T = readtable('Test_grzanie_izo_2');
czas = (1:height(T)) * 2;  % 2 sekundy odstępu

figure;
hold on;

% Wykresy
plot(czas, T.t1, 'r-', 'LineWidth', 1.5);
plot(czas, T.t2, 'g-', 'LineWidth', 1.5);
plot(czas, T.t3, 'b-', 'LineWidth', 1.5);

% Maksima i minima
max_t1 = max(T.t1); min_t1 = min(T.t1);
max_t2 = max(T.t2); min_t2 = min(T.t2);
max_t3 = max(T.t3); min_t3 = min(T.t3);

maxAll = max([max_t1, max_t2, max_t3]);
minAll = min([min_t1, min_t2, min_t3]);
% Linie poziome
yline(maxAll, 'k--', 'LineWidth', 1);
yline(minAll, 'k--', 'LineWidth', 1);

% Oś Y – pogrubione wartości (dodajemy ticki ręcznie)
yticks = unique([get(gca, 'YTick'), maxAll, minAll]);
yticks = yticks(yticks ~= 55);
ytick_labels = arrayfun(@(y) sprintf('%.1f', y), yticks, 'UniformOutput', false);

% Pogrubiamy tylko wartości odpowiadające ekstremom
highlighted = ismember(round(yticks, 2), round([maxAll, minAll], 2));
for i = 1:length(ytick_labels)
    if highlighted(i)
        ytick_labels{i} = ['\bf' ytick_labels{i}];
    end
end

set(gca, 'YTick', yticks, 'YTickLabel', ytick_labels);

xlabel('Czas [s]');
ylabel('Temperatura [°C]');
title('Charakterystyki temperatury z czujników w czasie');

legend(...
    'T1 – czujnik w środkowej części komory', ...
    'T2 – czujnik przy górnej krawędzi komory', ...
    'T3 – czujnik przy dolnej krawędzi komory' ...
);

grid on;
