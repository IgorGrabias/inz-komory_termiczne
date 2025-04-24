% === Ścieżki do plików ===
files = {
    'PI_NIC5x_45.csv', ...
    'Dwustawowe45_kp5_ki004093.csv', ...
    'Histereza_45_on_of.csv'
};

% === Nazwy do legendy ===
labels = {
    'Regulator PI (nastawy 5x)', ...
    'Regulacja hybrydowa (pełna moc + PI)', ...
    'Regulacja progowa (tylko grzanie)'
};

% === Kolory ===
colors = lines(3);

% === Inicjalizacja danych ===
T_all = cell(1, 3);
PWM_all = cell(1, 3);
czas_all = cell(1, 3);

for i = 1:3
    T = readtable(files{i});
    T.Tavg = str2double(strrep(string(T.Tavg), ',', '.'));

    if ismember('PWM', T.Properties.VariableNames)
        T.PWM = str2double(strrep(string(T.PWM), ',', '.'));
    elseif ismember('Status', T.Properties.VariableNames)
        status = string(T.Status);
        T.PWM = zeros(height(T), 1);
        T.PWM(status == "Heating") = 255;
    else
        T.PWM = 255 * ones(height(T), 1);
    end

    if i == 1 && any(strcmp('test', T.Properties.VariableNames))
        T.test = str2double(strrep(string(T.test), ',', '.'));
        T = T(T.test == 5, :);
        Ts = 3;
    else
        Ts = 2;
    end

    czas = (0:height(T)-1) * Ts;
    czas_all{i} = czas;
    T_all{i} = T.Tavg;
    PWM_all{i} = T.PWM;
end

% === Wykres 1: Temperatura ===
figure;
hold on;
for i = 1:3
    plot(czas_all{i}, T_all{i}, 'Color', colors(i, :), 'LineWidth', 1.5, 'DisplayName', labels{i});
end
yline(45, 'k--', 'LineWidth', 1.2, 'HandleVisibility', 'off');
text(100, 45.3, 'Temperatura zadana 45\circC', 'FontSize', 10, 'Color', 'k');
xlim([0, 1500])
xlabel('Czas [s]');
ylabel('Temperatura [\circC]');
title('Porównanie przebiegu temperatury dla różnych typów regulacji');
legend('Location', 'best');
grid on;

% === Wykres 2: PWM ===
figure;
hold on;

for i = 1:3
    czas = czas_all{i};
    pwm = PWM_all{i};

    if i == 3  % Regulacja progowa (tylko grzanie)
        % Rysuj odcinki poziome + przerywane pionowe przejścia
        for j = 2:length(pwm)
            if pwm(j) ~= pwm(j-1)
                plot(czas(j-1:j), pwm(j-1:j), '--', 'Color', colors(i,:), ...
                    'LineWidth', 1.5, 'HandleVisibility', 'off');
            else
                plot(czas(j-1:j), pwm(j-1:j), '-', 'Color', colors(i,:), ...
                    'LineWidth', 1.5, 'HandleVisibility', 'off');
            end
        end
        % Dodaj 1 linie do legendy
        plot(NaN, NaN, '-', 'Color', colors(i,:), 'LineWidth', 1.5, ...
            'DisplayName', labels{i});

    elseif i == 2  % Regulacja hybrydowa (pełna moc + PI)
        for j = 2:length(pwm)
            if pwm(j-1) == 255 && pwm(j) < 255
                % Przerywana pionowa przy zejściu z pełnej mocy
                plot(czas(j-1:j), pwm(j-1:j), '--', 'Color', colors(i,:), ...
                    'LineWidth', 1.5, 'HandleVisibility', 'off');
            else
                plot(czas(j-1:j), pwm(j-1:j), '-', 'Color', colors(i,:), ...
                    'LineWidth', 1.5, 'HandleVisibility', 'off');
            end
        end
        % Dodaj 1 linie do legendy
        plot(NaN, NaN, '-', 'Color', colors(i,:), 'LineWidth', 1.5, ...
            'DisplayName', labels{i});
    else
        % PI – rysuj normalnie
        plot(czas, pwm, '-', 'Color', colors(i,:), 'LineWidth', 1.5, ...
            'DisplayName', labels{i});
    end
end

xlabel('Czas [s]');
ylabel('Moc PWM');
title('Porównanie przebiegu mocy PWM dla różnych typów regulacji');
legend('Location', 'best');
xlim([0, 1500]);
ylim([0, 270]);
grid on;


