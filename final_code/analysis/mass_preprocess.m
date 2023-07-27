function mass_preprocess(run_params)
% Processing of binary files for SMR mass measurements
% 
% Arguments:
%   run_params (struct): running parameters for preprocessing code

%% Load data files
[freqfile, data_dir] = get_raw_file_handle('frequency');
[timefile, ~] = get_raw_file_handle('time');
cal_params = get_json_struct('mass calibration parameters');

%% Add file to save processed data
run_params.saving.save_abs_path = create_results_dir(run_params, data_dir);

%% Options for running 
analysismode = input('Rapid analysis mode? (1 = Yes, 0 = No): ');
if analysismode == 1
    dispprogress = input('Display progress? (1 = Yes, 0 = No): ');
else
    dispprogress = 1;
end
run_params.analysis_params.analysismode = analysismode;
run_params.analysis_params.dispprogress = dispprogress;

%% Analyze frequency data to get peaks
[processed_freq_data, pass_struct] = analyze_freq_data(run_params, ...
    freqfile, timefile);
summary_pks = processed_to_summary(processed_freq_data);

% Add calibrated mass data to peakset summary
summary_pks = [summary_pks, ...
    summary_pks(:,3) * cal_params.cal_factor_pg_per_hz];

% Close large raw data files
fclose(freqfile);
fclose(timefile);

%% Manual peak curation and data saving
samplepeak = pass_struct.samplepeak;
sampletime = pass_struct.sampletime;
sample_baseline_fits = pass_struct.sample_baseline_fits;

if run_params.prefs.manual_curation
    curated = manual_peak_curation(run_params, samplepeak, ...
        sampletime, sample_baseline_fits, summary_pks);
    
    variable_names = {'peak_time_s', 'peak_time_m', 'avg_pk_ht_hz', ...
        'avg_baseline', 'bl_slope', 'pk_ht1_hz', 'pk_ht2_hz', ...
        'pk_ht3_hz', 'node_dev_1', 'node_dev_2', 'node_dev_mean', ...
        'pk_fwhm', 'transit_t', 'segment_num', 'peak_time_h', ...
        'pk_order', 'mass_pg'};
    summary_pks_table = array2table(curated, ...
        'VariableNames', variable_names);
    writetable(summary_pks_table, save_dir + filesep + 'peak_data.csv')
else
    if run_params.curation.always_auto_reject
        % Despite no manual curation, still reject peaks 
        idx_discard = auto_discard_peaks(params, summary_pks);
        summary_pks = summary_pks(~idx_discard, :);
    end
    
    variable_names = {'peak_time_s', 'peak_time_m', 'avg_pk_ht_hz', ...
        'avg_baseline', 'bl_slope', 'pk_ht1_hz', 'pk_ht2_hz', ...
        'pk_ht3_hz', 'node_dev_1', 'node_dev_2', 'node_dev_mean', ...
        'pk_fwhm', 'transit_t', 'segment_num', 'peak_time_h', ...
        'pk_order', 'mass_pg'};
    summary_pks_table = array2table(summary_pks, ...
        'VariableNames', variable_names);
    writetable(summary_pks_table, save_dir + filesep + 'peak_data.csv')
end

end