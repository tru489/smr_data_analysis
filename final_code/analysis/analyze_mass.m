function analyze_mass(run_params, data_dir, rev_peaks_invert)
% Processing/analysis of binary files for SMR mass measurements
%
% Arguments:
%   run_params (struct): running parameters for preprocessing code
%   data_dir (string, optional): path to data directory. If omitted, a
%       uigetdir dialog opens. Pass when calling from batch_main.m.
%   rev_peaks_invert (0|1, optional): whether peaks are inverted. If
%       omitted (-1), the user is prompted interactively.

arguments
    run_params
    data_dir          string = ""
    rev_peaks_invert  double {mustBeMember(rev_peaks_invert, [-1, 0, 1])} = -1
end

%% Load data files
file_selection.valve_state = 1;
file_selection.mass_cal = 1;
file_selection.dens_bl_cal = 0;
file_selection.pmt_data = 0;
file_selection.cc_data = 0;

[parsed_files, data_dir, formatted_date] = parse_dir_contents(file_selection, data_dir);

freqfile = parsed_files.freq_id;
timefile = parsed_files.smr_time_id;
vsfile = parsed_files.vs_id;
mass_cal_params = parsed_files.mass_cal;

%% Ask user whether peaks are inverted (skipped when called programmatically)
if rev_peaks_invert == -1
    flag = 1;
    while flag
        peak_reversal = input('Are peaks inverted? (y/n): ', 's');
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
end

%% Add file to save processed data
run_params.saving.save_abs_path = create_results_dir(run_params, data_dir);
save_abs_path = run_params.saving.save_abs_path;

%% Analyze frequency data to get peaks
disp('Detecting peaks from frequency data...')
if ~rev_peaks_invert
    [processed_freq_data, pass_struct, init_time] = analyze_freq_data(run_params, ...
        freqfile, timefile, vsfile);
else
    [processed_freq_data, pass_struct, init_time] = analyze_freq_data(run_params, ...
        freqfile, timefile, vsfile, 1);
end

summary_pks = processed_to_summary(run_params, processed_freq_data, init_time, ...
    mass_cal_params.cal_factor_pg_per_hz);

%% Manual peak curation and data saving
path_list = regexp(data_dir, filesep, 'split');

% Choose whether to load in a set of curation choices from previous session
% or to perform curation from scratch
if ~run_params.prefs.load_previous_curation
    [curated, dataidx] = curation_handler(run_params, pass_struct, summary_pks, ...
        save_abs_path, strcat(path_list{end-1}, '_', path_list{end}, '.csv'), 1);
else
    [fname, dir, ~] = uigetfile('../*.*','Select previous curation choice CSV...',' ');
    dataidx = readmatrix(fullfile(dir, fname));
    curated = summary_pks(dataidx, :);
    writetable(curated, fullfile(save_abs_path, strcat(path_list{end-1}, '_', path_list{end}, '.csv')))
end

% Write curation indices used in this session to CSV
writematrix(dataidx, fullfile(save_abs_path, 'curation_index.csv'))

stats_cell = get_mass_stats(run_params, summary_pks, curated, ...
    mass_cal_params.cal_factor_pg_per_hz);
fig_path_cell = plot_mass_results(run_params, summary_pks, dataidx);

analysis_name = get_analysis_type(run_params);
presentation_title = string(formatted_date) + " " + string(analysis_name);
ppt_filename = string(formatted_date) + string(analysis_name) + "_figures";
gen_fig_ppt(run_params, stats_cell, fig_path_cell, ppt_filename, ...
    presentation_title, save_abs_path)

disp_dir_link(run_params.saving.save_abs_path)
param_log(run_params, run_params.saving.save_abs_path)

% Close large raw data files
fclose('all');

end