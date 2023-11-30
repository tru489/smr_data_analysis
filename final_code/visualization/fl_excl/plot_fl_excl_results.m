function fig_path_cell = plot_fl_excl_results(run_params, full_summary)

save_abs_path = run_params.saving.save_abs_path;
fig_path = fullfile(save_abs_path, 'fig');
mkdir(fig_path);

if run_params.vis.disp_fig_windows
    fig_visibility = 'on';
else
    fig_visibility = 'off';
end

% Create cell array for figure absolute paths
fig_path_cell = {};
i = 1; % Index to keep track of figures added to path cell array

%% Create mass histogram
total_mass_fig = plot_histogram(full_summary.mass_pg, ...
    'Total Mass (pg)', fig_visibility);

total_mass_fig_path = fullfile(fig_path, 'mass_pg_hist.jpg');
saveas(total_mass_fig, total_mass_fig_path)
fig_path_cell{i} = total_mass_fig_path;
i = i + 1;

%% Create histogram of transit times
transit_t_fig = plot_histogram(full_summary.transit_t, ...
    'Transit Time (datapoints)', fig_visibility);

transit_t_fig_path = fullfile(fig_path, 'transit_t_hist.jpg');
saveas(transit_t_fig, transit_t_fig_path)
fig_path_cell{i} = transit_t_fig_path;
i = i + 1;

%% Create avg baseline scatter
avg_bl_scatter = figure('visible', fig_visibility);
set(avg_bl_scatter, 'color', 'w')
s = scatter(full_summary.peak_time_m, full_summary.avg_baseline, 10, 'b', 'filled');
s.MarkerFaceAlpha = 0.5;
ax = gca; ax.FontSize = 11;
xlabel('Relative Peak Time (min)', 'FontSize', 13)
ylabel('Average Baseline (Hz)', 'FontSize', 13)

avg_bl_scatter_path = fullfile(fig_path, 'avg_bl_scatter.jpg');
saveas(avg_bl_scatter, avg_bl_scatter_path)
fig_path_cell{i} = avg_bl_scatter_path;
i = i + 1;

%% Create baseline slope scatter
bl_slope_scatter = figure('visible', fig_visibility);
set(bl_slope_scatter, 'color', 'w')
s = scatter(full_summary.peak_time_m, full_summary.bl_slope, 10, 'b', 'filled');
s.MarkerFaceAlpha = 0.5;
ax = gca; ax.FontSize = 11;
xlabel('Relative Peak Time (min)', 'FontSize', 13)
ylabel('Average Baseline Slope', 'FontSize', 13)

bl_slope_scatter_path = fullfile(fig_path, 'bl_slope_scatter.jpg');
saveas(bl_slope_scatter, bl_slope_scatter_path)
fig_path_cell{i} = bl_slope_scatter_path;
i = i + 1;

%% Create volume histogram
total_vol_fig = plot_histogram(full_summary.total_volume_fl, ...
    'Total Volume (fl)', fig_visibility);

total_volume_fig_path = fullfile(fig_path, 'volume_fl_hist.jpg');
saveas(total_vol_fig, total_volume_fig_path)
fig_path_cell{i} = total_volume_fig_path;
i = i + 1;

%% Create density histogram
total_density_fig = plot_histogram(full_summary.total_density_gcm3, ...
    'Total Density (g/cm3)', fig_visibility);

total_density_fig_path = fullfile(fig_path, 'density_gcm3_hist.jpg');
saveas(total_density_fig, total_density_fig_path)
fig_path_cell{i} = total_density_fig_path;
i = i + 1;

end

