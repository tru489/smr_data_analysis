close all;

paths = {...
    "A:\thomasu\raw_data\2023-10-31\8um_bead_trap_1\20240122.104649_mass_results\2023-10-31_8um_bead_trap_1.csv",...
    "A:\thomasu\raw_data\2023-10-31\8um_bead_trap_2\20240122.105038_mass_results\2023-10-31_8um_bead_trap_2.csv",...
    "A:\thomasu\raw_data\2023-10-31\8um_bead_trap_4\20240122.105411_mass_results\2023-10-31_8um_bead_trap_4.csv",...
    "A:\thomasu\raw_data\2023-10-31\8um_bead_trap_5\20240119.153406_mass_results\2023-10-31_8um_bead_trap_5.csv",...
    };


data = readtable(paths{3});
histogram(data.transit_t, 50)
dist1_mean_sl = data(data.transit_t < 404 & data.transit_t > 386, :);
dist1_mean = mean(dist1_mean_sl.transit_t);
dist1_half = data(data.transit_t < dist1_mean, :); dist1_half = dist1_half.transit_t;
reconst_dist1 = [dist1_half; -dist1_half + 2 * max(dist1_half)];
dist1_std = std(reconst_dist1);
fprintf('Mean: %.04f, std: %.04f\n', dist1_mean, dist1_std)

dist2_mean_sl = data(data.transit_t < 430 & data.transit_t > 410, :);
dist2_mean = mean(dist2_mean_sl.transit_t);
dist2_half = data(data.transit_t < dist2_mean, :); dist2_half = dist2_half.transit_t;
reconst_dist2 = [dist2_half; -dist2_half + 2 * max(dist2_half)];
fprintf('Mean: %.04f, std: %.04f\n', dist2_mean, dist2_std)
dist2_std = std(reconst_dist2);