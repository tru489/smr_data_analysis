close all;
addpath(genpath("..\..\helpers"));

%% Get GT densities from two-fluid measurements (H2O- and D2O-PBS)
% Data from: C:\thomasu\smr_data_analysis\analysis\2024-04-02_supp_fig_cal_draft
density_full_values = readtable('data\smr_density_gts.xlsx');

gt_densities = [1.0512, 1.0496, 1.0500, 1.0498, 1.0493, 1.0492, 1.0499, 1.0487];

%% Get GT volumes from Coulter measurements w/ RMSE min. scaling to manufacturer
% Data from: C:\thomasu\smr_data_analysis\analysis\2024-04-09_gt_bead_cal\data\bead_calibrations.xlsx
volume_full_values = readtable('data\cc_volume_gts.xlsx');

mean_coult_vol = [78.747, 130.933, 181.433, 261.567, 371.067, 537.700, 913.333, 1724.667];

[diam_dict, vol_dict] = get_bead_diams();
manu_vols = vol_dict([5 6 7 8 9 10 12 15]);

min_scl_bnd = 0.6; max_scl_bnd = 1.4; 
erf_handle_vol = ...
    @(scl) mean((scl*mean_coult_vol - manu_vols).^2);
scl_value = fminbnd(erf_handle_vol, min_scl_bnd, max_scl_bnd);

fprintf('Scale value: %.3f | Opt range: [%.2f, %.2f]\n', ...
    scl_value, min_scl_bnd, max_scl_bnd)

gt_bead_vols = mean_coult_vol * scl_value;

res_tab = array2table([gt_densities;gt_bead_vols], ...
    'VariableNames', {'5um','6um','7um','8um','9um','10um','12um','15um'});
writetable(res_tab, 'data\final_ground_truth.csv')