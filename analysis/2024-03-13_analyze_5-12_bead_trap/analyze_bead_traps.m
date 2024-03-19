close all;
addpath(genpath("..\..\helpers"));

%% Load data
bead_trap1 = readtable("A:\thomasu\raw_data\2024-01-29\5-12um_bead_dens_trap_1\20240313.154844_density_trap_results\peakset_summary_paired.csv");
bead_trap2 = readtable("A:\thomasu\raw_data\2024-01-29\5-12um_bead_dens_trap_2\20240313.155130_density_trap_results\peakset_summary_paired.csv");

bead_trap1_large = readtable("A:\thomasu\raw_data\2024-01-29\5-12um_bead_dens_trap_1\20240313.175216_density_trap_results\peakset_summary_paired.csv");
bead_trap2_large = readtable("A:\thomasu\raw_data\2024-01-29\5-12um_bead_dens_trap_2\20240313.180019_density_trap_results\peakset_summary_paired.csv");

% Low mass data
mask1 = bead_trap1.density_gcm3 > 1.046 & bead_trap1.density_gcm3 < 1.058;
mask2 = bead_trap2.density_gcm3 > 1.053 & bead_trap2.density_gcm3 < 1.056;

trp1_sl = bead_trap1(mask1, :);
trp2_sl = bead_trap2(mask2, :);

% High mass data
mask1_lar = bead_trap1_large.volume_fl > 750 & bead_trap1_large.volume_fl < 920;
mask2_lar = bead_trap2_large.volume_fl > 750 & bead_trap2_large.volume_fl < 920;

trp1_sl = [trp1_sl; bead_trap1_large(mask1_lar, :)]; % -----------------------------
trp2_sl = [trp2_sl; bead_trap2_large(mask2_lar, :)]; % -----------------------------

 %% Plotting
fh1 = figure; plot_scatter_histogram(fh1, trp1_sl, 'density_gcm3', ...
    'volume_fl', 'Density (g/cm3)', 'Volume (fl)')
title('Trap 1')
saveas(fh1, 'fig\trap1_dv_scatterhist.jpg');

fh2 = figure; plot_scatter_histogram(fh2, trp2_sl, 'density_gcm3', ...
    'volume_fl', 'Density (g/cm3)', 'Volume (fl)')
title('Trap 2')
saveas(fh2, 'fig\trap2_dv_scatterhist.jpg');

fh3 = figure;
scatter(trp1_sl.density_gcm3, trp1_sl.volume_fl, 15, 'red', DisplayName='First Trap Dataset'); hold on;
scatter(trp2_sl.density_gcm3, trp2_sl.volume_fl, 15, 'blue', DisplayName='Second Trap Dataset');
set(fh3, Position=[1125         323         560         505]);

[diam_dict, ~] = get_bead_diams();
vols_gt = 4/3 * pi * (diam_dict([6 7 8 9 10 12]) / 2).^3;
scatter(1.05 * ones(size(vols_gt)), vols_gt, 40, 'green', '+', DisplayName='Ground truth', LineWidth=2.5)
yline(vols_gt, Color='green', HandleVisibility='off')

xlabel('Density (g/cm3)'); ylabel('Volume (fl)')
legend(Location='southoutside')
saveas(fh3, 'fig\trap12_scatter.jpg')

fh4 = figure; histogram(trp1_sl.density_gcm3, 60); saveas(fh4, 'fig\trap1_dens_hist.jpg');
xlabel('Density (g/cm3)'); ylabel('Count');
fh5 = figure; histogram(trp2_sl.density_gcm3, 60); saveas(fh5, 'fig\trap2_dens_hist.jpg');
xlabel('Density (g/cm3)'); ylabel('Count');

% labels = [0, 120, 180, 280, 380, 520, 920];
% labels_ = ["6um beads", "7um beads", "8um beads", "9um beads", "10um beads", "12um beads"];
% colors = ["#e41a1c","#377eb8","#4daf4a","#984ea3","#ff7f00","#ffff33"];
% bin_width = 0.001;
% fh6 = figure; hold on;
% for i = 1:length(labels)-1
%     vols = trp1_sl.volume_fl;
%     trp1_sl_temp = trp1_sl(vols < labels(i+1) & vols > labels(i), :);
%     add_pdf_histogram(fh6, trp1_sl_temp.density_gcm3, bin_width, colors(i), 0.2, 0.2, labels_(i))
% end
% legend(Location='southoutside')
% 
% fh7 = figure; hold on;




fh_bl_fl1_trp1 = figure; histogram(trp1_sl.fl1_avg_baseline, 150); title('Trap 1 avg baseline in pbs'); xlabel('Avg baseline (Hz)')
saveas(fh_bl_fl1_trp1, 'fig\fh_bl_fl1_trp1.jpg')
fh_bl_fl1_trp2 = figure; histogram(trp2_sl.fl1_avg_baseline, 150); title('Trap 2 avg baseline in pbs'); xlabel('Avg baseline (Hz)')
saveas(fh_bl_fl1_trp2, 'fig\fh_bl_fl1_trp2.jpg')

fh_bl_fl2_trp1 = figure; histogram(trp1_sl.fl2_avg_baseline, 150); title('Trap 1 avg baseline in d2o'); xlabel('Avg baseline (Hz)')
saveas(fh_bl_fl2_trp1, 'fig\fh_bl_fl2_trp1.jpg')
fh_bl_fl2_trp2 = figure; histogram(trp2_sl.fl2_avg_baseline, 150); title('Trap 2 avg baseline in d2o'); xlabel('Avg baseline (Hz)')
saveas(fh_bl_fl2_trp2, 'fig\fh_bl_fl2_trp2.jpg')