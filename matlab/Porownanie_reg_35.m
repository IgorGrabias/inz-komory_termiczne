% === Ścieżki do plików ===
files = {
    'PI_25_017_002_LOW.csv', ...
    'Dwustawowe35_kp5_ki00412.csv', ...
    'Histereza_35_on_off.csv'
};

% === Nazwy do legendy ===
labels = {
    'Regulator PI z Ki = 0,09', ...
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

    % Zamiana przecinków na kropki
    T.Tavg = str2double(strrep(string(T.Tavg), ',', '.'));

    % Obsługa kolumny PWM lub zamiennik na podstawie Status
    if ismember('PWM', T.Properties.VariableNames)
        T.PWM = str2double(strrep(string(T.PWM), ',', '.'));
    elseif ismember('Status', T.Properties.VariableNames)
        status = string(T.Status);
        T.PWM = zeros(height(T), 1);
        T.PWM(status == "Heating") = 255;
        T.PWM(status == "Idle") = 0;
    else
        T.PWM = 255 * ones(height(T), 1);
    end

    % Filtr test == 5 tylko dla pierwszego pliku
    if i == 1 && ismember('test', T.Properties.VariableNames)
        T.test = str2double(strrep(string(T.test), ',', '.'));
        T = T(T.test == 5, :);
        Ts = 3;
    else
        Ts = 2;
    end

    czas_all{i} = (0:height(T)-1) * Ts;
    T_all{i} = T.Tavg;
    PWM_all{i} = T.PWM;
end

% === Wykres 1: Temperatura ===
figure;
hold on;
for i = 1:3
    plot(czas_all{i}, T_all{i}, 'Color', colors(i, :), 'LineWidth', 1.5, 'DisplayName', labels{i});
end

% Pozioma linia temperatury zadanej (35°C)
yline(35, '--k', 'Temperatura zadana 35°C', 'LineWidth', 1.2, ...
    'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom');

xlabel('Czas [s]');
ylabel('Temperatura [°C]');
title('Porównanie przebiegu temperatury dla różnych typów regulacji');
legend('Location', 'best');
xlim([0, 1000])
grid on;

% === Wykres 2: PWM ===
figure;
hold on;
for i = 1:3
    czas = czas_all{i};
    pwm = PWM_all{i};

    if i == 3  % Regulacja progowa (tylko grzanie)
        for j = 2:length(pwm)
            style = '-';
            if pwm(j) ~= pwm(j-1)
                style = '--';
            end
            plot(czas(j-1:j), pwm(j-1:j), style, 'Color', colors(i,:), ...
                'LineWidth', 1.5, 'HandleVisibility', 'off');
        end
        % Jedna linia do legendy
        plot(NaN, NaN, '-', 'Color', colors(i,:), 'LineWidth', 1.5, ...
            'DisplayName', labels{i});

    elseif i == 2  % Regulacja hybrydowa (pełna moc + PI)
        for j = 2:length(pwm)
            if pwm(j-1) == 255 && pwm(j) < 255
                % Przejście z pełnej mocy – narysuj pionową przerywaną
                plot(czas(j-1:j), pwm(j-1:j), '--', 'Color', colors(i,:), ...
                    'LineWidth', 1.5, 'HandleVisibility', 'off');
            else
                plot(czas(j-1:j), pwm(j-1:j), '-', 'Color', colors(i,:), ...
                    'LineWidth', 1.5, 'HandleVisibility', 'off');
            end
        end
        % Jedna linia do legendy
        plot(NaN, NaN, '-', 'Color', colors(i,:), 'LineWidth', 1.5, ...
            'DisplayName', labels{i});

    else  % Regulator PI
        plot(czas, pwm, '-', 'Color', colors(i,:), 'LineWidth', 1.5, ...
            'DisplayName', labels{i});
    end
end
xlabel('Czas [s]');
ylabel('Moc PWM');
title('Porównanie przebiegu mocy PWM dla różnych typów regulacji');
legend('Location', 'best');
xlim([0, 1000])
ylim([-10, 270])
grid on;
