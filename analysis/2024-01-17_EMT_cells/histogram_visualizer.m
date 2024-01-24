close all;

paths = ["A:\thomasu\raw_data\2024-01-12\wt\20240118.093807_fl_excl_results\2024-01-12_wt.csv", ...
    "A:\thomasu\raw_data\2024-01-12\wt_rep2\20240118.095546_fl_excl_results\2024-01-12_wt_rep2.csv", ...
    "A:\thomasu\raw_data\2024-01-12\6a_early\20240117.145826_fl_excl_results\2024-01-12_6a_early.csv", ...
    "A:\thomasu\raw_data\2024-01-12\6a_late\20240117.151846_fl_excl_results\2024-01-12_6a_late.csv", ...
    "A:\thomasu\raw_data\2024-01-12\6d_early\20240117.160357_fl_excl_results\2024-01-12_6d_early.csv", ...
    "A:\thomasu\raw_data\2024-01-12\6d_late\20240118.092733_fl_excl_results\2024-01-12_6d_late.csv"];
labels = ["wt_1", "wt_2", "6a_early", "6a_late", "6d_early", "6d_late"];

for i = 1:length(paths)
    % mass_slice_mask = (mass_pg > 40) & (mass_pg < 300);
    % vol_mask = vol_fl < 8000;
    data = readtable(paths(i));
    mass_pg = data.mass_pg;
    vol_fl = data.total_volume_fl;
    node_dev = data.node_dev_mean;

    figure;
    subplot(2,2,1); histogram(mass_pg, 75); xlabel('mass')
    xline(40); xline(300)
    subplot(2,2,2); histogram(vol_fl, 75); xlabel('volume')
    xline(8000)
    subplot(2,2,3); histogram(node_dev, 75); xlabel('node dev')
    sgtitle(labels(i))
end