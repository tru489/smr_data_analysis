close all;
addpath(genpath("..\..\helpers"));

%% Load data
h2o_wnkin11_paths = ls("data\h2o_wnkin11");
d2o_wnkin11_paths = ls("data\d2o_wnkin11");
h2o_wnk463_paths = ls("data\h2o_wnk463");
d2o_wnk463_paths = ls("data\d2o_wnk463");
h2o_dmso_paths = ls("data\h2o_dmso");
d2o_dmso_paths = ls("data\d2o_dmso");

h2o_rf = 1158493;
d2o_rf = 1142493;

slope = -174731.71074873616;
intc = 1.3341472962939898E+6;

num_replicates = 3;

%% Thresholding
% plot_pths_for_thresholding(h2o_wnkin11_paths, 'h2o\_wnk')
% plot_pths_for_thresholding(d2o_wnkin11_paths, 'd2o\_wnk')
% plot_pths_for_thresholding(h2o_wnk463_paths, 'h2o\_wnk')
% plot_pths_for_thresholding(d2o_wnk463_paths, 'd2o\_wnk')
% plot_pths_for_thresholding(h2o_dmso_paths, 'h2o\_dmso')
% plot_pths_for_thresholding(d2o_dmso_paths, 'd2o\_dmso')

h2o_wnkin11_thresh = [30 500];
d2o_wnkin11_thresh = [30 350];
h2o_wnk463_thresh = [30 500];
d2o_wnk463_thresh = [30 350];
h2o_dmso_thresh = [30 500];
d2o_dmso_thresh = [30 350];

%% Density baseline calculation
h2o_wnkin11_dens_arr = get_avg_density(h2o_wnkin11_paths, h2o_wnkin11_thresh, slope, intc, h2o_rf);
h2o_wnk463_dens_arr = get_avg_density(h2o_wnk463_paths, h2o_wnk463_thresh, slope, intc, h2o_rf);
h2o_dmso_dens_arr = get_avg_density(h2o_dmso_paths, h2o_dmso_thresh, slope, intc, h2o_rf);

d2o_wnkin11_dens_arr = get_avg_density(d2o_wnkin11_paths, d2o_wnkin11_thresh, slope, intc, d2o_rf);
d2o_wnk463_dens_arr = get_avg_density(d2o_wnk463_paths, d2o_wnk463_thresh, slope, intc, d2o_rf);
d2o_dmso_dens_arr = get_avg_density(d2o_dmso_paths, d2o_dmso_thresh, slope, intc, d2o_rf);

%% Get bms from threshold
h2o_wnkin11_bm = get_mean_bms_and_save(h2o_wnkin11_paths, h2o_wnkin11_thresh, 'results');
h2o_wnk463_bm = get_mean_bms_and_save(h2o_wnk463_paths, h2o_wnk463_thresh, 'results');
h2o_dmso_bm = get_mean_bms_and_save(h2o_dmso_paths, h2o_dmso_thresh, 'results');

d2o_wnkin11_bm = get_mean_bms_and_save(d2o_wnkin11_paths, d2o_wnkin11_thresh, 'results');
d2o_wnk463_bm = get_mean_bms_and_save(d2o_wnk463_paths, d2o_wnk463_thresh, 'results');
d2o_dmso_bm = get_mean_bms_and_save(d2o_dmso_paths, d2o_dmso_thresh, 'results');

%% calculate density and volume
[dens_wnkin11, vol_wnkin11] = calc_dry_dens_vol(h2o_wnkin11_bm, d2o_wnkin11_bm, h2o_wnkin11_dens_arr, d2o_wnkin11_dens_arr);
[dens_wnk463, vol_wnk463] = calc_dry_dens_vol(h2o_wnk463_bm, d2o_wnk463_bm, h2o_wnk463_dens_arr, d2o_wnk463_dens_arr);
[dens_dmso, vol_dmso] = calc_dry_dens_vol(h2o_dmso_bm, d2o_dmso_bm, h2o_dmso_dens_arr, d2o_dmso_dens_arr);

labels = ["Rep" + string(1:num_replicates) + "_wnkin11" "Rep" + string(1:num_replicates) + "_wnk463" "Rep" + string(1:num_replicates) + "_dmso"];
dry_tab = table();
dry_tab.labels = labels';
dry_tab.dry_density_gcm3 = [dens_wnkin11, dens_wnk463, dens_dmso]';
dry_tab.dry_volume_fl = [vol_wnkin11, vol_wnk463, vol_dmso]';
dry_tab.avg_buoyant_mass_h2o = [h2o_wnkin11_bm, h2o_wnk463_bm, h2o_dmso_bm]';
dry_tab.avg_buoyant_mass_d2o = [d2o_wnkin11_bm, d2o_wnk463_bm, d2o_dmso_bm]';
dry_tab.avg_density_h2o_gcm3 = [h2o_wnkin11_dens_arr, h2o_wnk463_dens_arr, h2o_dmso_dens_arr]';
dry_tab.avg_density_d2o_gcm3 = [d2o_wnkin11_dens_arr, d2o_wnk463_dens_arr, d2o_dmso_dens_arr]';
dry_tab.total_volume_fl = [2202.72	2215.57	2163.78	2085.96	2054.34	2063.35	2754.3	2685.03	2677.72]';
dry_tab.water_content = (dry_tab.total_volume_fl - dry_tab.dry_volume_fl) ./ dry_tab.total_volume_fl;
dry_tab.total_density_gcm3 = dry_tab.avg_buoyant_mass_h2o ./ dry_tab.total_volume_fl + dry_tab.avg_density_h2o_gcm3;


% Scaled parameters
dmso_bm_mean = mean(dry_tab.avg_buoyant_mass_h2o(contains(labels,'dmso')));
dmso_bm_samples = dry_tab.avg_buoyant_mass_h2o / dmso_bm_mean;
dry_tab.h2o_bm_dmso_scaled = dmso_bm_samples;

dmso_vol_mean = mean(dry_tab.total_volume_fl(contains(labels,'dmso')));
dmso_vol_samples = dry_tab.total_volume_fl / dmso_vol_mean;
dry_tab.tvol_dmso_scaled = dmso_vol_samples;

dmso_wc_mean = mean(dry_tab.water_content(contains(labels,'dmso')));
dmso_wc_samples = dry_tab.water_content / dmso_wc_mean;
dry_tab.wc_dmso_scaled = dmso_wc_samples;

dmso_tdens_mean = mean(dry_tab.total_density_gcm3(contains(labels,'dmso')));
dmso_tdens_samples = dry_tab.total_density_gcm3 / dmso_tdens_mean;
dry_tab.tdens_dmso_scaled = dmso_tdens_samples;

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
