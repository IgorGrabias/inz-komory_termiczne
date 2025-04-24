% Wczytaj dane
opts = detectImportOptions('Histereza_50_on_off.csv', 'Delimiter', ';');
data = readtable('Histereza_50_on_off.csv', opts);

Tavg = data.Tavg;
status = data.Status;
time = (0:height(data)-1) * 2;  % co 2 sekundy

% Mapowanie statusów na kolory
tempColorMap = containers.Map({'Heating', 'Cooling', 'Idle'}, ...
                          {[1 0 0], [0 0 1], [0.5 0.5 0.5]}); % RGB
pwmMap = containers.Map({'Heating', 'Cooling', 'Idle'}, {255, -255, 0});
pwmColorMap = containers.Map( ...
    {'Heating', 'Cooling', 'Idle'}, ...
    {[1 0 0], [0 0 1], [0.5 0.5 0.5]});

% Granice histerezy
hystSet = 50.00;
hystLow = 49;
hystHigh = 45.33;

figure;
hold on;
ylim([20 52]);
xlim([0 1000]);

% Wykres temperatury
for i = 1:length(Tavg)-1
    x = [time(i), time(i+1)];
    y = [Tavg(i), Tavg(i+1)];
    color = tempColorMap(status{i});
    plot(x, y, '-', 'Color', color, 'LineWidth', 2);
end

% Linie przerywane – granice histerezy
yline(hystLow, '--k', sprintf('%.2f°C', hystLow), ...
   'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom');
yline(hystSet, '--r', 'Wartość zadana = 45°C', ...
    'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'top');
%yline(hystHigh, '--k', sprintf('%.2f°C', hystHigh), ...
%   'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'top');

% Etykiety wykresu
ylabel('Temperatura średnia [°C]');
xlabel('Czas [s]');
title('Przebieg temperatury w czasie dla regulacji progowej');
grid on;

% Legenda temperatury
h1 = plot(NaN, NaN, '-', 'Color', [1 0 0], 'LineWidth', 2, 'DisplayName', 'Grzanie');
h2 = plot(NaN, NaN, '-', 'Color', [0 0 1], 'LineWidth', 2, 'DisplayName', 'Chłodzenie');
h3 = plot(NaN, NaN, '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 2, 'DisplayName', 'Stan bezczynności');
h4 = plot(NaN, NaN, '--r', 'LineWidth', 1.5, 'DisplayName', 'Wartość zadana');
legend([h1, h3, h4], 'Location', 'northeast');

% Wykres mocy
figure;
hold on;
xlim([0 1000]);
ylim([-10 260]);

for i = 1:length(status)-1
    x = [time(i), time(i+1)];
    y = [pwmMap(status{i}), pwmMap(status{i+1})];
    color = pwmColorMap(status{i});
    plot(x, y, '-', 'Color', color, 'LineWidth', 2);
end

ylabel('PWM');
xlabel('Czas [s]');
title('Przebieg PWM dla regulacji progowej');
grid on;

% Legenda mocy
p1 = plot(NaN, NaN, '-', 'Color', [1 0 0], 'LineWidth', 2, 'DisplayName', 'PWM (Grzanie = 255)');
p2 = plot(NaN, NaN, '-', 'Color', [0 0 1], 'LineWidth', 2, 'DisplayName', 'PWM (Chłodzenie = -255)');
p3 = plot(NaN, NaN, '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 2, 'DisplayName', 'PWM (Idle = 0)');
legend([p1, p3], 'Location', 'southoutside');

% PARAMETRY SYSTEMU
pelnamoc_W = 40;             % pełna moc przy PWM = 255
czas_probkowania_s = 2;      % interwał próbkowania
czas_probkowania_h = czas_probkowania_s / 3600;  % w godzinach

% Oblicz średnią moc względną (|PWM|/255), przemnóż przez pełną moc
rel_moc = abs(cellfun(@(s) pwmMap(s), status)) / 255;  % wektor wartości 0...1
moc_W = rel_moc * pelnamoc_W;  % rzeczywista moc w watach

% Całkowite zużycie energii (Wh)
energia_Wh = sum(moc_W) * czas_probkowania_h;

% Wypisanie zużycia energii w konsoli
fprintf('Całkowite zużycie energii: %.2f Wh\n', energia_Wh);
