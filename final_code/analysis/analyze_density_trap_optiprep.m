function analyze_density_trap_optiprep(run_params)
% Processing/analysis of binary files for SMR density trapping measurements
% where the second fluid is more dense than the particles being measured
% 
% Arguments:
%   run_params (struct): running parameters for analysis

%% Unload parameters
% Peakset summary indices
si = run_params.pkset_summ_idx;
% Density trap params
dt = run_params.density_trap;

%% Load data files
[freqfile, data_dir] = get_raw_file_handle('frequency');
[timefile, ~] = get_raw_file_handle('time');
[vsfile, ~] = get_raw_file_handle('valve state');
cal_params = get_json_struct('mass calibration parameters');
bl_dens_cal_params = ...
    get_json_struct('baseline density calibration parameters');
fl1_ref_freq = input('Input reference frequency for fluid 1: ');
fl2_ref_freq = input('Input reference frequency for fluid 2: ');

%% Add file to save processed data
run_params.saving.save_abs_path = create_results_dir(run_params, data_dir);
save_abs_path = run_params.saving.save_abs_path;

%% Analyze frequency data to get peaks
% -- Detect forward peaks --
[processed_freq_data, pass_struct_fluid1] = analyze_freq_data(run_params, ...
    freqfile, timefile, vsfile);
summary_pks_fluid1 = processed_to_summary(processed_freq_data, ...
    cal_params.cal_factor_pg_per_hz);

% -- Detect backward peaks --
[processed_freq_data, pass_struct_fluid2] = analyze_freq_data(run_params, ...
    freqfile, timefile, vsfile);
summary_pks_fluid2 = processed_to_summary(processed_freq_data, ...
    cal_params.cal_factor_pg_per_hz);

% Close large raw data files
fclose(freqfile);
fclose(timefile);
fclose(vsfile);

%% Manual peak curation and data saving
curated_fluid1 = curation_handler(run_params, pass_struct_fluid1, ...
    summary_pks_fluid1, save_abs_path, 'peak_data_fluid1.csv', ...
    run_params.density_trap.save_unpaired);

curated_fluid2 = curation_handler(run_params, pass_struct_fluid2, ...
    summary_pks_fluid2, save_abs_path, 'peak_data_fluid2.csv', ...
    run_params.density_trap.save_unpaired);

%% Density trap peak pairing
fluid1_datasmr = curated_fluid1;
fluid1_pk_direct = 1;
fluid2_datasmr = curated_fluid2;
fluid2_pk_direct = -1;
paired_datasmr = pair_density_trap(run_params, fluid1_datasmr, ...
    fluid1_pk_direct, fluid2_datasmr, fluid2_pk_direct, cal_params, ...
    bl_dens_cal_params, fl1_ref_freq, fl2_ref_freq);

variable_names = {'fl1_pk_time_min', 'fl1_avg_pk_ht_hz', 'fl1_bl_slope', ...
    'fl1_bl_avg_hz', 'fl1_bl_dens_gcm3', 'fl1_pk_ht_1_hz', 'fl1_pk_ht_2_hz', ...
    'fl1_pk_ht_3_hz', 'fl2_pk_time_min', 'fl2_avg_pk_ht_hz', 'fl2_bl_slope', ...
    'fl2_bl_avg_hz', 'fl2_bl_dens_gcm3', 'fl2_pk_ht_1_hz', 'fl2_pk_ht_2_hz', ...
    'fl2_pk_ht_3_hz', 'density_gcm3', 'volume_fl'};
summary_pks_table = array2table(paired_datasmr, ...
    'VariableNames', variable_names);
writetable(summary_pks_table, ...
    fullfile(save_abs_path, 'peak_data_paired.csv'))

disp_dir_link(run_params.saving.save_abs_path)
param_log(run_params, save_dir)

end
