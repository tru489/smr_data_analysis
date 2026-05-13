close all;
addpath(genpath("..\..\helpers"));

h2o_low_paths = ls("data\h2o_low");
h2o_high_paths = ls("data\h2o_high");
d2o_low_paths = ls("data\d2o_low");
d2o_high_paths = ls("data\d2o_high");

h2o_rf = 1155224;
d2o_rf = 1137224;

slope = -173501.99879609281;
intc = 1.3332725199553773E+6;

num_replicates = 3;

% plot_pths_for_thresholding(h2o_low_paths, 'h2o\_low')
% plot_pths_for_thresholding(h2o_high_paths, 'h2o\_high')
% plot_pths_for_thresholding(d2o_low_paths, 'd2o\_low')
% plot_pths_for_thresholding(d2o_high_paths, 'd2o\_high')

h2o_thresh = 8;
d2o_thresh = 4;

h2o_dens = get_avg_density([h2o_low_paths, h2o_high_paths], h2o_thresh, slope, intc, h2o_rf);
d2o_dens = get_avg_density([d2o_low_paths, d2o_high_paths], d2o_thresh, slope, intc, d2o_rf);

h2o_low_bm = get_mean_bms_and_save(h2o_low_paths, h2o_thresh, 'results');
h2o_high_bm = get_mean_bms_and_save(h2o_high_paths, h2o_thresh, 'results');
d2o_low_bm = get_mean_bms_and_save(d2o_low_paths, d2o_thresh, 'results');
d2o_high_bm = get_mean_bms_and_save(d2o_high_paths, d2o_thresh, 'results');

[dens_low, vol_low] = calc_dry_dens_vol(h2o_low_bm, d2o_low_bm, h2o_dens, d2o_dens);
[dens_high, vol_high] = calc_dry_dens_vol(h2o_high_bm, d2o_high_bm, h2o_dens, d2o_dens);

labels = ["Rep" + string([1 2 3]) + "_low" "Rep" + string([1 2 3]) + "_high"];
dry_tab = table();
dry_tab.labels = labels';
dry_tab.dry_density_gcm3 = [dens_low, dens_high]';
dry_tab.dry_volume_fl = [vol_low, vol_high]';
dry_tab.avg_buoyant_mass_h2o = [h2o_low_bm, h2o_high_bm]';
dry_tab.avg_buoyant_mass_d2o = [d2o_low_bm, d2o_high_bm]';
dry_tab.avg_density_h2o_gcm3 = repmat(h2o_dens, 1, num_replicates*2)';
dry_tab.avg_density_d2o_gcm3 = repmat(d2o_dens, 1, num_replicates*2)';
writetable(dry_tab, 'results\dry_properties.csv')

%%
function plot_pths_for_thresholding(pths, title_)

for i = 1:length(pths)
    tab_t = readtable(pths{i});
    figure; histogram(tab_t.mass_pg, 150)
    title(title_)
end

end

function dens = get_avg_density(pths, thresh, slope, intc, rf)

ref_freqs = zeros(size(pths));
for i = 1:length(pths)
    tab_t = readtable(pths{i});
    tab_t = tab_t(tab_t.mass_pg > thresh, :);
    ref_freqs(i) = rf + mean(tab_t.avg_baseline);
end

dens = (mean(ref_freqs) - intc) / slope;

end

function bms = get_mean_bms_and_save(pths, thresh, save_dir)

bms = zeros(size(pths));
for i = 1:length(pths)
    tab_t = readtable(pths{i});
    tab_t = tab_t(tab_t.mass_pg > thresh, :);
    bms(i) = mean(tab_t.mass_pg);
    
    [~, fname, ext] = fileparts(pths{i});
    writetable(tab_t, fullfile(save_dir, [fname, ext]))
end

end

function [dens, vol] = calc_dry_dens_vol(bm_h2o, bm_d2o, dens_h2o, dens_d2o)

dens = (dens_d2o.*bm_h2o - dens_h2o.*bm_d2o) ./ (bm_h2o - bm_d2o);
vol = (bm_h2o - bm_d2o) ./ (dens_d2o - dens_h2o);

end
