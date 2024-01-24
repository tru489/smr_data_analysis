close all;

paired_data_path = "A:\thomasu\raw_data\2024-01-12\l1210_control\20240117.134932_fl_excl_results\readout_paired.txt";
data = readtable(paired_data_path);


f1 = figure;
mass_pg = data.buoyant_mass_pg;
histogram(data.buoyant_mass_pg, 100)
title('mass')

f2 = figure;
vol_au = data.vol_au;
histogram(data.vol_au, 100)
title('vol')

mass_slice = (mass_pg > 22) & (mass_pg < 100);
slice_combine = mass_slice;

save_path = "C:\thomasu\smr_data_analysis\analysis\2024-01-17_EMT_cells\fig\";

f1 = figure;
mass_pg_sl = mass_pg(slice_combine);
histogram(mass_pg_sl, 50)
xlabel('Mass (pg)', 'FontSize', 12)
ylabel('Count', 'FontSize', 12)
saveas(f1, save_path + "l1210_mass_hist.jpg")

f2 = figure;
vol_cal_factor_fl_per_au = 16.710185712;
vol_au_sl = vol_au(slice_combine);
histogram(vol_au_sl * vol_cal_factor_fl_per_au, 50)
xlabel('Volume (fl)', 'FontSize', 12)
ylabel('Count', 'FontSize', 12)
saveas(f2, save_path + "l120_vol_hist.jpg")

f3 = figure;
node_dev = data.node_deviation_hz(slice_combine);
histogram(node_dev, 50)
xlabel('Node deviation (Hz)', 'FontSize', 12)
ylabel('Count', 'FontSize', 12)
saveas(f3, save_path + "l120_ndev_hist.jpg")

data_sliced = data(slice_combine, :);

% write_path = "A:\thomasu\raw_data\2023-12-08\l1210_control\20231214.110243_fl_excl_results\readout_paired_sliced.txt";
% writetable(data_sliced, write_path, 'Delimiter', '\t');