close all;
addpath(genpath("..\..\helpers"));

data_dir = 'data\5-15um_beads';
pair_tab = readtable(fullfile(data_dir, "peakset_summary_paired.csv"));
pair_tab = pair_tab(pair_tab.density_gcm3 < 1.062 & pair_tab.density_gcm3 > 1.046,:);
met_tab = readtable("C:\thomasu\smr_data_analysis\analysis\2024-07-12_bead_2fluid_heatmaps\fig_5-15um\full_metric_table.csv");
met_tab = met_tab(pair_tab.density_gcm3 < 1.062 & pair_tab.density_gcm3 > 1.046,:);

vol_gating = [0 90 140 210 300 400 550 1000 1800];

% Fwd and back bl height vs time
fh1 = figure;
mask = met_tab.mean_bl_val_fwd > -200;
s = scatter(pair_tab.fl1_peak_time_s(mask), pair_tab.fl1_bl_dens_gcm3(mask), 40, 'r', 'filled'); 
s.MarkerFaceAlpha=0.3;

xlabel('Time (s)', FontSize=14); ylabel('Mean fluid density (fwd peak)', FontSize=14);
ax=gca; ax.FontSize=13;
saveas(fh1, 'data\vs_time\bl_fwd_vstime.jpg')

% --

fh2 = figure;
s = scatter(pair_tab.fl2_peak_time_s, pair_tab.fl2_bl_dens_gcm3, 40, 'r', 'filled'); 
s.MarkerFaceAlpha=0.3;

xlabel('Time (s)', FontSize=14); ylabel('Mean fluid density (back peak)', FontSize=14);
ax=gca; ax.FontSize=13;
saveas(fh2, 'data\vs_time\bl_back_vstime.jpg')

% --

fh3 = figure;
mask = met_tab.mean_bl_val_fwd > -45;
s = scatter(pair_tab.fl1_bl_dens_gcm3(mask), pair_tab.fl2_bl_dens_gcm3(mask), 40, pair_tab.fl1_peak_time_s(mask), 'filled'); 
s.MarkerFaceAlpha=0.3;
colormap jet
colorbar
xlabel('Average h2o fluid density', FontSize=14); ylabel('Average d2o fluid density', FontSize=14);
ax=gca; ax.FontSize=13;
saveas(fh3, 'data\vs_time\fwd_vs_back_colortime.jpg')

% --

fh4 = figure;
s = scatter(pair_tab.fl2_bl_dens_gcm3, pair_tab.fl2_mass_pg, 40, pair_tab.fl1_peak_time_s, 'filled'); 
colormap jet
colorbar

% --

fh6 = figure;
s = scatter(pair_tab.fl1_peak_time_s, pair_tab.fl1_mass_pg, 40, pair_tab.fl1_peak_time_s, 'filled'); 
colormap jet
colorbar

% --

fh7 = figure;
s = scatter(pair_tab.fl1_peak_time_s, pair_tab.fl2_mass_pg, 40, pair_tab.fl1_peak_time_s, 'filled'); 
colormap jet
colorbar

% % --
% fh8 = figure;
% s = scatter(pair_tab.volume_fl, pair_tab.density_gcm3, 40, pair_tab.fl1_mass_pg, 'filled'); 
% colormap jet
% colorbar
% 
% % --
% fh9 = figure;
% s = scatter(pair_tab.volume_fl, pair_tab.density_gcm3, 40, pair_tab.fl2_mass_pg, 'filled'); 
% colormap jet
% colorbar

fh1 = figure(Position=[1921          41        1920         963]);
axs1 = tight_subplot(3,3, 0.07, [0.09 0.05], [0.05 0.02]);
for i = 1:length(vol_gating)-1
    tab_sl = pair_tab(pair_tab.volume_fl > vol_gating(i) & pair_tab.volume_fl < vol_gating(i+1), :);
    
    axes(axs1(i));
    scatter(tab_sl.volume_fl, tab_sl.density_gcm3, [], tab_sl.fl2_avg_pk_ht_hz / mean(tab_sl.fl2_avg_pk_ht_hz), 'filled')
    colorbar
    colormap jet

    axes(axs2(i));
    scatter(tab_sl.volume_fl, tab_sl.density_gcm3, [], tab_sl.fl2_bl_dens_gcm3 / mean(tab_sl.fl2_bl_dens_gcm3), 'filled')
    colorbar
    colormap jet
end