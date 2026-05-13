close all;
addpath(genpath("..\..\helpers"));

num_reps = 2;

h2o_low_paths = ls("data\h2o_low");
h2o_high_paths = ls("data\h2o_high");
h2o_n_paths = ls("data\h2o_-n");
% h2o_p_paths = ls("data\1870_-p_h2o");

d2o_low_paths = ls("data\d2o_low");
d2o_high_paths = ls("data\d2o_high");
d2o_n_paths = ls("data\d2o_-n");
% d2o_p_paths = ls("data\1870_-p_d2o");

h2o_rf = 1155193;
d2o_rf = 1137193;

slope = -174731.71074873616;
intc = 1.3341472962939898E+6;

% plot_pths_for_thresholding(h2o_low_paths, 'h2o\_low')
% plot_pths_for_thresholding(h2o_high_paths, 'h2o\_high')
% plot_pths_for_thresholding(h2o_n_paths, 'h2o\_n')

% plot_pths_for_thresholding(d2o_low_paths, 'd2o\_low')
% plot_pths_for_thresholding(d2o_high_paths, 'd2o\_high')
% plot_pths_for_thresholding(d2o_n_paths, 'd2o\_n')


h2o_low_thresh = [20 inf];
h2o_high_thresh = [5 50];
h2o_n_thresh = [20 inf];
% h2o_p_thresh = [10 inf];

d2o_low_thresh = [10 inf];
d2o_high_thresh = [4 50];
d2o_n_thresh = [12 inf];
% d2o_p_thresh = [6 inf];

low_h2o_dens_arr = get_avg_density(h2o_low_paths, h2o_low_thresh, slope, intc, h2o_rf);
high_h2o_dens_arr = get_avg_density(h2o_high_paths, h2o_high_thresh, slope, intc, h2o_rf);
n_h2o_dens_arr = get_avg_density(h2o_n_paths, h2o_n_thresh, slope, intc, h2o_rf);
% p_h2o_dens_arr = get_avg_density(h2o_p_paths, h2o_p_thresh, slope, intc, h2o_rf);
h2o_dens = mean([low_h2o_dens_arr, high_h2o_dens_arr, n_h2o_dens_arr]);

low_d2o_dens_arr = get_avg_density(d2o_low_paths, d2o_low_thresh, slope, intc, d2o_rf);
high_d2o_dens_arr = get_avg_density(d2o_high_paths, d2o_high_thresh, slope, intc, d2o_rf);
n_d2o_dens_arr = get_avg_density(d2o_n_paths, d2o_n_thresh, slope, intc, h2o_rf);
% p_d2o_dens_arr = get_avg_density(d2o_p_paths, d2o_p_thresh, slope, intc, h2o_rf);
d2o_dens = mean([low_d2o_dens_arr, high_d2o_dens_arr, n_d2o_dens_arr]);

h2o_low_bm = get_mean_bms_and_save(h2o_low_paths, h2o_low_thresh, 'results');
h2o_high_bm = get_mean_bms_and_save(h2o_high_paths, h2o_high_thresh, 'results');
h2o_n_bm = get_mean_bms_and_save(h2o_n_paths, h2o_n_thresh, 'results');
% h2o_p_bm = get_mean_bms_and_save(h2o_p_paths, h2o_p_thresh, 'results');
d2o_low_bm = get_mean_bms_and_save(d2o_low_paths, d2o_low_thresh, 'results');
d2o_high_bm = get_mean_bms_and_save(d2o_high_paths, d2o_high_thresh, 'results');
d2o_n_bm = get_mean_bms_and_save(d2o_n_paths, d2o_n_thresh, 'results');
% d2o_p_bm = get_mean_bms_and_save(d2o_p_paths, d2o_p_thresh, 'results');

[dens_low, vol_low] = calc_dry_dens_vol(h2o_low_bm, d2o_low_bm, h2o_dens, d2o_dens);
[dens_high, vol_high] = calc_dry_dens_vol(h2o_high_bm, d2o_high_bm, h2o_dens, d2o_dens);
[dens_n, vol_n] = calc_dry_dens_vol(h2o_n_bm, d2o_n_bm, h2o_dens, d2o_dens);
% [dens_p, vol_p] = calc_dry_dens_vol(h2o_p_bm, d2o_p_bm, h2o_dens, d2o_dens);

labels = ["Rep" + string(1:num_reps) + "_low" "Rep" + string(1:num_reps) + "_high" "Rep" + string(1:num_reps) + "_-n"];
dry_tab = table();
dry_tab.labels = labels';
dry_tab.dry_density_gcm3 = [dens_low, dens_high, dens_n]';
dry_tab.dry_volume_fl = [vol_low, vol_high, vol_n]';
dry_tab.avg_buoyant_mass_h2o = [h2o_low_bm, h2o_high_bm, h2o_n_bm]';
dry_tab.avg_buoyant_mass_d2o = [d2o_low_bm, d2o_high_bm, d2o_n_bm]';
dry_tab.avg_density_h2o_gcm3 = repmat(h2o_dens, 1, num_reps*3)';
dry_tab.avg_density_d2o_gcm3 = repmat(d2o_dens, 1, num_reps*3)';
writetable(dry_tab, 'results\dry_properties.csv')

%% Helpers
function plot_pths_for_thresholding(pths, title_)

for i = 1:length(pths)
    tab_t = readtable(pths{i});
    figure; histogram(tab_t.mass_pg, 200)
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
