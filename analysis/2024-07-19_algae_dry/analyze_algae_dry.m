close all;
addpath(genpath("..\..\helpers"));

%% Get paths
h2o_low_paths = ls("data\h2o_low");
h2o_high_paths = ls("data\h2o_high");

d2o_low_paths = ls("data\d2o_low");
d2o_high_paths = ls("data\d2o_high");

p_h2o_paths = ls("data\-p_h2o");
p_d2o_paths = ls("data\-p_d2o");

n_h2o_paths = ls("data\-n_h2o");
n_d2o_paths = ls("data\-n_d2o");

%% Set calibration params
h2o_rf = 1155524;
d2o_rf = 1137524;

slope = -174297.37677650762;
intc = 1.3337763674179905E+6;

num_replicates = 2;

% plot_pths_for_thresholding(h2o_low_paths, 'h2o\_low')
% plot_pths_for_thresholding(h2o_high_paths, 'h2o\_high')

% plot_pths_for_thresholding(d2o_low_paths, 'd2o\_low')
% plot_pths_for_thresholding(d2o_high_paths, 'd2o\_high')

% plot_pths_for_thresholding(p_h2o_paths, '-p\_h2o')
% plot_pths_for_thresholding(p_d2o_paths, '-p\_d2o')

% plot_pths_for_thresholding(n_h2o_paths, '-n\_h2o')
% plot_pths_for_thresholding(n_d2o_paths, '-n\_d2o')

%% Set thresholds
h2o_low_thresh = [20 inf];
h2o_high_thresh = [20 inf];
fprintf('%s thresholding: low threshold = %.1f pg\n', 'Low sample (h2o)', h2o_low_thresh(1))
fprintf('%s thresholding: low threshold = %.1f pg\n', 'High sample (h2o)', h2o_high_thresh(1))

d2o_low_thresh = [20 inf];
d2o_high_thresh = [20 inf];
fprintf('%s thresholding: low threshold = %.1f pg\n', 'Low sample (d2o)', d2o_low_thresh(1))
fprintf('%s thresholding: low threshold = %.1f pg\n', 'High sample (d2o)', d2o_high_thresh(1))

p_h2o_thresh = [20 inf];
p_d2o_thresh = [20 inf];
fprintf('%s thresholding: low threshold = %.1f pg\n', '-p sample (h2o)', p_h2o_thresh(1))
fprintf('%s thresholding: low threshold = %.1f pg\n', '-p sample (d2o)', p_d2o_thresh(1))

n_h2o_thresh = [20 inf];
n_d2o_thresh = [20 inf];
fprintf('%s thresholding: low threshold = %.1f pg\n', '-n sample (h2o)', n_h2o_thresh(1))
fprintf('%s thresholding: low threshold = %.1f pg\n', '-n sample (d2o)', n_d2o_thresh(1))

%% Get densities
low_h2o_dens_arr = get_avg_density(h2o_low_paths, h2o_low_thresh, slope, intc, h2o_rf);
high_h2o_dens_arr = get_avg_density(h2o_high_paths, h2o_high_thresh, slope, intc, h2o_rf);
p_h2o_dens_arr = get_avg_density(p_h2o_paths, p_h2o_thresh, slope, intc, h2o_rf);
n_h2o_dens_arr = get_avg_density(n_h2o_paths, n_h2o_thresh, slope, intc, h2o_rf);
h2o_dens = mean([low_h2o_dens_arr, high_h2o_dens_arr, p_h2o_dens_arr, n_h2o_dens_arr]);

low_d2o_dens_arr = get_avg_density(d2o_low_paths, d2o_low_thresh, slope, intc, d2o_rf);
high_d2o_dens_arr = get_avg_density(d2o_high_paths, d2o_high_thresh, slope, intc, d2o_rf);
p_d2o_dens_arr = get_avg_density(p_d2o_paths, p_d2o_thresh, slope, intc, d2o_rf);
n_d2o_dens_arr = get_avg_density(n_d2o_paths, n_d2o_thresh, slope, intc, d2o_rf);
d2o_dens = mean([low_d2o_dens_arr, high_d2o_dens_arr, p_d2o_dens_arr, n_d2o_dens_arr]);
fprintf('h2o density: %.4f| d2o density: %.4f\n', h2o_dens, d2o_dens)

%% Slice BMs
h2o_low_bm = get_mean_bms_and_save(h2o_low_paths, h2o_low_thresh, 'results');
h2o_high_bm = get_mean_bms_and_save(h2o_high_paths, h2o_high_thresh, 'results');
d2o_low_bm = get_mean_bms_and_save(d2o_low_paths, d2o_low_thresh, 'results');
d2o_high_bm = get_mean_bms_and_save(d2o_high_paths, d2o_high_thresh, 'results');

h2o_p_bm = get_mean_bms_and_save(p_h2o_paths, p_h2o_thresh, 'results');
h2o_n_bm = get_mean_bms_and_save(n_h2o_paths, n_h2o_thresh, 'results');
d2o_p_bm = get_mean_bms_and_save(p_d2o_paths, p_d2o_thresh, 'results');
d2o_n_bm = get_mean_bms_and_save(n_d2o_paths, n_d2o_thresh, 'results');

%% Calculate density and volume
[dens_low, vol_low] = calc_dry_dens_vol(h2o_low_bm, d2o_low_bm, h2o_dens, d2o_dens);
[dens_high, vol_high] = calc_dry_dens_vol(h2o_high_bm, d2o_high_bm, h2o_dens, d2o_dens);
[dens_p, vol_p] = calc_dry_dens_vol(h2o_p_bm, d2o_p_bm, h2o_dens, d2o_dens);
[dens_n, vol_n] = calc_dry_dens_vol(h2o_n_bm, d2o_n_bm, h2o_dens, d2o_dens);

labels = ["Rep" + string(1:num_replicates) + "_low" "Rep" + string(1:num_replicates) + "_high" "Rep" + string(1:num_replicates) + "-p" "Rep" + string(1:num_replicates) + "_-n"];
dry_tab = table();
dry_tab.labels = labels';
dry_tab.dry_density_gcm3 = [dens_low, dens_high, dens_p, dens_n]';
dry_tab.dry_volume_fl = [vol_low, vol_high, vol_p, vol_n]';
dry_tab.avg_buoyant_mass_h2o = [h2o_low_bm, h2o_high_bm, h2o_p_bm, h2o_n_bm]';
dry_tab.avg_buoyant_mass_d2o = [d2o_low_bm, d2o_high_bm, d2o_p_bm, d2o_n_bm]';
dry_tab.avg_density_h2o_gcm3 = repmat(h2o_dens, 1, num_replicates*4)';
dry_tab.avg_density_d2o_gcm3 = repmat(d2o_dens, 1, num_replicates*4)';
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
