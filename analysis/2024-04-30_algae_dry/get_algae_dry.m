close all;
addpath(genpath("..\..\helpers"));


slp = -173501.99879609281; int = 1.3332725199553773E+6;
% % slp = -1.7308e+05; intc = 1.3328e+06;

h2o_ref = 1155034;
d2o_ref = 1146034;

% h2o_cal_factor = 0.568;
% d2o_cal_factor = 0.78130711967174138;

%% Cal data analysis
tab = readtable("A:\thomasu\raw_data\2024-04-29\7um_bead_cal_h2o_media\20240430.152701_mass_results\2024-04-29_7um_bead_cal_h2o_media.csv");
% figure; histogram(tab.mass_pg, 150)
tab_sl = tab(tab.mass_pg > 4.3 & tab.mass_pg < 5, :);
% figure; histogram(tab_sl.avg_pk_ht_hz, 150)
avg_bl = mean(tab_sl.avg_baseline);
adj_ref_h2o = h2o_ref - avg_bl; h2o_dens = (adj_ref_h2o - int) / slp;
freq_mean = mean(tab_sl.avg_pk_ht_hz);
cal_factor = 4/3 * pi * (6.976 / 2)^3 * (1.05 - h2o_dens) / freq_mean;

% calculate h2o cal factor
hz_mean = 8.0616037204846425;
cal_factor_h2o = 4/3 * pi * (6.976 / 2)^3 * (1.05 - h2o_dens) / hz_mean;

%% Analyze data
d2o_paths = ls('data\d2o'); h2o_paths = ls('data\h2o');
labels = ["high" + ["1", "2", "3", "4"], "low" + ["1", "2", "3", "4"]];

h2o_arrs = cell(size(h2o_paths)); h2o_densities = zeros(size(h2o_paths));
for i = 1:length(h2o_paths)
    t = readtable(h2o_paths{i});
    % figure; histogram(t.mass_pg, 150); title(labels(i))
    if i <= 4
        t = t(t.mass_pg < 130 & t.mass_pg > 35, :);
    else
        t = t(t.mass_pg < 130 & t.mass_pg > 35, :);
    end
    % figure; histogram(t.mass_pg, 50); title(labels(i))
    % t.mass_pg = t.avg_pk_ht_hz * cal_factor_h2o;
    h2o_arrs{i} = t;
    h2o_densities(i) = h2o_dens;
end

d2o_arrs = cell(size(h2o_paths)); d2o_densities = zeros(size(h2o_paths));
for i = 1:length(h2o_paths)
    t = readtable(d2o_paths{i});
    figure; histogram(t.mass_pg, 150); title(labels(i))
    if i <= 4
        t = t(t.mass_pg < 130 & t.mass_pg > 30, :);
    else
        t = t(t.mass_pg < 130 & t.mass_pg > 30, :);
    end
    % figure; histogram(t.mass_pg, 50); title(labels(i))
    t.mass_pg = t.avg_pk_ht_hz * cal_factor;
    d2o_arrs{i} = t;
    d2o_densities(i) = ((d2o_ref - mean(t.avg_baseline)) - int) / slp;
end

h2o_bm_arr = zeros(size(d2o_paths)); d2o_bm_arr = zeros(size(d2o_paths));
h2o_dens_arr = zeros(size(d2o_paths)); d2o_dens_arr = zeros(size(d2o_paths));
dry_dens_arr = zeros(size(d2o_paths)); dry_vol_arr = zeros(size(d2o_paths));
for i = 1:length(d2o_paths)
    rho1 = h2o_densities(i); rho2 = d2o_densities(i);
    bm1 = mean(h2o_arrs{i}.mass_pg); bm2 = mean(d2o_arrs{i}.mass_pg);
    disp(labels(i))
    fprintf('    h2o mean: %f pg, d2o mean %f pg\n', bm1, bm2)
    dry_dens = (rho2 * bm1 - rho1 * bm2) / (bm1 - bm2);
    dry_vol = (bm1 - bm2) / (rho2 - rho1);
    fprintf('    dry dens = %.3f g/cm3 | dry vol = %.3f fl\n', dry_dens, dry_vol)

    h2o_bm_arr(i) = bm1; d2o_bm_arr(i) = bm2;
    h2o_dens_arr(i) = rho1; d2o_dens_arr(i) = rho2;
    dry_dens_arr(i) = dry_dens; dry_vol_arr(i) = dry_vol;
end

res_tab = table();
res_tab.label = labels';
res_tab.h2o_buoyant_mass_pg = h2o_bm_arr'; 
res_tab.d2o_buoyant_mass_pg = d2o_bm_arr';
res_tab.h2o_media_density_gcm3 = h2o_dens_arr'; 
res_tab.d2o_media_density_gcm3 = d2o_dens_arr';
res_tab.dry_density = dry_dens_arr';
res_tab.dry_volume = dry_vol_arr';

% writetable(res_tab, 'data\result_table.csv')

