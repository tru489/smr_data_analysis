close all;
addpath(genpath("..\..\helpers"));

set1 = readtable("C:\thomasu\smr_data_analysis\analysis\2024-07-12_bead_2fluid_heatmaps\data\trapping_datasets\6_8_10um_beads.csv");
set1 = set1(set1.density_gcm3 > 1.04 & set1.density_gcm3 < 1.06, :);
set2 = readtable("C:\thomasu\smr_data_analysis\analysis\2024-07-12_bead_2fluid_heatmaps\data\trapping_datasets\5-15um_beads.csv");
set2 = set2(set2.density_gcm3 > 1.046 & set2.density_gcm3 < 1.062, :);
set3 = readtable("C:\thomasu\smr_data_analysis\analysis\2024-07-12_bead_2fluid_heatmaps\data\trapping_datasets\5_10_15um_beads.csv");
set3 = set3(set3.density_gcm3 > 1.048 & set3.density_gcm3 < 1.056, :);

%%
cal1 = 0.86935259278634813;
cal2 = 0.78609163581640928;
cal3 = 0.78609163581640928;

avg_freq1 = 52.167700651613; % dens = 1.0056
avg_freq2 = 61.154770233021772; % dens = 0.997
avg_freq3 = 61.154770233021772; % dens = 0.997

dens_dict = get_bead_density(); dens_12um = dens_dict([12]);
vol_dict = get_bead_vols_coulter(); vol_12um = vol_dict([12]);

gt_bm1 = (dens_12um - 1.0056) * vol_12um;
gt_bm_23 = (dens_12um - 0.997) * vol_12um;

new_cal1 = gt_bm1 / avg_freq1;
new_cal2 = gt_bm_23 / avg_freq2;
new_cal3 = gt_bm_23 / avg_freq3;

set1.volume_fl = set1.volume_fl * new_cal1 / cal1;
set2.volume_fl = set2.volume_fl * new_cal2 / cal1;
set3.volume_fl = set3.volume_fl * new_cal3 / cal1;

%%
figure; hold on;
scatter(set1.volume_fl, set1.density_gcm3)
scatter(set2.volume_fl, set2.density_gcm3)
scatter(set3.volume_fl, set3.density_gcm3)



% fl1_rng_list = linspace(2,80,30);
% for i = 1:length(fl1_rng_list)
%     fl1_rng = fl1_rng_list(i); fl2 = linspace(-fl1_rng_list(i) - 0.6*fl1_rng_list(i), -fl1_rng_list(i) + 0.3*fl1_rng_list(i), 20);
%     dens_fl1 = 1.0047; dens_fl2 = 1.0956; 
%     dens = (dens_fl2*fl1_rng - dens_fl1*fl2) ./ (fl1_rng-fl2);
%     vol = (fl1_rng-fl2) / (dens_fl2 - dens_fl1);
%     plot(vol, dens, 'k')
% end
% xlim([0 2000])


dens_range = 1.04:0.001:1.062;
vol_range = 0:20:2000;
[dens_range,vol_range] = meshgrid(dens_range,vol_range);
Z = (dens_range - 1.0047).* vol_range; % 1.0047
contour(vol_range,dens_range,Z, 50)


% Plot ground truths
scatter(vol_dict([5:10, 12, 15]), dens_dict([5:10, 12, 15]), 80, 'r', '+', LineWidth=3); 


function rad = vol_to_rad(vol)
    rad = (vol * 3/(4*pi)) .^ (1/3);
end