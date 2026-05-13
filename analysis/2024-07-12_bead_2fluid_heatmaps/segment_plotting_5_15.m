close all;
addpath(genpath("..\..\helpers"));

set2 = readtable("C:\thomasu\smr_data_analysis\analysis\2024-07-12_bead_2fluid_heatmaps\data\trapping_datasets\5-15um_beads.csv");
set2 = set2(set2.density_gcm3 > 1.046 & set2.density_gcm3 < 1.062, :);

%%
cal2 = 0.78609163581640928;

avg_freq2 = 61.154770233021772; % dens = 0.997

dens_dict = get_bead_density(); dens_12um = dens_dict([12]);
vol_dict = get_bead_vols_coulter(); vol_12um = vol_dict([12]);

gt_bm_23 = (dens_12um - 0.997) * vol_12um;

new_cal2 = gt_bm_23 / avg_freq2;

set2.volume_fl = set2.volume_fl * new_cal2 / cal2;

%%
% Volume gating
vol_gating = [0 90 140 210 300 400 550 1000 1800];

fh1 = figure(Position=[1921          41        1920         963]);
axs1 = tight_subplot(3,3, 0.07, [0.09 0.05], [0.05 0.02]);

fh2 = figure(Position=[1921          41        1920         963]);
axs2 = tight_subplot(3,3, 0.07, [0.09 0.05], [0.05 0.02]);

for i = 1:length(vol_gating)-1
    tab_sl = set2(set2.volume_fl > vol_gating(i) & set2.volume_fl < vol_gating(i+1), :);
    
    axes(axs1(i));
    scatter(tab_sl.volume_fl, tab_sl.density_gcm3, [], tab_sl.fl2_avg_pk_ht_hz / mean(tab_sl.fl2_avg_pk_ht_hz), 'filled')
    colorbar
    colormap jet

    axes(axs2(i));
    scatter(tab_sl.volume_fl, tab_sl.density_gcm3, [], tab_sl.fl2_bl_dens_gcm3 / mean(tab_sl.fl2_bl_dens_gcm3), 'filled')
    colorbar
    colormap jet
end

saveas(fh1, 'figs_segment_plotting\back_pk_fractions.jpg')
saveas(fh2, 'figs_segment_plotting\back_density_fractions.jpg')