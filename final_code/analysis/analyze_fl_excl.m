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

if isnan(pkset_summ)
    %% ------------------------- ANALYZE SMR SIGNAL -------------------------
    % Load data files
    file_selection.valve_state = 1;
    file_selection.mass_cal = 1;
    file_selection.dens_bl_cal = 0;
    file_selection.pmt_data = 1;
    if run_params.fl_excl.use_coulter_calibration
        file_selection.cc_data = 1;
    else
        file_selection.cc_data = 0;
    end
    
    [parsed_files, data_dir, formatted_date] = parse_dir_contents(file_selection);
    
    freqfile = parsed_files.freq_id;
    timefile = parsed_files.smr_time_id;
    cal_params = parsed_files.mass_cal;
    coulter_data = parsed_files.cc_data;
    pmt_file_id = parsed_files.pmt_channels_id;
    pmt_timefile = parsed_files.pmt_time_id;
    
    %% Add file to save processed data
    run_params.saving.save_abs_path = create_results_dir(run_params, data_dir);
    save_abs_path = run_params.saving.save_abs_path;
    
    %% Analyze frequency data to get peaks
    [processed_freq_data, pass_struct, init_time] = ...
        analyze_freq_data(run_params, freqfile, timefile);
    summary_pks = processed_to_summary(run_params, processed_freq_data, ...
        init_time, cal_params.cal_factor_pg_per_hz);
    
    %% Manual peak curation and data saving 
    % curated = curation_handler(run_params, pass_struct, summary_pks, ...
    %     save_abs_path, 'peak_data.csv', run_params.fl_excl.save_peakset_summ);

    % Choose whether to load in a set of curation choices from previous session
    % or to perform curation from scratch
    if ~run_params.prefs.load_previous_curation
        [curated, dataidx] = curation_handler(run_params, pass_struct, summary_pks, ...
            save_abs_path, 'peak_data.csv', run_params.fl_excl.save_peakset_summ);
    else
        [fname, dir, ~] = uigetfile('../*.*','Select previous curation choice CSV...',' ');
        dataidx = readmatrix(fullfile(dir, fname));
        curated = summary_pks(dataidx, :);
    end
    
    % Write curation indices used in this session to CSV
    writematrix(dataidx, fullfile(save_abs_path, 'curation_index.csv'))

else
    curated = pkset_summ;
end

%% ------------------------- ANALYZE PMT SIGNAL -------------------------
% Load data files
% pmt_file_id = get_pmt_file_handles(run_params);
% [pmt_timefile, ~] = get_raw_file_handle('time');

[output_pmt_table, param_table] = analyze_pmt_data(run_params, ...
    pmt_file_id, pmt_timefile, save_abs_path);

% Reformat SMR file to be compatible with readout pairing
variable_names = {'real_time_sec', 'buoyant_mass_pg', 'node_deviation_hz'};
smr_table = array2table([curated.real_time_s, curated.mass_pg, ...
    curated.node_dev_mean], 'VariableNames', variable_names);

[pairing_stats, readout_paired, paired_smr_ind] = ...
    readout_pairing(run_params, smr_table, output_pmt_table, param_table, ...
    save_abs_path);

if run_params.fl_excl.use_coulter_calibration
    [vol_cal_fl_per_au, cc_hist_bin_edges, cc_hist_bin_counts] = ...
        coulter_counter_calibration(run_params, coulter_data, ...
        readout_paired);
else
    vol_cal_fl_per_au = run_params.fl_excl.manual_fl_per_au_cal_factor;
end

total_vols_fl = readout_paired.vol_au * vol_cal_fl_per_au;
[~, idx_smr, idx_pmt] = intersect(curated.real_time_s, ...
    readout_paired.real_time_sec, 'stable');

total_vols_table = array2table([readout_paired.vol_au, total_vols_fl], ...
    'VariableNames', {'total_volume_au', 'total_volume_fl'});
full_summary = [curated(idx_smr, :), total_vols_table(idx_pmt, :)];
full_summary.total_density_gcm3 = full_summary.mass_pg ./ full_summary.total_volume_fl;

path_list = regexp(data_dir, filesep, 'split');
writetable(full_summary, fullfile(save_abs_path, strcat(path_list{end-1}, '_', path_list{end}, '.csv')))


fig_path_cell = plot_fl_excl_results(run_params, full_summary);


stats_cell = get_fl_excl_stats(run_params, ...
    full_summary, summary_pks, cal_params.cal_factor_pg_per_hz, vol_cal_fl_per_au, ...
    output_pmt_table, curated);

analysis_name = get_analysis_type(run_params);
presentation_title = string(formatted_date) + " " + string(analysis_name);
ppt_filename = string(formatted_date) + string(analysis_name) + "_figures";
gen_fig_ppt(run_params, stats_cell, fig_path_cell, ppt_filename, presentation_title, ...
    save_abs_path)






disp_dir_link(run_params.saving.save_abs_path)
param_log(run_params, run_params.saving.save_abs_path)

% Close large raw data files
fclose('all');

end