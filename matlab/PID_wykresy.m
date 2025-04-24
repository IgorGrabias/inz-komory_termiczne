% Wczytanie danych
T = readtable('Dwustawowe-35.csv');
czas = (1:height(T)) * 2;  % co 2 sekundy

% === WYKRES 1: Temperatura ===
figure;
plot(czas, T.Tavg, 'r-', 'LineWidth', 2);
hold on;

% Linie poziome: max i min temperatury
maxT = max(T.Tavg);
minT = min(T.Tavg);
yline(maxT, 'k--', 'LineWidth', 1);
yline(minT, 'k--', 'LineWidth', 1);

% Pogrubione ticki Y
yticks = unique([get(gca, 'YTick'), maxT, minT]);
yticks = yticks(~ismember(round(yticks, 2), [38]));  % usuń 40 i 24
ytick_labels = arrayfun(@(y) sprintf('%.1f', y), yticks, 'UniformOutput', false);
highlighted = ismember(round(yticks, 2), round([maxT, minT], 2));
for i = 1:length(ytick_labels)
    if highlighted(i)
        ytick_labels{i} = ['\bf' ytick_labels{i}];
    end
end
set(gca, 'YTick', yticks, 'YTickLabel', ytick_labels);

xlabel('Czas [s]');
ylabel('Temperatura [°C]');
title('Temperatura w czasie');
legend('Średnia temperatura', 'Location', 'best');
grid on;

% === WYKRES 2: PWM i PID_raw ===
figure;

plot(czas, T.PWM, 'b-', 'LineWidth', 1.8);  % rzeczywiste PWM
hold on;
plot(czas, T.PID_raw, '--', 'Color', [0 0.4 1], 'LineWidth', 1.5);  % PID_raw jako linia przerywana

% Linie przerywane ograniczeń
yline(0, 'k--', 'LineWidth', 1);
yline(255, 'k--', 'LineWidth', 1);

xlabel('Czas [s]');
ylabel('Moc PWM');
title('Sterowanie PI: PWM i PWM przed ograniczeniem');
legend('PWM (realna moc)', 'PWM przed ograniczeniem', 'Ograniczenia', 'Location', 'best');
ylim([-20 280]);
grid on;
