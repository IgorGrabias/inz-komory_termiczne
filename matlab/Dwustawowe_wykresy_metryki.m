% Wczytanie danych
T = readtable('Dwustanowy45_kp5_ki00408.csv');
czas = (1:height(T)) * 2;  % co 2 sekundy

% Kolory
kolorMAX = [1 0 0];          % czerwony
kolorPI = [1 0.5 0];         % pomarańczowy
stylMAX = '-';
stylPI = '--';

% === WYKRES 1: Temperatura ===
figure;
hold on;
title('Temperatura w czasie');
xlabel('Czas [s]');
ylabel('Temperatura [°C]');

for i = 1:height(T)-1
    x_vals = czas(i:i+1);
    y_vals = T.Tavg(i:i+1);
    if strcmp(T.status{i}, 'MAX') && strcmp(T.status{i+1}, 'MAX')
        plot(x_vals, y_vals, stylMAX, 'Color', kolorMAX, 'LineWidth', 2);
    elseif strcmp(T.status{i}, 'PI') && strcmp(T.status{i+1}, 'PI')
        plot(x_vals, y_vals, stylMAX, 'Color', kolorPI, 'LineWidth', 2);
    else
        % Połączenie między fragmentami
        plot(x_vals, y_vals, stylPI, 'Color', kolorPI, 'LineWidth', 1.5);
    end
end
yline(45, '--', 'Temperatura zadana 45°C', 'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom', ...
       'Color', [0.3 0.3 0.3], 'LineWidth', 1.2);

% Dodanie ukrytych linii tylko do legendy
h1 = plot(NaN, NaN, stylMAX, 'Color', kolorMAX, 'LineWidth', 2);
h2 = plot(NaN, NaN, stylMAX, 'Color', kolorPI, 'LineWidth', 2);
legend([h1 h2], {'MAX', 'PI'}, 'Location', 'best');
grid on;

% === WYKRES 2: PWM ===
figure;
hold on;
title('Sterowanie: PWM');
xlabel('Czas [s]');
ylabel('Moc PWM');

for i = 1:height(T)-1
    x_vals = czas(i:i+1);
    y_vals = T.PWM(i:i+1);
    if strcmp(T.status{i}, 'MAX') && strcmp(T.status{i+1}, 'MAX')
        plot(x_vals, y_vals, stylMAX, 'Color', kolorMAX, 'LineWidth', 2);
    elseif strcmp(T.status{i}, 'PI') && strcmp(T.status{i+1}, 'PI')
        plot(x_vals, y_vals, stylPI, 'Color', kolorPI, 'LineWidth', 2);
    else
        % Połączenie między fragmentami
        plot(x_vals, y_vals, stylPI, 'Color', kolorPI, 'LineWidth', 1.5);
    end
end

yline(0, 'k--', 'LineWidth', 1);
yline(255, 'k--', 'LineWidth', 1);
h1 = plot(NaN, NaN, stylMAX, 'Color', kolorMAX, 'LineWidth', 2);
h2 = plot(NaN, NaN, stylMAX,  'Color', kolorPI, 'LineWidth', 2);
legend([h1 h2], {'MAX', 'PI'}, 'Location', 'best');
ylim([-20 280]);
grid on;

% === METRYKI REGULACJI ===
setpoint = 45.0;
Ts = 2;  % próbkowanie [s]
pelnamoc_W = 40;  % pełna moc [W]

n = height(T);
tolerance = 1;
idx_settle = find(abs(T.Tavg - setpoint) > tolerance, 1, 'last');

e = setpoint - T.Tavg(1:(190/2));
IAE = nansum(abs(e)) * Ts;
MSE = nanmean(e.^2);
RMSE = sqrt(MSE);

T90 = setpoint * 0.9;
T10v = setpoint * 0.1;
try
    idx10 = find(T.Tavg >= T10v, 1);
    idx90 = find(T.Tavg >= T90, 1);
    t_rise = (idx90 - idx10) * Ts;
catch
    t_rise = NaN;
end

Tmax = max(T.Tavg);
overshoot = max(0, (Tmax - setpoint) / setpoint * 100);
t_settle = idx_settle * Ts;

PWM_rel = abs(T.PWM(1:idx_settle)) / 255;
moc = PWM_rel * pelnamoc_W;
energia_Wh = sum(moc) * Ts / 3600;

idx_end = n - 1;
PWM_rel_post = abs(T.PWM(idx_settle:idx_end)) / 255;
moc_post = PWM_rel_post * pelnamoc_W;
sr_moc_post = mean(moc_post);

% === WYŚWIETLENIE ===
metryki = [IAE; MSE; RMSE; t_rise; overshoot; t_settle; energia_Wh; sr_moc_post];
metryki_labels = {
    'IAE', 
    'MSE', 
    'RMSE', 
    'Czas narastania [s]', 
    'Przeregulowanie [\%]', 
    'Czas regulacji [s]', 
    'Zużycie energii do regulacji [Wh]', 
    'Śr. moc w stanie ust. [W]'};

fprintf('\n\n%% === TABELA METRYK (LaTeX) ===\n');
fprintf('\\begin{table}[H]\n\\centering\n\\caption{Metryki dla pojedynczego testu}\n\\begin{tabular}{|l|c|}\n');
fprintf('\\hline\n\\textbf{Metryka} & \\textbf{Wartość} \\\\\n\\hline\n');

for r = 1:length(metryki)
    fprintf('%s & %.2f \\\\\n', metryki_labels{r}, metryki(r));
end

fprintf('\\hline\n\\end{tabular}\n\\end{table}\n');

