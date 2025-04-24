% Wczytaj dane z dwóch plików
T1 = readtable('test_grz_izo_2.csv');
T2 = readtable('Test_grz.csv');

czas1 = (1:height(T1)) * 2;
czas2 = (1:height(T2)) * 2;

% Indeksy stanów
heat1 = strcmp(T1.Status, 'Heating'); cool1 = strcmp(T1.Status, 'Cooling');
heat2 = strcmp(T2.Status, 'Heating'); cool2 = strcmp(T2.Status, 'Cooling');

figure;
hold on;

% Rysuj grzanie i chłodzenie dla obu zestawów danych
h1 = plot(czas1(heat1), T1.Tavg(heat1), 'r-', 'LineWidth', 2);
h2 = plot(czas1(cool1), T1.Tavg(cool1), 'b-', 'LineWidth', 2);

plot(czas2(heat2), T2.Tavg(heat2), 'r-', 'LineWidth', 2, 'HandleVisibility', 'off');
plot(czas2(cool2), T2.Tavg(cool2), 'b-', 'LineWidth', 2, 'HandleVisibility', 'off');

% Dodaj podpisy w połowie przebiegu
idx_cool1 = find(cool1);
idx_heat2 = find(heat2);

% Chłodzenie – podpis połowy czasu
midIdxCool = idx_cool1(round(end/2));
text(3230, 31, 'Model z izolacją', ...
    'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'VerticalAlignment', 'bottom', ...
    'Color', 'k', 'FontSize', 10);

% Grzanie – podpis połowy czasu
midIdxHeat = idx_heat2(round(end/2));
text(1400, 29, 'Model bez izolacji', ...
    'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'VerticalAlignment', 'bottom', ...
    'Color', 'k', 'FontSize', 10);

% Skala Y – usuń np. 55
yt = get(gca, 'YTick');
yt = yt(yt ~= 55);  % usuń tick 55
% yt = yt(yt ~= 20);
set(gca, 'YTick', yt);

% Linia maks/min
yline(max([T1.Tavg; T2.Tavg]), 'k--', 'LineWidth', 1);
yline(min([T1.Tavg; T2.Tavg]), 'k--', 'LineWidth', 1);
yline(35, 'k--', 'LineWidth', 1);


% Pogrubione ticki Y
yticks = unique([get(gca, 'YTick'), max([T1.Tavg; T2.Tavg]), 35, min([T1.Tavg; T2.Tavg])]);
ytick_labels = arrayfun(@(y) sprintf('%.1f', y), yticks, 'UniformOutput', false);
highlighted = ismember(round(yticks, 2), round([max([T1.Tavg; T2.Tavg]), 35, 21, min([T1.Tavg; T2.Tavg])], 2));
for i = 1:length(ytick_labels)
    if highlighted(i)
        ytick_labels{i} = ['\bf' ytick_labels{i}];
    end
end
set(gca, 'YTick', yticks, 'YTickLabel', ytick_labels);

xlabel('Czas [s]');
ylabel('Średnia temperatura [°C]');
title('Temperatura w czasie – porównanie dla chłodzenia aktywnego');

% Tylko dwa elementy w legendzie
legend([h1, h2], {'Grzanie', 'Chłodzenie'}, 'Location', 'best');
grid on;