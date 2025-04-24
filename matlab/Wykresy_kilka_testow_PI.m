% Wczytanie danych
T = readtable('PI_25_017_002_LOW.csv', 'Delimiter', ';', 'Encoding', 'ISO-8859-2');
T.test = str2double(string(T.test)); % konwersja tekstu na liczby

Ts = 3; % czas próbkowania
setpoint = 35;
pelnamoc_W = 40;

% Filtrowanie testów
T10 = T(T.test >= 0 & T.test <= 9, :);
testy = unique(T10.test);

% === WYKRES 1: TEMPERATURA ===
figure;
hold on;
for i = 1:length(testy)
    test_id = testy(i);
    dane = T10(T10.test == test_id, :).Tavg;
    czas = (0:length(dane)-1) * Ts;

    Ki_val = T10.Ki(find(T10.test == test_id, 1, 'first'));
    label = sprintf('Test %d (K_i = %.3f)', test_id , Ki_val);
    if (test_id == 5)
        plot(czas, dane, 'DisplayName', label, 'LineWidth', 1);
    else
        plot(czas, dane, 'DisplayName', label, 'LineWidth', 1);
    end
end
yline(setpoint, '--k', 'DisplayName', sprintf('Wartość zadana = %.1f°C', setpoint));
xlabel('Czas [s]');
ylabel('Średnia temperatura [°C]');
title('Przebiegi temperatury dla testów');
legend show;
grid on;

% === WYKRES 2: PWM ===
figure;
hold on;
for i = 1:length(testy)
    test_id = testy(i);
    daneH = T10(T10.test == test_id, :).PWM;
    czas = (0:length(daneH)-1) * Ts;

    Ki_val = T10.Ki(find(T10.test == test_id, 1, 'first'));
    label = sprintf('Test %d (K_i = %.3f)', test_id, Ki_val);

    plot(czas, daneH, 'DisplayName', label, 'LineWidth', 1);
end
xlabel('Czas [s]');
ylabel('Moc PWM [%]');
title('Przebiegi mocy dla testów');
legend show;
grid on;

% Wczytanie danych
T.test = str2double(string(T.test)); % konwersja tekstu na liczby


% === WCZYTANIE I PRZYGOTOWANIE DANYCH ===

% Zamiana przecinków na kropki i konwersja na liczby
T.Tavg = str2double(strrep(string(T.Tavg), ',', '.'));
T.PWM = str2double(strrep(string(T.PWM), ',', '.'));
T.test = str2double(strrep(string(T.test), ',', '.'));
T.test = str2double(string(T.test));
T10 = T(T.test >= 0 & T.test <= 9, :);
testy = unique(T10.test);

% === INICJALIZACJA MACIERZY METRYK ===
metryki = zeros(8, length(testy));


% === OBLICZENIA ===
for i = 1:length(testy)
    test_id = testy(i);
    subT = T10(T10.test == test_id, :);
    n = height(subT);
    
    try

        tolerance = 1;
        idx_settle = find(abs(subT.Tavg - setpoint) >= tolerance, 1, 'last');

        max_samples = 500 / Ts;
        e = setpoint - subT.Tavg(1:min(max_samples, height(subT)));
        MSE = nanmean(e.^2);

        % e = setpoint - subT.Tavg(1:idx_settle);
        IAE = nansum(abs(e)) * Ts;
        MSE = nanmean(e.^2);
        RMSE = sqrt(MSE);

        T90 = setpoint * 0.9;
        T10v = setpoint * 0.1;
        idx10 = find(subT.Tavg >= T10v, 1);
        idx90 = find(subT.Tavg >= T90, 1);
        if isempty(idx10) || isempty(idx90)
            t_rise = NaN;
        else
            t_rise = (idx90 - idx10) * Ts;
        end

        Tmax = max(subT.Tavg);
        overshoot = max(0, (Tmax - setpoint) / setpoint * 100);

        if isempty(idx_settle)
            t_settle = NaN;
            energia_Wh = NaN;
            sr_moc_post = NaN;
        else
            t_settle = idx_settle * Ts;
            PWM_rel = abs(subT.PWM(1:idx_settle)) / 255;
            moc = PWM_rel * pelnamoc_W;
            energia_Wh = sum(moc) * Ts / 3600;

            idx_end = n-1;
            if idx_end > idx_settle
                PWM_rel_post = abs(subT.PWM(idx_settle:idx_end)) / 255;
                moc_post = PWM_rel_post * pelnamoc_W;
                sr_moc_post = mean(moc_post);
            else
                sr_moc_post = NaN;
            end
        end

        metryki(:, i) = [IAE; MSE; RMSE; t_rise; overshoot; t_settle; energia_Wh; sr_moc_post];

    catch ME
        warning('Błąd w obliczaniu metryk dla testu %d: %s', test_id, ME.message);
        metryki(:, i) = NaN;
    end
end

 
  
    % Zapis metryk
    metryki(:, i) = [IAE; MSE; RMSE; t_rise; overshoot; t_settle; energia_Wh; sr_moc_post];

    
% === OPISY METRYK ===
metryki_labels = {
    'IAE (suma uchybu bezwzględnego)', 
    'MSE (błąd średniokwadratowy)', 
    'RMSE (pierwiastek z MSE)', 
    'Czas narastania [s]', 
    'Przeregulowanie [%]', 
    'Czas regulacji [s]', 
    'Zużycie energii do regulacji [Wh]', 
    'Średnia moc [W]'};

% === PODZIAŁ NA 2 GRUPY TESTÓW ===
grupa1_idx = testy <= 4 ;
grupa2_idx = testy >= 5;

metryki1 = metryki(:, grupa1_idx);
metryki2 = metryki(:, grupa2_idx);
testy1 = testy(grupa1_idx);
testy2 = testy(grupa2_idx);

generuj_tabele_latex(metryki1, testy1, metryki_labels, 'Porównanie metryk dla testów 0--5');
generuj_tabele_latex(metryki2, testy2, metryki_labels, 'Porównanie metryk dla testów 6--11');
% === FUNKCJA DO GENEROWANIA TABELI LATEX ===
function generuj_tabele_latex(metryki, testy, metryki_labels, opis)
    fprintf('\\begin{table}[H]\n\\centering\n\\caption{%s}\n\\begin{tabular}{|l|%s|}\n', opis, repmat('c|', 1, length(testy)));
    fprintf('\\hline\n\\textbf{Metryka}');
    for i = 1:length(testy)
        fprintf(' & \\textbf{Test %d}', testy(i));
    end
    fprintf(' \\\\\n\\hline\n');

    for r = 1:size(metryki, 1)
        fprintf('%s', metryki_labels{r});
        row = metryki(r, :);
        [~, idx_best] = min(row);
        for c = 1:length(row)
            val = row(c);
            if c == idx_best && ~isnan(val)
                fprintf(' & \\textbf{%.2f}', val);
            else
                fprintf(' & %.2f', val);
            end
        end
        fprintf(' \\\\\n');
    end

    fprintf('\\hline\n\\end{tabular}\n\\end{table}\n\n');
end

% === GENERUJ DWIE TABELKI ===


