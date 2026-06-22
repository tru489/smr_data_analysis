function fig_path_cell = plot_mass_results(run_params, summary_pks, dataidx)
%PLOT_MASS_RESULTS Save diagnostic figures for a mass analysis run.
%
% Arguments:
%   run_params (struct): running parameters for analysis
%   summary_pks (table): full peak summary table (all detected peaks)
%   dataidx (array(double)): row indices of summary_pks that were accepted
%       (kept) by curation; the remaining rows are the rejected peaks
% Returns:
%   fig_path_cell (cell(str)): absolute paths of saved figures

save_abs_path = run_params.saving.save_abs_path;
fig_path = fullfile(save_abs_path, 'fig');
mkdir(fig_path);

if run_params.vis.disp_fig_windows
    fig_visibility = 'on';
else
    fig_visibility = 'off';
end

% Reconstruct accepted (curated) and rejected splits
curated = summary_pks(dataidx, :);
rej_idx = setdiff(1:height(summary_pks), dataidx);
rejected = summary_pks(rej_idx, :);

% Create cell array for figure absolute paths
fig_path_cell = {};
i = 1; % Index to keep track of figures added to path cell array

%% Create mass histogram
total_mass_fig = plot_histogram(curated.mass_pg, ...
    'Buoyant mass (pg)', fig_visibility);

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

%% Create curation diagnostic (accepted vs rejected)
accepted_color = [0 0.4470 0.7410]; % blue
rejected_color = [0.8500 0.1250 0.1250]; % red

curation_diag_fig = figure('visible', fig_visibility);
set(curation_diag_fig, 'color', 'w')

% Subplot 1: stacked histogram of accepted vs rejected buoyant masses.
% histogram() cannot stack, so compute shared bin edges over all masses
% and draw stacked bars from the per-group counts.
subplot(1, 2, 1)
[~, edges] = histcounts(summary_pks.mass_pg);
n_acc = histcounts(curated.mass_pg, edges);
if ~isempty(rejected)
    n_rej = histcounts(rejected.mass_pg, edges);
else
    n_rej = zeros(1, numel(edges) - 1);
end
centers = edges(1:end-1) + diff(edges) / 2;
b = bar(centers, [n_acc; n_rej].', 'stacked', 'BarWidth', 1);
b(1).FaceColor = accepted_color;
b(2).FaceColor = rejected_color;
ax = gca; ax.FontSize = 11;
xlabel('Buoyant mass (pg)', 'FontSize', 13)
ylabel('Count', 'FontSize', 13)
legend({'Accepted', 'Rejected'}, 'Location', 'best')

% Subplot 2: buoyant mass vs time, rejected particles in red
subplot(1, 2, 2)
hold on
s_acc = scatter(curated.peak_time_m, curated.mass_pg, 10, ...
    accepted_color, 'filled');
s_acc.MarkerFaceAlpha = 0.5;
if ~isempty(rejected)
    s_rej = scatter(rejected.peak_time_m, rejected.mass_pg, 10, ...
        rejected_color, 'filled');
    s_rej.MarkerFaceAlpha = 0.5;
end
hold off
ax = gca; ax.FontSize = 11;
xlabel('Relative Peak Time (min)', 'FontSize', 13)
ylabel('Buoyant mass (pg)', 'FontSize', 13)
legend({'Accepted', 'Rejected'}, 'Location', 'best')

curation_diag_path = fullfile(fig_path, 'mass_curation_diagnostic.jpg');
saveas(curation_diag_fig, curation_diag_path)
fig_path_cell{i} = curation_diag_path;
i = i + 1;

%% Create mass histogram with outliers removed (MAD-based)
mass_no_outliers = rmoutliers(curated.mass_pg);
no_outlier_fig = plot_histogram(mass_no_outliers, ...
    'Buoyant mass (pg, outliers removed)', fig_visibility);

no_outlier_fig_path = fullfile(fig_path, 'mass_pg_hist_no_outliers.jpg');
saveas(no_outlier_fig, no_outlier_fig_path)
fig_path_cell{i} = no_outlier_fig_path;
i = i + 1;
end

