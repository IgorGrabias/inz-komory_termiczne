% Lista plików i nazw
files = {'Histereza_35_on_off.csv', 'Histereza_35_on_off_w_cooling.csv', 'Histereza_35_on_off_w_cooling_2.csv'};
labels = {'Regulacja progowa - tylko grzanie', 'Regulacja progowa - grzanie i chłodzenie', 'Regulacja progowa – grzanie i chłodzenie ze strefą martwą'};
colors = {[1 0 0], [0 0 1], [0 0.6 0]};  % czerwony, niebieski, zielony

offsets = [-32, 0, -20];  % przesunięcia w sekundach (w lewo)

figure;
hold on;
xlim([0, 1000]);
ylim([20 40]);
xlabel('Czas [s]');
ylabel('Temperatura średnia [°C]');
title('Porównanie przebiegów temperatury');
grid on;

for i = 1:length(files)
    opts = detectImportOptions(files{i}, 'Delimiter', ';');
    data = readtable(files{i}, opts);

    Tavg = data.Tavg;
    time = (0:height(data)-1) * 2 + offsets(i);  % przesunięcie względem czasu

    plot(time, Tavg, 'LineWidth', 2, 'Color', colors{i}, 'DisplayName', labels{i});
end

% Wartość zadana
yline(35, '--k', 'Wartość zadana = 35°C', ...
    'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom', ...
    'HandleVisibility', 'off');

legend('Location', 'northeast');