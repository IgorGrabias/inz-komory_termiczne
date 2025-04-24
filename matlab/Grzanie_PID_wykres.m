% Wczytanie danych
T = readtable('Histereza_35_on_off_w_cooling.csv');
czas = (1:height(T)) * 2;  % pomiary co 2 sekundy

% Jeśli kolumna Status istnieje (opcjonalnie)
if ismember('Status', T.Properties.VariableNames)
    heating_idx = strcmp(T.Status, 'Heating');
    cooling_idx = strcmp(T.Status, 'Cooling');
else
    heating_idx = true(height(T), 1);   % wszystko traktujemy jako grzanie
    cooling_idx = false(height(T), 1);  % brak chłodzenia
end

% Wykres temperatury
figure;
hold on;
plot(czas(heating_idx), T.Tavg(heating_idx), 'r-', 'LineWidth', 2);
plot(czas(cooling_idx), T.Tavg(cooling_idx), 'b-', 'LineWidth', 2);

% Linie poziome: maksimum i minimum temperatury
maxT = max(T.Tavg);
minT = min(T.Tavg);
yline(maxT, 'k--', 'LineWidth', 1);
yline(minT, 'k--', 'LineWidth', 1);

% Y-ticki z pogrubionym max/min
yticks = unique([get(gca, 'YTick'), maxT, minT]);
ytick_labels = arrayfun(@(y) sprintf('%.1f', y), yticks, 'UniformOutput', false);
highlighted = ismember(round(yticks, 2), round([maxT, minT], 2));
for i = 1:length(ytick_labels)
    if highlighted(i)
        ytick_labels{i} = ['\bf' ytick_labels{i}];
    end
end
set(gca, 'YTick', yticks, 'YTickLabel', ytick_labels);

xlabel('Czas [s]');
ylabel('Średnia temperatura [°C]');
title('Temperatura w czasie');
legend('Grzanie', 'Chłodzenie', 'Location', 'best');
grid on;
