% Wczytanie danych
T0 = readtable('PI_NIC_45.csv');           % dane z oryginalnymi nastawami
T = readtable('PI_NIC5x_45.csv');          % dane z nastawami przemnożonymi x3
czas = (1:height(T)) * 2;  % co 2 sekundy

% Ustal wspólną długość
min_len = min([height(T0), height(T)]);

% Skrócone dane
czas = (1:min_len) * 2;
T0 = T0(1:min_len, :);
T = T(1:min_len, :);

% === WYKRES 1: Temperatura ===
figure;

plot(czas, T0.Tavg(1:length(czas)), '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.2); % szara linia odniesienia
hold on;
plot(czas, T.Tavg, 'r-', 'LineWidth', 2);
ylim([20, 40])
xlim([0, 1500])
% Linie poziome: max i min temperatury
maxT = max(T.Tavg);
minT = min(T.Tavg);
yline(maxT, 'k--', 'LineWidth', 1);
yline(minT, 'k--', 'LineWidth', 1);

% Pogrubione ticki Y
yticks = unique([get(gca, 'YTick'), maxT, minT]);
yticks = yticks(~ismember(round(yticks, 2), [24]));  % usuń 38 jeśli niepotrzebne
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
legend('PI – nastawy Ziegler–Nichols', 'PI – 7× wzmocnienie', 'Location', 'best');
grid on;

% === WYKRES 2: PWM i PID_raw ===
figure;

% Szara linia z porównania
plot(czas, T0.PWM(1:length(czas)), '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.2); % PWM z oryginalnych nastaw
hold on;

plot(czas, T.PWM, 'b-', 'LineWidth', 1.8);  % rzeczywiste PWM (wariant x3)
plot(czas, T.PID_raw, '--', 'Color', [0 0.4 1], 'LineWidth', 1.5);  % PID_raw jako linia przerywana
xlim([0, 1500])
% Linie przerywane ograniczeń
yline(0, 'k--', 'LineWidth', 1);
yline(255, 'k--', 'LineWidth', 1);

xlabel('Czas [s]');
ylabel('Moc PWM');
title('Sterowanie PI: PWM i PWM przed ograniczeniem');
legend('PWM – nastawy Ziegler–Nichols', 'PWM – 7× wzmocnienie', 'PWM przed ograniczeniem', 'Ograniczenia', 'Location', 'best');
ylim([-20 280]);
grid on;
