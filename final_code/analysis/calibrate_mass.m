function calibrate_mass(run_params)
% Processing of binary files for SMR mass measurements for mass calibration
% 
% Arguments:
%   run_params (struct): running parameters for preprocessing code

%% Load data files
file_selection.valve_state = 0;
file_selection.mass_cal = 0;
file_selection.dens_bl_cal = 0;
file_selection.pmt_data = 0;
file_selection.cc_data = 0;

[parsed_files, data_dir, formatted_date] = parse_dir_contents(file_selection);

freqfile = parsed_files.freq_id;
timefile = parsed_files.smr_time_id;

%% Add file to save processed data
run_params.saving.save_abs_path = create_results_dir(run_params, data_dir);
save_abs_path = run_params.saving.save_abs_path;

%% Analyze frequency data to get peaks
[processed_freq_data, pass_struct, init_time] = analyze_freq_data(run_params, ...
    freqfile, timefile);
summary_pks = processed_to_summary(run_params, processed_freq_data, init_time);

%% Manual peak curation and data saving
curated = curation_handler(run_params, pass_struct, summary_pks, ...
    save_abs_path, 'peakset_summary.csv', 0);

analyze_mass_cal(run_params, curated, save_abs_path, formatted_date)
param_log(run_params, save_abs_path)
disp_dir_link(run_params.saving.save_abs_path)
fclose('all');

end
