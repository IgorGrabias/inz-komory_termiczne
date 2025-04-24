% Wczytaj dane
T = readtable('Histereza_35_on_off_w_cooling.csv');
czas = (1:height(T)) * 2;  % co 2 sekundy
Ts = 2;                   % czas próbkowania [s]
setpoint = 35;            % wartość zadana

% Obliczenie uchybu
e = setpoint - T.Tavg;

% IAE – suma uchybu bezwzględnego
IAE = sum(abs(e)) * Ts;

% MSE i RMSE
MSE = mean((e).^2);
RMSE = sqrt(MSE);

% Czas narastania (czas od 10% do 90% wartości zadanej)
T90 = setpoint * 0.9;
T10 = setpoint * 0.1;
try
    idx10 = find(T.Tavg >= T10, 1);
    idx90 = find(T.Tavg >= T90, 1);
    t_rise = (idx90 - idx10) * Ts;
catch
    t_rise = NaN;
end

% Przeregulowanie [%]
Tmax = max(T.Tavg);
overshoot = max(0, (Tmax - setpoint) / setpoint * 100);

% Czas regulacji – ostatni moment przekroczenia tolerancji
tolerance = 1.33; % Można też: 0.05 * setpoint
idx_settle = find(abs(e) > tolerance, 1, 'last');
if isempty(idx_settle)
    t_settle = 0;
else
    t_settle = idx_settle * Ts;
end

% Mapowanie stanów na moc (W)
powerMap = containers.Map({'Heating', 'Cooling', 'Idle'}, [40, 40, 0]);
moc = zeros(idx_settle, 1);
for i = 1:idx_settle
    moc(i) = powerMap(T.Status{i});
end

% Obliczenie zużycia energii (Wh) do czasu regulacji
czas_h = Ts / 3600;
energia_Wh = sum(moc) * czas_h;

% === DODANE: energia i moc dla zakresu czasu ===
czas_start = 660;  % [s]
czas_koniec = 494; % [s]



idx_start = round(czas_start / Ts) + 1;
idx_end = height(T);

moc_zakres = zeros(idx_end - idx_start + 1, 1);
for i = idx_settle:idx_end
    moc_zakres(i - idx_settle + 1) = powerMap(T.Status{i});
end
srednia_moc_W = mean(moc_zakres);


% Wyświetlenie wyników
fprintf('IAE (suma uchybu bezwzględnego): %.2f\n', IAE);
fprintf('MSE (błąd średniokwadratowy): %.2f\n', MSE);
fprintf('RMSE (pierwiastek z błędu średniokwadratowego): %.2f\n', RMSE);
fprintf('Czas narastania: %.0f s\n', t_rise);
fprintf('Przeregulowanie: %.2f%%\n', overshoot);
fprintf('Czas regulacji: %.0f s\n', t_settle);
fprintf('Zużycie energii do czasu regulacji: %.2f Wh\n', energia_Wh);
fprintf('Śr. moc w stanie ust. [W]  %.2f ', srednia_moc_W);

