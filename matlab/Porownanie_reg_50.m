% === Ścieżki do plików ===
files = {
    'PI_NIC5x_50.csv', ...
    'Dwustawowe50_kp5_ki0040.csv', ...
    'Histereza_50_on_off.csv'
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
    T = readtable(files{i}, 'Encoding', 'ISO-8859-2');

    % Naprawa przecinków i konwersja
    T.Tavg = str2double(strrep(string(T.Tavg), ',', '.'));

    % Obsługa PWM
    if ismember('PWM', T.Properties.VariableNames)
        T.PWM = str2double(strrep(string(T.PWM), ',', '.'));
    elseif ismember('Status', T.Properties.VariableNames)
        % Zamień status Heating na 255, Idle na 0
        T.PWM = zeros(height(T), 1);
        T.PWM(strcmp(T.Status, 'Heating')) = 255;
    else
        T.PWM = 255 * ones(height(T), 1); % Domyślnie pełna moc
    end

    Ts = 2;
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
xlim([0, 1500])
xlabel('Czas [s]');
ylabel('Temperatura [°C]');
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
        % Rysuj przerywane i ciągłe odcinki bez wpisu do legendy
        for j = 2:length(pwm)
            style = '-';
            if pwm(j) ~= pwm(j-1)
                style = '--';
            end
            plot(czas(j-1:j), pwm(j-1:j), style, 'Color', colors(i,:), ...
                'LineWidth', 1.5, 'HandleVisibility', 'off');
        end
        % Dodaj tylko 1 linię do legendy
        plot(NaN, NaN, '-', 'Color', colors(i,:), 'LineWidth', 1.5, ...
            'DisplayName', labels{i});

    elseif i == 2  % Regulacja hybrydowa
        for j = 2:length(pwm)
            if pwm(j-1) == 255 && pwm(j) < 255
                % Przerywane pionowe zejście z pełnej mocy
                plot(czas(j-1:j), pwm(j-1:j), '--', 'Color', colors(i,:), ...
                    'LineWidth', 1.5, 'HandleVisibility', 'off');
            else
                plot(czas(j-1:j), pwm(j-1:j), '-', 'Color', colors(i,:), ...
                    'LineWidth', 1.5, 'HandleVisibility', 'off');
            end
        end
        % Dodaj tylko 1 linię do legendy
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
xlim([0, 1500]);
ylim([-10, 270]);
grid on;
