function analyze_water_content(run_params)
% Processing/analysis of binary files for SMR mass measurements
% 
% Arguments:
%   run_params (struct): running parameters for preprocessing code
%   pkset_summ (array(double)): peakset summary from previous SMR signal

%% Unload parameters
% Density trap params
dt = run_params.density_trap;

%% Load data files
file_selection.valve_state = 1;
file_selection.mass_cal = 1;
file_selection.dens_bl_cal = 1;
file_selection.pmt_data = 1;
file_selection.cc_data = 1;

[parsed_files, data_dir, formatted_date] = parse_dir_contents(file_selection);

freqfile = parsed_files.freq_id;
timefile = parsed_files.smr_time_id;
vsfile = parsed_files.vs_id;    
mass_cal_params = parsed_files.mass_cal;
bl_dens_cal_params = parsed_files.dens_bl_cal;
pmt_file_id = parsed_files.pmt_channels_id;
pmt_timefile = parsed_files.pmt_time_id;
coulter_data = parsed_files.cc_data;

run_params.density_trap.fl1_ref_freq = ...
    input('Input reference frequency for fluid 1: ');
run_params.density_trap.fl2_ref_freq = ...
    input('Input reference frequency for fluid 2: ');

%% Ask user whether reverse peaks are inverted
flag = 1;
while flag
    peak_reversal = input('Are the reverse peaks inverted? (y/n): ', 's');
    if lower(peak_reversal) == 'y'
        flag = 0;
        rev_peaks_invert = 1;
    elseif lower(peak_reversal) == 'n'
        flag = 0;
        rev_peaks_invert = 0;
    else
        disp('Invalid input.')
    end
end

%% Add file to save processed data
run_params.saving.save_abs_path = create_results_dir(run_params, data_dir);
save_abs_path = run_params.saving.save_abs_path;

%% Analyze frequency data to get peaks
if ~rev_peaks_invert
    % ---------------- If reverse peaks are not inverted... ----------------
    [processed_freq_data, pass_struct, init_time] = ...
        analyze_freq_data(run_params, freqfile, timefile, vsfile);
    summary_pks = processed_to_summary(run_params, processed_freq_data, ...
        init_time, mass_cal_params.cal_factor_pg_per_hz);
    
    % ---------------- Manual peak curation and data saving ----------------
    % Choose whether to load in a set of curation choices from previous session
    % or to perform curation from scratch
    if ~run_params.prefs.load_previous_curation
        [curated, dataidx] = curation_handler(run_params, pass_struct, summary_pks, ...
            save_abs_path, 'peakset_summary_unpaired.csv', ...
            run_params.density_trap.save_unpaired);
    else
        [fname, dir, ~] = uigetfile('../*.*','Select previous curation choice CSV...',' ');
        dataidx = readmatrix(fullfile(dir, fname));
        curated = summary_pks(dataidx, :);
    end
    
    % Write curation indices used in this session to CSV
    writematrix(dataidx, fullfile(save_abs_path, 'curation_index.csv'))
    
    % ---------------- Density trap peak pairing ----------------
    fluid1_datasmr = curated(curated.valve_state == dt.fluid1_vstate, :);
    fluid1_pk_direct = 1;
    fluid2_datasmr = curated(curated.valve_state == dt.fluid2_vstate, :);
    fluid2_pk_direct = 1;
    paired_datasmr = pair_density_trap(run_params, fluid1_datasmr, ...
        fluid1_pk_direct, fluid2_datasmr, fluid2_pk_direct, mass_cal_params, ...
        bl_dens_cal_params, run_params.density_trap.fl1_ref_freq, ...
        run_params.density_trap.fl2_ref_freq);
else
    % ---------------- If reverse peaks are inverted... ----------------
    % (repeat analysis twice, once normally and once for inverted frequency
    % data)
    
    % -- Detect forward peaks --
    [processed_freq_data, pass_struct_fluid1] = analyze_freq_data(run_params, ...
        freqfile, timefile, vsfile);
    summary_pks_fluid1 = processed_to_summary(processed_freq_data, ...
        mass_cal_params.cal_factor_pg_per_hz);
    
    % -- Detect backward peaks --
    [processed_freq_data, pass_struct_fluid2] = analyze_freq_data(run_params, ...
        freqfile, timefile, vsfile, 1);
    summary_pks_fluid2 = processed_to_summary(processed_freq_data, ...
        mass_cal_params.cal_factor_pg_per_hz);
    
    % ---------------- Manual peak curation and data saving ----------------
    % Choose whether to load in a set of curation choices from previous session
    % or to perform curation from scratch
    if ~run_params.prefs.load_previous_curation
        % Curation for forward peaks...
        [curated_fluid1, dataidx1] = curation_handler(run_params, pass_struct_fluid1, ...
            summary_pks_fluid1, save_abs_path, 'peakset_summary_unpaired_fluid1.csv', ...
            run_params.density_trap.save_unpaired);
        % Curation for reverse peaks...
        [curated_fluid2, dataidx2] = curation_handler(run_params, pass_struct_fluid2, ...
            summary_pks_fluid2, save_abs_path, 'peakset_summary_unpaired_fluid2.csv', ...
            run_params.density_trap.save_unpaired);
    else
        disp('Select previous curation choice CSV for forward measurement...')
        [fname, dir, ~] = uigetfile('../*.*','Select previous curation choice CSV for forward measurement...',' ');
        dataidx1 = readmatrix(fullfile(dir, fname));
        curated_fluid1 = summary_pks_fluid1(dataidx1, :);

        disp('Select previous curation choice CSV for backward measurement...')
        [fname, dir, ~] = uigetfile('../*.*','Select previous curation choice CSV for backward measurement...',' ');
        dataidx2 = readmatrix(fullfile(dir, fname));
        curated_fluid2 = summary_pks_fluid2(dataidx2, :);
    end
    
    % Write curation indices used in this session to CSV
    writematrix(dataidx1, fullfile(save_abs_path, 'curation_index_fwd.csv'))
    writematrix(dataidx2, fullfile(save_abs_path, 'curation_index_back.csv'))
    
    % ---------------- Density trap peak pairing ----------------
    curated = [curated_fluid1, curated_fluid2];
    curated = sortrows(curated, 'real_time_s');
    
    fluid1_datasmr = curated_fluid1;
    fluid1_pk_direct = 1;
    fluid2_datasmr = curated_fluid2;
    fluid2_pk_direct = -1;
    paired_datasmr = pair_density_trap(run_params, fluid1_datasmr, ...
        fluid1_pk_direct, fluid2_datasmr, fluid2_pk_direct, mass_cal_params, ...
        bl_dens_cal_params, run_params.density_trap.fl1_ref_freq, ...
        run_params.density_trap.fl2_ref_freq);
end

writetable(paired_datasmr, fullfile(save_abs_path, ...
    'peakset_summary_paired.csv'))

%% ------------------------- ANALYZE PMT SIGNAL -------------------------
% Load data files
% pmt_file_id = get_pmt_file_handles(run_params);
% [pmt_timefile, ~] = get_raw_file_handle('time');

[output_pmt_table, param_table] = analyze_pmt_data(run_params, ...
    pmt_file_id, pmt_timefile, save_abs_path);

% Reformat SMR file to be compatible with readout pairing
variable_names = {'real_time_sec', 'buoyant_mass_pg', 'node_deviation_hz'};
smr_table = array2table([fluid1_datasmr.real_time_s, fluid1_datasmr.mass_pg, ...
    fluid1_datasmr.node_dev_mean], 'VariableNames', variable_names);

[~, readout_paired, ~] = ...
    readout_pairing(run_params, smr_table, output_pmt_table, param_table, ...
    save_abs_path);
[vol_cal_fl_per_au, cc_hist_bin_edges, cc_hist_bin_counts] = ...
    coulter_counter_calibration(run_params, coulter_data, ...
    readout_paired);


total_vols_fl = readout_paired.vol_au * vol_cal_fl_per_au;
[~, idx_smr, idx_pmt] = intersect(paired_datasmr.fl1_real_time_s, ...
    readout_paired.real_time_sec, 'stable');

total_vols_table = array2table([readout_paired.vol_au, total_vols_fl], ...
    'VariableNames', {'total_volume_au', 'total_volume_fl'});
full_summary = [paired_datasmr(idx_smr, :), total_vols_table(idx_pmt, :)];
full_summary.water_content = ...
    (full_summary.total_volume_fl - full_summary.volume_fl) ./ ...
    full_summary.total_volume_fl;
writetable(full_summary, fullfile(save_abs_path, 'pmt_smr_paired.csv'))

fig_path_cell = plot_water_content_results(run_params, ...
    full_summary, mass_cal_params.cal_factor_pg_per_hz, vol_cal_fl_per_au, cc_hist_bin_edges, ...
    cc_hist_bin_counts, curated, output_pmt_table);

stats_cell = get_water_content_stats(run_params, ...
    full_summary, paired_datasmr, mass_cal_params.cal_factor_pg_per_hz, vol_cal_fl_per_au, ...
    curated, output_pmt_table, vsfile);

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
