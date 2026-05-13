close all;
addpath(genpath("..\..\helpers"));

fh = figure;
t1 = readtable("C:\thomasu\smr_data_analysis\analysis\2024-07-12_bead_2fluid_heatmaps\data\5_10_15um_beads\peakset_summary_paired.csv");
mask = t1.density_gcm3 < 1.07 & t1.density_gcm3 > 1.04;
s = scatter(t1.volume_fl(mask), t1.density_gcm3(mask), [], t1.fl2_bl_dens_gcm3(mask), 'filled');
colorbar
colormap jet
% s.MarkerFaceAlpha=0.3;

xlabel('Dry Volume (fL)', FontSize=14); ylabel('Dry Density (g/cm3)', FontSize=14);
ax=gca; ax.FontSize=13;
% saveas(fh1, 'data\vs_time\bl_fwd_vstime.jpg')

% fh=figure; 
% s = scatter(t1.volume_fl(mask), t1.density_gcm3(mask), [], t1.fl1_peak_time_s(mask), 'filled');


%% 
fh = figure; 
t2 = readtable("C:\thomasu\smr_data_analysis\analysis\2024-07-12_bead_2fluid_heatmaps\data\6_8_10um_beads\peakset_summary_paired.csv");
mask = t2.density_gcm3 < 1.055 & t2.density_gcm3 > 1.04;
s = scatter(t2.volume_fl(mask), t2.density_gcm3(mask), [], t2.fl2_bl_dens_gcm3(mask), 'filled');
colorbar
colormap jet
% s.MarkerFaceAlpha=0.3;

xlabel('Dry Volume (fL)', FontSize=14); ylabel('Dry Density (g/cm3)', FontSize=14);
ax=gca; ax.FontSize=13;
% saveas(fh1, 'data\vs_time\bl_fwd_vstime.jpg')