close all;
addpath(genpath("..\..\helpers"));

%% Load data
day0_paths = ls("data\day0");
day1_paths = ls("data\day1");
day2_paths = ls("data\day2");

h2o_rf_d0 = 1158424;
h2o_rf_d1 = 1158024;
h2o_rf_d2 = 1158424;

slope = -174312.26307490587;
intc = 1.3335929208278775E+6;

%% Thresholding
% plot_pths_for_thresholding(day0_paths, 'day0')
% plot_pths_for_thresholding(day1_paths, 'day1')
% plot_pths_for_thresholding(day2_paths, 'day2')

day0_thresh = [7,20;7,20;7,20];
day1_thresh = [0,60;0,60;0,60;...
    0,30;0,30;0,30];
day2_thresh = [0,40;0,40;0,40;...
    0,60;0,60;0,60;...
    0,120;0,120;0,120];

%% Density baseline calculation
day0_dens_arr = get_avg_density(day0_paths, day0_thresh, slope, intc, h2o_rf_d0);
day1_dens_arr = get_avg_density(day1_paths, day1_thresh, slope, intc, h2o_rf_d1);
day2_dens_arr = get_avg_density(day2_paths, day2_thresh, slope, intc, h2o_rf_d2);

%% Get bms from threshold
day0_bm = get_mean_bms_and_save(day0_paths, day0_thresh, 'results\day0');
day1_bm = get_mean_bms_and_save(day1_paths, day1_thresh, 'results\day1');
day2_bm = get_mean_bms_and_save(day2_paths, day2_thresh, 'results\day2');

%% calculate density and volume

labels = [string(day0_paths) string(day1_paths) string(day2_paths)];
dry_tab = table();
dry_tab.labels = labels';
dry_tab.avg_buoyant_mass_h2o = [day0_bm, day1_bm, day2_bm]';
dry_tab.avg_density_h2o_gcm3 = [day0_dens_arr, day1_dens_arr, day2_dens_arr]';
dry_tab.total_volume_fl = [101.397	101.397	96.0166	238.68	269.265	119.3	113.079	85.4521	85.6945	87.8559	92.1447	100.497	175.052	203.727	122.926	442.753	424.695	464.131  ]';
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
    tab_t = tab_t(tab_t.mass_pg > thresh(i,1) & tab_t.mass_pg < thresh(i,2), :);
    ref_freqs(i) = rf - mean(tab_t.avg_baseline);
end

dens_arr = (ref_freqs - intc) / slope;

end

function bms = get_mean_bms_and_save(pths, thresh, save_dir)

bms = zeros(size(pths));
for i = 1:length(pths)
    tab_t = readtable(pths{i});
    tab_t = tab_t(tab_t.mass_pg > thresh(i,1) & tab_t.mass_pg < thresh(i,2), :);
    bms(i) = mean(tab_t.mass_pg);
    
    [~, fname, ext] = fileparts(pths{i});
    writetable(tab_t, fullfile(save_dir, [fname, ext]))
end

end
