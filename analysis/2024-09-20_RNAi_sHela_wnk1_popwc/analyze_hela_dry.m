close all;
addpath(genpath("..\..\helpers"));

%% Load data
h2o_ntarget_paths = ls("data\h2o_ntarget");
d2o_ntarget_paths = ls("data\d2o_ntarget");
h2o_ntreat_paths = ls("data\h2o_ntreat");
d2o_ntreat_paths = ls("data\d2o_ntreat");
h2o_siRNA1_paths = ls("data\h2o_siRNA1");
d2o_siRNA1_paths = ls("data\d2o_siRNA1");
h2o_siRNA2_paths = ls("data\h2o_siRNA2");
d2o_siRNA2_paths = ls("data\d2o_siRNA2");

h2o_rf = 1158424;
d2o_rf = 1142424;

slope = -174312.26307490587;
intc = 1.3335929208278775E+6;

num_replicates = 2;

%% Thresholding
% plot_pths_for_thresholding(h2o_ntarget_paths, 'h2o\_ntarget')
% plot_pths_for_thresholding(d2o_ntarget_paths, 'd2o\_ntarget')
% plot_pths_for_thresholding(h2o_ntreat_paths, 'h2o\_ntreat')
% plot_pths_for_thresholding(d2o_ntreat_paths, 'd2o\_ntreat')
% plot_pths_for_thresholding(h2o_siRNA1_paths, 'h2o\_siRNA1')
% plot_pths_for_thresholding(d2o_siRNA1_paths, 'd2o\_siRNA1')
% plot_pths_for_thresholding(h2o_siRNA2_paths, 'h2o\_siRNA2')
% plot_pths_for_thresholding(d2o_siRNA2_paths, 'd2o\_siRNA2')

h2o_ntarget_thresh = [30 600];
d2o_ntarget_thresh = [30 600];
h2o_ntreat_thresh = [30 600];
d2o_ntreat_thresh = [30 600];
h2o_siRNA1_thresh = [30 600];
d2o_siRNA1_thresh = [30 600];
h2o_siRNA2_thresh = [30 600];
d2o_siRNA2_thresh = [30 600];

%% Density baseline calculation
h2o_ntarget_dens_arr = get_avg_density(h2o_ntarget_paths, h2o_ntarget_thresh, slope, intc, h2o_rf);
h2o_ntreat_dens_arr = get_avg_density(h2o_ntreat_paths, h2o_ntreat_thresh, slope, intc, h2o_rf);
h2o_siRNA1_dens_arr = get_avg_density(h2o_siRNA1_paths, h2o_siRNA1_thresh, slope, intc, h2o_rf);
h2o_siRNA2_dens_arr = get_avg_density(h2o_siRNA2_paths, h2o_siRNA2_thresh, slope, intc, h2o_rf);

d2o_ntarget_dens_arr = get_avg_density(d2o_ntarget_paths, d2o_ntarget_thresh, slope, intc, d2o_rf);
d2o_ntreat_dens_arr = get_avg_density(d2o_ntreat_paths, d2o_ntreat_thresh, slope, intc, d2o_rf);
d2o_siRNA1_dens_arr = get_avg_density(d2o_siRNA1_paths, d2o_siRNA1_thresh, slope, intc, d2o_rf);
d2o_siRNA2_dens_arr = get_avg_density(d2o_siRNA2_paths, d2o_siRNA2_thresh, slope, intc, d2o_rf);

%% Get bms from threshold
h2o_ntarget_bm = get_mean_bms_and_save(h2o_ntarget_paths, h2o_ntarget_thresh, 'results');
h2o_ntreat_bm = get_mean_bms_and_save(h2o_ntreat_paths, h2o_ntreat_thresh, 'results');
h2o_siRNA1_bm = get_mean_bms_and_save(h2o_siRNA1_paths, h2o_siRNA1_thresh, 'results');
h2o_siRNA2_bm = get_mean_bms_and_save(h2o_siRNA2_paths, h2o_siRNA2_thresh, 'results');

d2o_ntarget_bm = get_mean_bms_and_save(d2o_ntarget_paths, d2o_ntarget_thresh, 'results');
d2o_ntreat_bm = get_mean_bms_and_save(d2o_ntreat_paths, d2o_ntreat_thresh, 'results');
d2o_siRNA1_bm = get_mean_bms_and_save(d2o_siRNA1_paths, d2o_siRNA1_thresh, 'results');
d2o_siRNA2_bm = get_mean_bms_and_save(d2o_siRNA2_paths, d2o_siRNA2_thresh, 'results');

%% calculate density and volume
[dens_ntarget, vol_ntarget] = calc_dry_dens_vol(h2o_ntarget_bm, d2o_ntarget_bm, h2o_ntarget_dens_arr, d2o_ntarget_dens_arr);
[dens_ntreat, vol_ntreat] = calc_dry_dens_vol(h2o_ntreat_bm, d2o_ntreat_bm, h2o_ntreat_dens_arr, d2o_ntreat_dens_arr);
[dens_siRNA1, vol_siRNA1] = calc_dry_dens_vol(h2o_siRNA1_bm, d2o_siRNA1_bm, h2o_siRNA1_dens_arr, d2o_siRNA1_dens_arr);
[dens_siRNA2, vol_siRNA2] = calc_dry_dens_vol(h2o_siRNA2_bm, d2o_siRNA2_bm, h2o_siRNA2_dens_arr, d2o_siRNA2_dens_arr);

labels = ["Rep" + string(1:num_replicates) + "_ntarget" "Rep" + string(1:num_replicates) + "_ntreat" "Rep" + string(1:num_replicates) + "_siRNA1" "Rep" + string(1:num_replicates) + "_siRNA2"];
dry_tab = table();
dry_tab.labels = labels';
dry_tab.dry_density_gcm3 = [dens_ntarget, dens_ntreat, dens_siRNA1, dens_siRNA2]';
dry_tab.dry_volume_fl = [vol_ntarget, vol_ntreat, vol_siRNA1, vol_siRNA2]';
dry_tab.avg_buoyant_mass_h2o = [h2o_ntarget_bm, h2o_ntreat_bm, h2o_siRNA1_bm, h2o_siRNA2_bm]';
dry_tab.avg_buoyant_mass_d2o = [d2o_ntarget_bm, d2o_ntreat_bm, d2o_siRNA1_bm, d2o_siRNA2_bm]';
dry_tab.avg_density_h2o_gcm3 = [h2o_ntarget_dens_arr, h2o_ntreat_dens_arr, h2o_siRNA1_dens_arr, h2o_siRNA2_dens_arr]';
dry_tab.avg_density_d2o_gcm3 = [d2o_ntarget_dens_arr, d2o_ntreat_dens_arr, d2o_siRNA1_dens_arr, d2o_siRNA2_dens_arr]';
dry_tab.total_volume_fl = [2739.35	2666.97		2904.34	2736.64		2671.92	2560.7		2651.44	2552.86	]';
dry_tab.water_content = (dry_tab.total_volume_fl - dry_tab.dry_volume_fl) ./ dry_tab.total_volume_fl;
dry_tab.total_density = dry_tab.avg_buoyant_mass_h2o ./ dry_tab.total_volume_fl + dry_tab.avg_density_h2o_gcm3;

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
