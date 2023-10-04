function fig_path_cell = plot_water_content_results(run_params, ...
    full_summary, mass_cal_factor, vol_cal_factor, cc_hist_bin_edges, ...
    cc_hist_bin_counts, smr_peaks_unpaired, output_pmt_table)
% Plots water content result figures
%
% Arguments
%   run_params (struct): running parameters for analysis
%   full_summary (table): summary table for density trapping
%   mass_cal_factor (double): mass calibration factor
%   vol_cal_factor

save_abs_path = run_params.saving.save_abs_path;
fig_path = fullfile(save_abs_path, 'fig');

if run_params.vis.disp_fig_windows
    fig_visibility = 'on';
else
    fig_visibility = 'off';
end

fig_path_cell = plot_dens_trap_results(run_params, full_summary);
i = length(fig_path_cell) + 1;

%% Total volume histogram
total_vol_hist = plot_histogram(full_summary.total_volume_fl, ...
    'Total Volume (fl)', fig_visibility);
title("Volume calibration factor: " + num2str(vol_cal_factor) + " fl/au", ...
    'FontSize', 13)

total_vol_hist_path = fullfile(fig_path, 'total_vol_hist.jpg');
saveas(total_vol_hist, total_vol_hist_path)
fig_path_cell{i} = total_vol_hist_path;
i = i + 1;

%% Coulter counter histogram
cc_hist = figure('visible', fig_visibility);
set(cc_hist, 'color', 'w')

vol_ceiling =(4*pi*(40./2).^3)/3; % for 40um filter
histogram('BinEdges', cc_hist_bin_edges, 'BinCounts', cc_hist_bin_counts)
xlim([0, vol_ceiling])
set(gca, 'Xscale', 'log')
ax = gca; ax.FontSize = 11;
xlabel('Coulter Counter Volume (fl)', 'FontSize', 13)
ylabel('Count', 'FontSize', 13)

cc_hist_path = fullfile(fig_path, 'coulter_counter_hist.jpg');
saveas(cc_hist, cc_hist_path)
fig_path_cell{i} = cc_hist_path;
i = i + 1;

%% Time gaps between forward and back peaks
fwd_back_hist = plot_histogram(...
    full_summary.fl2_real_time_s - full_summary.fl1_real_time_s, ...
    'Forward-back time gap (s)', fig_visibility);
fwd_back_hist_path = fullfile(fig_path, 'fwd_back_hist.jpg');
saveas(fwd_back_hist, fwd_back_hist_path)
fig_path_cell{i} = fwd_back_hist_path;
i = i + 1;

%% Forward and reverse peaks prior to density pairing
f1_vs = run_params.density_trap.fluid1_vstate;
f2_vs = run_params.density_trap.fluid2_vstate;
forward_pks = smr_peaks_unpaired(smr_peaks_unpaired.valve_state == f1_vs, :);
backward_pks = smr_peaks_unpaired(smr_peaks_unpaired.valve_state == f2_vs, :);

init_forward_back_pks = figure('visible', fig_visibility);
set(init_forward_back_pks, 'color', 'w')
bin_width = 2;
h_f1 = histogram(forward_pks.mass_pg, 'BinWidth', 2, 'DisplayName', ...
    'Candidate Forward Peaks');
h_f1.FaceAlpha = 0.3; h_f1.EdgeAlpha = 0.4;
hold on;
h_f2 = histogram(backward_pks.mass_pg, 'BinWidth', 2, 'DisplayName', ...
    'Candidate Backward Peaks');
h_f2.FaceAlpha = 0.3; h_f2.EdgeAlpha = 0.4;
legend('FontSize', 13);
ax = gca; ax.FontSize = 11;
xlabel('Buoyant mass (pg)', 'FontSize', 13)
ylabel('Count', 'FontSize', 13)

init_forward_back_pks_path = fullfile(fig_path, 'fwd_back_candidate_hist.jpg');
saveas(init_forward_back_pks, init_forward_back_pks_path)
fig_path_cell{i} = init_forward_back_pks_path;
i = i + 1;

%% Distribution of measured volumes prior to pairing
init_tot_vol = plot_histogram(output_pmt_table.vol_au * vol_cal_factor, ...
    'Total volume prior to pairing (fl)', fig_visibility);

init_tot_vol_path = fullfile(fig_path, 'init_total_vol_hist.jpg');
saveas(init_tot_vol, init_tot_vol_path)
fig_path_cell{i} = init_tot_vol_path;
i = i + 1;

%% Distribution of water content
water_content = plot_histogram(full_summary.water_content, ...
    'Fractional water content', fig_visibility);

water_content_path = fullfile(fig_path, 'water_content_hist.jpg');
saveas(water_content, water_content_path)
fig_path_cell{i} = water_content_path;
i = i + 1;

%% Water content vs total volume
wc_vs_tot_vol = plot_scatter_histogram(full_summary, ...
    'total_volume_fl', 'water_content', 'Total cell volume (fl)', ...
    'Fractional water content', fig_visibility);

wc_vs_tot_vol_path = fullfile(fig_path, 'wc_vs_tot_volume.jpg');
saveas(wc_vs_tot_vol, wc_vs_tot_vol_path)
fig_path_cell{i} = wc_vs_tot_vol_path;
i = i + 1;

%% Water content vs dry volume
wc_vs_dry_vol = plot_scatter_histogram(full_summary, ...
    'volume_fl', 'water_content', 'Dry cell volume (fl)', ...
    'Fractional water content', fig_visibility);

wc_vs_dry_vol_path = fullfile(fig_path, 'wc_vs_dry_volume.jpg');
saveas(wc_vs_dry_vol, wc_vs_dry_vol_path)
fig_path_cell{i} = wc_vs_dry_vol_path;
i = i + 1;

%% Water content vs dry density
wc_vs_dry_dens = plot_scatter_histogram(full_summary, ...
    'density_gcm3', 'water_content', 'Dry mass density (g/cm3)', ...
    'Fractional water content', fig_visibility);

wc_vs_dry_dens_path = fullfile(fig_path, 'wc_vs_dry_dens.jpg');
saveas(wc_vs_dry_dens, wc_vs_dry_dens_path)
fig_path_cell{i} = wc_vs_dry_dens_path;
i = i + 1;

end

