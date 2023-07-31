function calibrate_mass(run_params)
% Processing of binary files for SMR mass measurements for mass calibration
% 
% Arguments:
%   run_params (struct): running parameters for preprocessing code

%% Load data files
[freqfile, data_dir] = get_raw_file_handle('frequency');
[timefile, ~] = get_raw_file_handle('time');

%% Add file to save processed data
run_params.saving.save_abs_path = create_results_dir(run_params, data_dir);
save_abs_path = run_params.saving.save_abs_path;

%% Analyze frequency data to get peaks
[processed_freq_data, pass_struct] = analyze_freq_data(run_params, ...
    freqfile, timefile);
summary_pks = processed_to_summary(processed_freq_data);

% Close large raw data files
fclose(freqfile);
fclose(timefile);

%% Manual peak curation and data saving
samplepeak = pass_struct.samplepeak;
sampletime = pass_struct.sampletime;
sample_baseline_fits = pass_struct.sample_baseline_fits;

if run_params.prefs.manual_curation
    curated = manual_pk_curation(run_params, samplepeak, ...
        sampletime, sample_baseline_fits, summary_pks);
else
    if run_params.curation.always_auto_reject
        % Despite no manual curation, still auto-reject peaks
        idx_discard = auto_discard_peaks(run_params.curation, summary_pks);
        curated = summary_pks(idx_discard, :);
    else
        curated = summary_pks;
    end
end

analyze_mass_cal(run_params, curated, save_abs_path)
param_log(run_params, save_abs_path)
disp_dir_link(run_params.saving.save_abs_path)

end

