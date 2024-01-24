function recal_dens_params(run_params)

file_selection.valve_state = 1;
file_selection.mass_cal = 1;
file_selection.dens_bl_cal = 1;
file_selection.pmt_data = 0;
file_selection.cc_data = 0;

[parsed_files, data_dir, formatted_date] = parse_dir_contents(file_selection);

cal_params = parsed_files.mass_cal;
mass_cal_factor = cal_params.cal_factor_pg_per_hz;

bl_dens_cal_params = parsed_files.dens_bl_cal;
intercept = bl_dens_cal_params.intercept;
slope = bl_dens_cal_params.slope;

% Get calibration file
disp("Getting paired SMR data...")
[path, dir, ind] = uigetfile('../*.csv', ...
    "Select paired SMR data CSV file...", ' ');
if ind ~= 0
    paired_data = readtable(fullfile(dir, path));
else
    error("IOError: CSV file not selected")
end

% Create results dir
run_params.saving.save_abs_path = create_results_dir(run_params, data_dir);
save_dir = run_params.saving.save_abs_path;

run_params.density_trap.fl1_ref_freq = ...
    input('Input reference frequency for fluid 1: ');
fl1_ref_freq = run_params.density_trap.fl1_ref_freq;

run_params.density_trap.fl2_ref_freq = ...
    input('Input reference frequency for fluid 2: ');
fl2_ref_freq = run_params.density_trap.fl2_ref_freq;

[paired_dv, opt_slope, opt_intercept] = ...
    optimize_base_freq_params(paired_data, fl1_ref_freq, fl2_ref_freq, ...
    intercept, slope, mass_cal_factor);

st.date = formatted_date;
st.slope = opt_slope;
st.intercept = opt_intercept;
json_id = fopen(fullfile(save_dir, formatted_date + ...
    "_density_baseline_calibration.json"), 'w');
js_str = jsonencode(st, PrettyPrint=true);
fprintf(json_id, js_str);
fclose(json_id);

writetable(paired_dv, fullfile(save_dir, "paired_dens_vol_recalibrated.csv"))

disp_dir_link(run_params.saving.save_abs_path)
param_log(run_params, run_params.saving.save_abs_path)

fclose('all');

end

