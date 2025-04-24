% Wczytaj dane z dwóch plików
T1 = readtable('test_grz_izo_2.csv');
T2 = readtable('Test_grz.csv');

czas1 = (1:height(T1)) * 2;
czas2 = (1:height(T2)) * 2;

% Rysuj temperatury z trzech czujników
figure; hold on;

% Model z izolacją (T1)
p1 = plot(czas1, T1.t1, 'r-', 'LineWidth', 1.5);
p2 = plot(czas1, T1.t2, 'g-', 'LineWidth', 1.5);
p3 = plot(czas1, T1.t3, 'b-', 'LineWidth', 1.5);

% Model bez izolacji (T2)
plot(czas2, T2.t1, 'r-', 'LineWidth', 1.5, 'HandleVisibility', 'off');
plot(czas2, T2.t2, 'g-', 'LineWidth', 1.5, 'HandleVisibility', 'off');
plot(czas2, T2.t3, 'b-', 'LineWidth', 1.5, 'HandleVisibility', 'off');

% Podpisy
text(3250, 31, 'Model z izolacją', ...
    'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'VerticalAlignment', 'bottom', ...
    'Color', 'k', 'FontSize', 10);

text(1430, 27, 'Model bez izolacji', ...
    'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'VerticalAlignment', 'bottom', ...
    'Color', 'k', 'FontSize', 10);

% Linie odniesienia
ref_lines = [23, 35, ...
             max([T1.t1; T1.t2; T1.t3; T2.t1; T2.t2; T2.t3])];

for val = ref_lines
    yline(val, 'k--', 'LineWidth', 1);
end

% Skala Y – usuń wybrane ticki
yticks_all = unique([get(gca, 'YTick'), ref_lines]);
yticks_all = yticks_all(~ismember(round(yticks_all), [55, 25, 20]));
yticks_all = sort(yticks_all);

% Pogrubienie wybranych ticków
ytick_labels = arrayfun(@(y) sprintf('%.1f', y), yticks_all, 'UniformOutput', false);
highlighted = ismember(round(yticks_all, 2), round(ref_lines, 2));

for i = 1:length(ytick_labels)
    if highlighted(i)
        ytick_labels{i} = ['\bf' ytick_labels{i}];
    end
end

set(gca, 'YTick', yticks_all, 'YTickLabel', ytick_labels);
set(gca, 'TickLabelInterpreter', 'tex');

% Opisy i legenda
xlabel('Czas [s]');
ylabel('Temperatura [°C]');
title('Temperatura w czasie – porównanie (3 czujniki)');

legend([p1, p2, p3], {'Czujnik 1', 'Czujnik 2', 'Czujnik 3'}, 'Location', 'best');
grid on;
