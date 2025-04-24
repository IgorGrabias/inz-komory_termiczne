% Wczytaj dane
T1 = readtable('test_grz_izo_2.csv');
T2 = readtable('Test_grz.csv');

czas1 = (1:height(T1)) * 2;
czas2 = (1:height(T2)) * 2;

% Indeksy stanów
heat1 = strcmp(T1.Status, 'Heating');
cool1 = strcmp(T1.Status, 'Cooling');
heat2 = strcmp(T2.Status, 'Heating');
cool2 = strcmp(T2.Status, 'Cooling');

% Rysowanie wykresu
figure; hold on;

% Wykresy wilgotności
h1 = plot(czas1(heat1), T1.Havg(heat1), 'r-', 'LineWidth', 2);
h2 = plot(czas1(cool1), T1.Havg(cool1), 'b-', 'LineWidth', 2);
plot(czas2(heat2), T2.Havg(heat2), 'r-', 'LineWidth', 2, 'HandleVisibility', 'off');
plot(czas2(cool2), T2.Havg(cool2), 'b-', 'LineWidth', 2, 'HandleVisibility', 'off');

% Podpisy z przesunięciem w prawo o ~500 sekund
idx_cool1 = find(cool1);
idx_heat2 = find(heat2);
midIdxCool = idx_cool1(round(end/2));
midIdxHeat = idx_heat2(round(end/2));

text(czas1(midIdxCool) + 200, T1.Havg(midIdxCool) + 1, 'Model z izolacją', ...
    'HorizontalAlignment', 'left', 'FontWeight', 'bold', 'Color', 'k', 'FontSize', 10);
text(czas2(midIdxHeat) + 600, T2.Havg(midIdxHeat) + 1, 'Model bez izolacji', ...
    'HorizontalAlignment', 'left', 'FontWeight', 'bold', 'Color', 'k', 'FontSize', 10);

% Min i max wilgotności z obu plików
hvals = round([min(T1.Havg), 30.67, min(T2.Havg), 33.67], 2);
hvals = unique(hvals);  % usuń ewentualne powtórzenia

% Linie przerywane
for i = 1:length(hvals)
    yline(hvals(i), 'k--', 'LineWidth', 1);
end

% Ticki Y + pogrubienie odpowiednich
yt_all = get(gca, 'YTick');
yt_combined = unique([yt_all, hvals]);
yt_combined = sort(yt_combined);

% Usuń ticki 50, 35, 15
yt_combined = yt_combined(~ismember(round(yt_combined, 2), [50, 30, 15]));

ytick_labels = strings(size(yt_combined));
for i = 1:length(yt_combined)
    if ismember(round(yt_combined(i), 2), hvals)
        ytick_labels(i) = ['\bf' sprintf('%.1f', yt_combined(i))];
    else
        ytick_labels(i) = sprintf('%.1f', yt_combined(i));
    end
end

set(gca, 'YTick', yt_combined, 'YTickLabel', ytick_labels);
set(gca, 'TickLabelInterpreter', 'tex');  % aby \bf działało

% Zakres Y od zera
ylim([0, max(ylim)]);

% Opisy i legenda
xlabel('Czas [s]');
ylabel('Średnia wilgotność [%]');
title('Wilgotność w czasie – porównanie dla chłodzenia pasywnego');
legend([h1, h2], {'Grzanie', 'Chłodzenie'}, 'Location', 'best');
grid on;
