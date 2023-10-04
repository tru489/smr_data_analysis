function analyze_fl_excl(run_params, pkset_summ)
% Processing/analysis of binary files for SMR mass measurements
% 
% Arguments:
%   run_params (struct): running parameters for preprocessing code
%   pkset_summ (array(double)): peakset summary from previous SMR signal
%       analysis to be paired with PMT data analyzed here. Optional; if no data
%       is passed then it is assumed that mass and PMT data will be analyzed
%       here

arguments
    run_params
    pkset_summ = NaN
end

si = run_params.pkset_summ_idx;

if isnan(pkset_summ)
    %% ------------------------- ANALYZE SMR SIGNAL -------------------------
    % Load data files
    [freqfile, data_dir] = get_raw_file_handle('frequency');
    [timefile, ~] = get_raw_file_handle('time');
    cal_params = get_json_struct('mass calibration parameters');
    
    %% Add file to save processed data
    run_params.saving.save_abs_path = create_results_dir(run_params, data_dir);
    save_abs_path = run_params.saving.save_abs_path;
    
    %% Analyze frequency data to get peaks
    [processed_freq_data, pass_struct, init_time] = ...
        analyze_freq_data(run_params, freqfile, timefile);
    summary_pks = processed_to_summary(run_params, processed_freq_data, ...
        init_time, cal_params.cal_factor_pg_per_hz);
    
    % Close large raw data files
    fclose(freqfile);
    fclose(timefile);
    
    %% Manual peak curation and data saving 
    curated = curation_handler(run_params, pass_struct, summary_pks, ...
        save_abs_path, 'peak_data.csv', run_params.fl_excl.save_peakset_summ);
else
    curated = pkset_summ;
end

%% ------------------------- ANALYZE PMT SIGNAL -------------------------
% Load data files
pmt_file_id = get_pmt_file_handles(run_params);
[pmt_timefile, ~] = get_raw_file_handle('time');


[output_pmt_table, param_table] = analyze_pmt_data(run_params, ...
    pmt_file_id, pmt_timefile, save_abs_path);

% Reformat SMR file to be compatible with readout pairing
variable_names = {'real_time_sec', 'buoyant_mass_pg', 'node_deviation_hz'};
smr_table = array2table(...
    curated(:, [si.real_time_s, si.mass_pg, si.node_dev_mean]), ...
    'VariableNames', variable_names);

[pairing_stats, readout_paired, paired_smr_ind] = ...
    readout_pairing(run_params, smr_table, output_pmt_table, param_table, ...
    save_abs_path);

Coulter_data = get_coulter_data();
vol_cal_fl_per_au = coulter_counter_calibration(run_params, Coulter_data, ...
    readout_paired);

disp_dir_link(run_params.saving.save_abs_path)
param_log(run_params, run_params.saving.save_abs_path)



end