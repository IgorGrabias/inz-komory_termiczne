% Wczytaj dane
opts = detectImportOptions('PI_NIC4x_35.csv', 'Delimiter', ';');
data = readtable('PI_NIC4x_35.csv', opts);

Tavg = data.Tavg;
status = data.Status;
time = (0:height(data)-1) * 2;  % co 2 sekundy

% Mapowanie statusów na kolory
colorMap = containers.Map({'Heating', 'Cooling', 'Idle'}, ...
                          {[1 0 0], [0 0 1], [0.5 0.5 0.5]}); % RGB

% Granice histerezy
%hystHigh = 45.33;
hystSet = 50.00;
hystLow = 49.00;
%hystSetreal = 47
figure;
hold on;
ylim([20 55]);
xlim([0 1000]);
% Rysowanie linii między punktami wg statusu
for i = 1:length(Tavg)-1
    x = [time(i), time(i+1)];
    y = [Tavg(i), Tavg(i+1)];
    color = colorMap(status{i});
    plot(x, y, '-', 'Color', color, 'LineWidth', 2);
end

% Linie przerywane – granice histerezy
%yline(hystHigh, '--k', sprintf('%.2f°C', hystHigh), ...
 %   'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'top');
yline(hystLow, '--k', sprintf('%.2f°C', hystLow), ...
   'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom');
%yline(hystSetreal, '--k', sprintf('%.2f°C', hystSetreal ), ...
    %'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'top');
    
% Czerwona linia przerywana - Setpoint
yline(hystSet, '--r', 'Setpoint = 50°C'  , ...
    'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'top');

% Etykiety wykresu
xlabel('Czas [s]');
ylabel('Temperatura średnia [°C]');
title('Regulacja ON/OFF temperatura w czasie, Setpoint = 50°C');
grid on;

% Legenda
h1 = plot(NaN, NaN, '-', 'Color', [1 0 0], 'LineWidth', 2, 'DisplayName', 'Heating');
h3 = plot(NaN, NaN, '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 2, 'DisplayName', 'Idle');
h4 = plot(NaN, NaN, '--r', 'LineWidth', 1.5, 'DisplayName', 'Setpoint');

legend([h1, h3, h4], 'Location', 'northeast');
