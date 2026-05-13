close all;
addpath(genpath("..\..\helpers"));

%% Parameters
slope = -174297.37677650762;
intc = 1.3337763674179905E+6;

h2o_rf = 1158624;
d2o_rf = 1142024;

%% Analyze+plot density trapping data
dtrap_tab = readtable('data\peakset_summary_paired.csv');
vol_msk = dtrap_tab.volume_fl > 0 & dtrap_tab.volume_fl < 350;
dens_msk = dtrap_tab.density_gcm3 > 0 & dtrap_tab.density_gcm3 < 1.7;
dtrap_tab = dtrap_tab(vol_msk & dens_msk, :);
writetable(dtrap_tab, 'results\dens_trap_summary.csv')

fh_sc = figure; hold on;
scatter(dtrap_tab.volume_fl, dtrap_tab.density_gcm3)
xlabel('Dry Mass Volume (fL)', FontSize=14); 
ylabel('Dry Mass Density (g/cm^3)', FontSize=14); 
ax=gca; ax.FontSize=12;

%% Analyze+plot pop level data
% H2O
h2o_tab = readtable('data\2024-08-07_fl5+-il3_h2o.csv');
h2o_rf_adj = h2o_rf - h2o_tab.avg_baseline;
h2o_dens = mean((h2o_rf_adj - intc) / slope);

il3_mask = h2o_tab.mass_pg > 26;
strv_mask = h2o_tab.mass_pg > 12 & h2o_tab.mass_pg < 26;
il3_h2o = h2o_tab(il3_mask, :); bm_h2o_il3 = mean(il3_h2o.mass_pg);
strv_h2o = h2o_tab(strv_mask, :); bm_h2o_strv = mean(strv_h2o.mass_pg);

% D2O
d2o_tab = readtable('data\2024-08-07_fl5+-il3_d2o.csv');
d2o_rf_adj = d2o_rf - d2o_tab.avg_baseline;
d2o_dens = mean((d2o_rf_adj - intc) / slope);

il3_mask = d2o_tab.mass_pg > 20;
strv_mask = d2o_tab.mass_pg > 6 & d2o_tab.mass_pg < 20;
il3_d2o = d2o_tab(il3_mask, :); bm_d2o_il3 = mean(il3_d2o.mass_pg);
strv_d2o = d2o_tab(strv_mask, :); bm_d2o_strv = mean(strv_d2o.mass_pg);

figure; histogram(h2o_tab.mass_pg, 120)
figure; histogram(d2o_tab.mass_pg, 120)

% Calculate dry density and volume GTs
[dens_il3, vol_il3] = calc_dry_dens_vol(bm_h2o_il3, bm_d2o_il3, h2o_dens, d2o_dens);
[dens_strv, vol_strv] = calc_dry_dens_vol(bm_h2o_strv, bm_d2o_strv, h2o_dens, d2o_dens);

fprintf('+il3 density: %.3f | +il3 volume: %.3f\n', dens_il3, vol_il3)
fprintf('-il3 density: %.3f | -il3 volume: %.3f\n\n', dens_strv, vol_strv)

figure(fh_sc)
scatter([vol_il3, vol_strv], [dens_il3, dens_strv], 70, 'r', '+', LineWidth=3)

%% Population level water content
il3_tot_vol = 1061;
strv_tot_vol = 316.2;

fprintf('Pop WC for +il3: %.4f | Pop WC for -il3: %.4f\n', (il3_tot_vol - vol_il3) / il3_tot_vol, (strv_tot_vol - vol_strv) / strv_tot_vol)

%% Functions
function [dens, vol] = calc_dry_dens_vol(bm_h2o, bm_d2o, dens_h2o, dens_d2o)

dens = (dens_d2o.*bm_h2o - dens_h2o.*bm_d2o) ./ (bm_h2o - bm_d2o);
vol = (bm_h2o - bm_d2o) ./ (dens_d2o - dens_h2o);

end
