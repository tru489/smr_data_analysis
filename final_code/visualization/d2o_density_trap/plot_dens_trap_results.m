function fig_path_cell = plot_dens_trap_results(run_params, ...
    density_trap_summary)
% Creates plots for D2O density trapping (i.e for dry mass/dry mass density
% etc)
%
% Arguments:
%   run_params (struct): running parameters for analysis
%   density_trap_summary (array(double)): summary density trapping data
%   mass_cal_factor (double): mass calibration factor

%% Setup
save_abs_path = run_params.saving.save_abs_path;
fig_path = fullfile(save_abs_path, 'fig');
mkdir(fig_path);

if run_params.vis.disp_fig_windows
    fig_visibility = 'on';
else
    fig_visibility = 'off';
end

density_gcm3 = density_trap_summary.density_gcm3;
volume_fl = density_trap_summary.volume_fl;
fl1_mass_pg = density_trap_summary.fl1_mass_pg;
fl2_mass_pg = density_trap_summary.fl2_mass_pg;

% Create cell array for figure absolute paths
fig_path_cell = {};
i = 1; % Index to keep track of figures added to path cell array

%% Dry volume histogram
vol_fig = plot_histogram(volume_fl, 'Dry volume (fl)', fig_visibility);
volume_hist_path = fullfile(fig_path, 'dry_volumes_hist.jpg');
saveas(vol_fig, volume_hist_path)
fig_path_cell{i} = volume_hist_path;
i = i + 1;

%% Density histogram
dens_fig = plot_histogram(density_gcm3, 'Dry density (g/cm^3)', fig_visibility);
density_hist_path = fullfile(fig_path, 'dry_density_hist.jpg');
saveas(dens_fig, density_hist_path)
fig_path_cell{i} = density_hist_path;
i = i + 1;

%% Dry density vs volume
% dens_vs_vol_fig = figure('visible', fig_visibility);
% set(dens_vs_vol_fig, 'color', 'w')
% s = scatter(density_gcm3, volume_fl, 10, 'b', 'filled');
% s.MarkerFaceAlpha = 0.5;
% ax = gca; ax.FontSize = 11;
% xlabel('Dry density (g/cm^3)', 'FontSize', 13)
% ylabel('Dry volume (fl)', 'FontSize', 13)
% 
% dens_vol_scatter_path = fullfile(fig_path, 'dens_vs_vol.jpg');
% saveas(dens_vs_vol_fig, dens_vol_scatter_path)
% fig_path_cell{i} = dens_vol_scatter_path;
% i = i + 1;

%% Scatter histogram chart of dry density and dry volume
dens_vs_vol_scatter_histo = figure(Visible='off');
plot_scatter_histogram(dens_vs_vol_scatter_histo, density_trap_summary, ...
    'density_gcm3', 'volume_fl', 'Density (g/cm^3)', 'Volume (fl)');

dens_vol_scatter_hist_path = fullfile(fig_path, 'dens_vs_vol_scatterhisto.jpg');
saveas(dens_vs_vol_scatter_histo, dens_vol_scatter_hist_path)
fig_path_cell{i} = dens_vol_scatter_hist_path;
i = i + 1;

%% Forward vs backward peaks
% fwd_back_fig = figure('visible', fig_visibility);
% set(fwd_back_fig, 'color', 'w')
% s = scatter(fl1_mass_pg, fl2_mass_pg, 10, 'b', 'filled');
% s.MarkerFaceAlpha = 0.5;
% ax = gca; ax.FontSize = 11;
% xlabel('Forward Peak Buoyant Mass (pg)', 'FontSize', 13)
% ylabel('Backward Peak Buoyant Mass (pg)', 'FontSize', 13)
% title("Mass calibration factor: " + num2str(mass_cal_factor) + " pg/Hz", ...
%     'FontSize', 13)
% 
% dens_vol_scatter_path = fullfile(fig_path, 'fwd_back_peaks.jpg');
% saveas(fwd_back_fig, dens_vol_scatter_path)
% fig_path_cell{i} = dens_vol_scatter_path;
% i = i + 1;

%% Forward peaks histogram
fl1_hist = plot_histogram(fl1_mass_pg, ...
    'Buoyant mass in fluid 1 (pg)', fig_visibility);
fl1_hist_path = fullfile(fig_path, 'fl1_bm_peaks.jpg');
saveas(fl1_hist, fl1_hist_path)
fig_path_cell{i} = fl1_hist_path;
i = i + 1;

%% Backward peaks histogram
fl2_hist = plot_histogram(fl2_mass_pg, ...
    'Buoyant mass in fluid 2 (pg)', fig_visibility);
fl2_hist_path = fullfile(fig_path, 'fl2_bm_peaks.jpg');
saveas(fl2_hist, fl2_hist_path)
fig_path_cell{i} = fl2_hist_path;
i = i + 1;

%% Scatter histogram chart of forward and back peaks
fwd_back_scatter_histo = figure(Visible='off');
plot_scatter_histogram(fwd_back_scatter_histo, density_trap_summary, ...
    'fl1_mass_pg', 'fl2_mass_pg', 'Buoyant mass in fluid 1 (pg)', ...
    'Buoyant mass in fluid 2 (pg)');

dens_vol_scatter_hist_path = fullfile(fig_path, 'fl1_fl2_scatterhisto.jpg');
saveas(fwd_back_scatter_histo, dens_vol_scatter_hist_path)
fig_path_cell{i} = dens_vol_scatter_hist_path;
i = i + 1;
end
