function fig_path_cell = plot_mass_results(run_params, curated)
%PLOT_MASS_SUMMARY Summary of this function goes here
%   Detailed explanation goes here

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
total_mass_fig = plot_histogram(curated.mass_pg, ...
    'Total Mass (pg)', fig_visibility);

total_mass_fig_path = fullfile(fig_path, 'mass_pg_hist.jpg');
saveas(total_mass_fig, total_mass_fig_path)
fig_path_cell{i} = total_mass_fig_path;
i = i + 1;

%% Create histogram of transit times
transit_t_fig = plot_histogram(curated.transit_t, ...
    'Transit Time (datapoints)', fig_visibility);

transit_t_fig_path = fullfile(fig_path, 'transit_t_hist.jpg');
saveas(transit_t_fig, transit_t_fig_path)
fig_path_cell{i} = transit_t_fig_path;
i = i + 1;

%% Create avg baseline scatter
avg_bl_scatter = figure('visible', fig_visibility);
set(avg_bl_scatter, 'color', 'w')
s = scatter(curated.peak_time_m, curated.avg_baseline, 10, 'b', 'filled');
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
s = scatter(curated.peak_time_m, curated.bl_slope, 10, 'b', 'filled');
s.MarkerFaceAlpha = 0.5;
ax = gca; ax.FontSize = 11;
xlabel('Relative Peak Time (min)', 'FontSize', 13)
ylabel('Average Baseline Slope', 'FontSize', 13)

bl_slope_scatter_path = fullfile(fig_path, 'bl_slope_scatter.jpg');
saveas(bl_slope_scatter, bl_slope_scatter_path)
fig_path_cell{i} = bl_slope_scatter_path;
i = i + 1;
end

