close all;
addpath(genpath("..\..\helpers"));

%% Load data
h2o_wnk_paths = ls("data\h2o_wnk");
d2o_wnk_paths = ls("data\d2o_wnk");
h2o_dmso_paths = ls("data\h2o_dmso");
d2o_dmso_paths = ls("data\d2o_dmso");

h2o_rf = 1158024;
d2o_rf = 1142024;

slope = -174312.26307490587;
intc = 1.3335929208278775E+6;

num_replicates = 3;

%% Thresholding
% plot_pths_for_thresholding(h2o_wnk_paths, 'h2o\_wnk')
% plot_pths_for_thresholding(d2o_wnk_paths, 'd2o\_wnk')
% plot_pths_for_thresholding(h2o_dmso_paths, 'h2o\_dmso')
plot_pths_for_thresholding(d2o_dmso_paths, 'd2o\_dmso')

h2o_wnk_thresh = [20 200];
d2o_wnk_thresh = [15 120];
h2o_dmso_thresh = [20 200];
d2o_dmso_thresh = [15 120];

%% Density baseline calculation
h2o_wnk_dens_arr = get_avg_density(h2o_wnk_paths, h2o_wnk_thresh, slope, intc, h2o_rf);
h2o_dmso_dens_arr = get_avg_density(h2o_dmso_paths, h2o_dmso_thresh, slope, intc, h2o_rf);

d2o_wnk_dens_arr = get_avg_density(d2o_wnk_paths, d2o_wnk_thresh, slope, intc, d2o_rf);
d2o_dmso_dens_arr = get_avg_density(d2o_dmso_paths, d2o_dmso_thresh, slope, intc, d2o_rf);

%% Get bms from threshold
h2o_wnk_bm = get_mean_bms_and_save(h2o_wnk_paths, h2o_wnk_thresh, 'results');
h2o_dmso_bm = get_mean_bms_and_save(h2o_dmso_paths, h2o_dmso_thresh, 'results');

d2o_wnk_bm = get_mean_bms_and_save(d2o_wnk_paths, d2o_wnk_thresh, 'results');
d2o_dmso_bm = get_mean_bms_and_save(d2o_dmso_paths, d2o_dmso_thresh, 'results');

%% calculate density and volume
[dens_wnk, vol_wnk] = calc_dry_dens_vol(h2o_wnk_bm, d2o_wnk_bm, h2o_wnk_dens_arr, d2o_wnk_dens_arr);
[dens_dmso, vol_dmso] = calc_dry_dens_vol(h2o_dmso_bm, d2o_dmso_bm, h2o_dmso_dens_arr, d2o_dmso_dens_arr);

labels = ["Rep" + string(1:num_replicates) + "_wnk" "Rep" + string(1:num_replicates) + "_dmso"];
dry_tab = table();
dry_tab.labels = labels';
dry_tab.dry_density_gcm3 = [dens_wnk, dens_dmso]';
dry_tab.dry_volume_fl = [vol_wnk, vol_dmso]';
dry_tab.avg_buoyant_mass_h2o = [h2o_wnk_bm, h2o_dmso_bm]';
dry_tab.avg_buoyant_mass_d2o = [d2o_wnk_bm, d2o_dmso_bm]';
dry_tab.avg_density_h2o_gcm3 = [h2o_wnk_dens_arr, h2o_dmso_dens_arr]';
dry_tab.avg_density_d2o_gcm3 = [d2o_wnk_dens_arr, d2o_dmso_dens_arr]';
dry_tab.total_volume_fl = [732.3, 732.7, 760.7, 908.3, 884.35, 909]';
dry_tab.water_content = (dry_tab.total_volume_fl - dry_tab.dry_volume_fl) ./ dry_tab.total_volume_fl;
dry_tab.total_density_gcm3 = dry_tab.avg_buoyant_mass_h2o ./ dry_tab.total_volume_fl + dry_tab.avg_density_h2o_gcm3;

writetable(dry_tab, 'results\dry_properties.csv')

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
    ref_freqs(i) = rf - mean(tab_t.avg_baseline);
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
