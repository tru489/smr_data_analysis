close all;
addpath(genpath("..\..\helpers"));
addpath(genpath("..\..\final_code"));

unscaled_paths = ls('data', true);

new_p = [-1.72602e+05, 1.33222e+06];

% Hz/pg calibration correction
cal_pth = "A:\thomasu\raw_data\2023-12-11\12um_bead_cal\20240109.113323_mass_calibration_results\20231211_12um_mass_calibration.json";
bm_cal_st = get_json_struct('mass cal', cal_pth);
gt_bm = (1.05 - 1.0056) * 4/3 * pi * (bm_cal_st.bead_diameter_um / 2)^3;
new_cal_factor = gt_bm / bm_cal_st.avg_freq_hz;
fprintf('Old cal factor: %.5f pg/Hz | new cal factor: %.5f pg/Hz\n', bm_cal_st.cal_factor_pg_per_hz, new_cal_factor)

fl1_rf_bead = 1158724;
fl2_rf_bead = 1142951;

[~, slope_opt, intercept_opt] = ...
    optimize_base_freq_params(readtable(unscaled_paths{1}), fl1_rf_bead, fl2_rf_bead, ...
    new_p(2), new_p(1), new_cal_factor);

p_opt = [slope_opt, intercept_opt];

for i = 1:length(unscaled_paths)
    data_tab = readtable(unscaled_paths{i});

    bead_tab_rescaled = ...
        calc_particle_dens_vol(data_tab, fl1_rf_bead, fl2_rf_bead, ...
        p_opt(2), p_opt(1), new_cal_factor);
    
    [prefix, fname, ext] = fileparts(unscaled_paths(i));
    writetable(bead_tab_rescaled, ['data_rescaled\', fname, '_rescale', ext])
end
