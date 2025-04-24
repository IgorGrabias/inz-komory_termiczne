% === WCZYTANIE I PRZYGOTOWANIE DANYCH ===
T = readtable('PI_NIC5x_35_2.csv', 'Delimiter', ';', 'Encoding', 'ISO-8859-2', 'ReadVariableNames', true);

% Zamiana przecinków na kropki i konwersja na liczby
T.Tavg = str2double(strrep(string(T.Tavg), ',', '.'));
T.PWM = str2double(strrep(string(T.PWM), ',', '.'));

% === PARAMETRY EKSPERYMENTU ===
setpoint = 35.0;         % temperatura zadana
Ts = 2;                  % czas próbkowania [s]
pelnamoc_W = 40;       % moc przy PWM=255 [W]

% === OBLICZENIE METRYK ===
n = height(T);
tolerance = 1;
idx_settle = find(abs(T.Tavg - setpoint) > tolerance, 1, 'last');

e = setpoint - T.Tavg(1:idx_settle);
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

fprintf('%f', idx_settle)

% === METRYKI I OPISY ===
disp("DEBUG energia_Wh przed tabelą:");
disp(energia_Wh);
disp("DEBUG sr_moc_post:");
disp(sr_moc_post);
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

% === GENEROWANIE TABELI LATEX ===
fprintf('\\begin{table}[H]\n\\centering\n\\caption{Metryki dla pojedynczego testu}\n\\begin{tabular}{|l|c|}\n');
fprintf('\\hline\n\\textbf{Metryka} & \\textbf{Wartość} \\\\\n\\hline\n');

for r = 1:length(metryki)
    fprintf('%s & %.2f \\\\\n', metryki_labels{r}, metryki(r));
end

fprintf('\\hline\n\\end{tabular}\n\\end{table}\n');
