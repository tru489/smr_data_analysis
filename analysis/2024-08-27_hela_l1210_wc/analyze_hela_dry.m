close all;
addpath(genpath("..\..\helpers"));

%% Load data
h2o_nvp_paths = ls("hela_data\h2o_nvp");
d2o_nvp_paths = ls("hela_data\d2o_nvp");
h2o_dmso_paths = ls("hela_data\h2o_dmso");
d2o_dmso_paths = ls("hela_data\d2o_dmso");

h2o_rf = 1158224;
d2o_rf = 1143224;

slope = -174297.37677650762;
intc = 1.3337763674179905E+6;

num_replicates = 3;

%% Thresholding
% plot_pths_for_thresholding(h2o_nvp_paths, 'h2o\_nvp')
% plot_pths_for_thresholding(d2o_nvp_paths, 'd2o\_nvp')
% plot_pths_for_thresholding(h2o_dmso_paths, 'h2o\_dmso')
% plot_pths_for_thresholding(d2o_dmso_paths, 'd2o\_dmso')

h2o_nvp_thresh = [35 500];
d2o_nvp_thresh = [20 400];
h2o_dmso_thresh = [35 500];
d2o_dmso_thresh = [20 400];

%% Density baseline calculation
h2o_trm_dens_arr = get_avg_density(h2o_nvp_paths, h2o_nvp_thresh, slope, intc, h2o_rf);
h2o_dmso_dens_arr = get_avg_density(h2o_dmso_paths, h2o_dmso_thresh, slope, intc, h2o_rf);
h2o_dens = mean([h2o_gsk_dens_arr, h2o_trm_dens_arr, h2o_dmso_dens_arr]);

d2o_trm_dens_arr = get_avg_density(d2o_nvp_paths, d2o_nvp_thresh, slope, intc, d2o_rf);
d2o_dmso_dens_arr = get_avg_density(d2o_dmso_paths, d2o_dmso_thresh, slope, intc, d2o_rf);
d2o_dens = mean([d2o_gsk_dens_arr, d2o_trm_dens_arr, d2o_dmso_dens_arr]);

%% Get bms from threshold
h2o_nvp_bm = get_mean_bms_and_save(h2o_nvp_paths, h2o_nvp_thresh, 'hela_results');
h2o_dmso_bm = get_mean_bms_and_save(h2o_dmso_paths, h2o_dmso_thresh, 'hela_results');

d2o_nvp_bm = get_mean_bms_and_save(d2o_nvp_paths, d2o_nvp_thresh, 'hela_results');
d2o_dmso_bm = get_mean_bms_and_save(d2o_dmso_paths, d2o_dmso_thresh, 'hela_results');

%% calculate density and volume
[dens_nvp, vol_nvp] = calc_dry_dens_vol(h2o_nvp_bm, d2o_nvp_bm, h2o_trm_dens_arr, d2o_trm_dens_arr);
[dens_dmso, vol_dmso] = calc_dry_dens_vol(h2o_dmso_bm, d2o_dmso_bm, h2o_dmso_dens_arr, d2o_dmso_dens_arr);

labels = ["Rep" + string(1:num_replicates) + "_nvp" "Rep" + string(1:num_replicates) + "_dmso"];
dry_tab = table();
dry_tab.labels = labels';
dry_tab.dry_density_gcm3 = [dens_nvp, dens_dmso]';
dry_tab.dry_volume_fl = [vol_nvp, vol_dmso]';
dry_tab.avg_buoyant_mass_h2o = [h2o_nvp_bm, h2o_dmso_bm]';
dry_tab.avg_buoyant_mass_d2o = [d2o_nvp_bm, d2o_dmso_bm]';
dry_tab.avg_density_h2o_gcm3 = [h2o_trm_dens_arr, h2o_dmso_dens_arr]';
dry_tab.avg_density_d2o_gcm3 = [d2o_trm_dens_arr, d2o_dmso_dens_arr]';
dry_tab.total_volume_fl = [2367, 2256, 2320, 3037, 3048, 3092]';
dry_tab.water_content = (dry_tab.total_volume_fl - dry_tab.dry_volume_fl) ./ dry_tab.total_volume_fl;

writetable(dry_tab, 'hela_results\dry_properties.csv')

%%
function plot_pths_for_thresholding(pths, title_)

for i = 1:length(pths)
    tab_t = readtable(pths{i});
    figure; histogram(tab_t.mass_pg, 150)
    title(title_)
end

end

function dens_arr = get_avg_density(pths, thresh, slope, intc, rf)

ref_freqs = zeros(size(pths));
for i = 1:length(pths)
    tab_t = readtable(pths{i});
    tab_t = tab_t(tab_t.mass_pg > thresh(1) & tab_t.mass_pg < thresh(2), :);
    ref_freqs(i) = rf + mean(tab_t.avg_baseline);
end

dens_arr = (ref_freqs - intc) / slope;

end

function bms = get_mean_bms_and_save(pths, thresh, save_dir)

bms = zeros(size(pths));
for i = 1:length(pths)
    tab_t = readtable(pths{i});
    tab_t = tab_t(tab_t.mass_pg > thresh(1) & tab_t.mass_pg < thresh(2), :);
    bms(i) = mean(tab_t.mass_pg);
    
    [~, fname, ext] = fileparts(pths{i});
    writetable(tab_t, fullfile(save_dir, [fname, ext]))
end

end

function [dens, vol] = calc_dry_dens_vol(bm_h2o, bm_d2o, dens_h2o, dens_d2o)

dens = (dens_d2o.*bm_h2o - dens_h2o.*bm_d2o) ./ (bm_h2o - bm_d2o);
vol = (bm_h2o - bm_d2o) ./ (dens_d2o - dens_h2o);

end
