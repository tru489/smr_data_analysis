function mass_preprocess(run_params)
% Preprocessing of binary files for SMR mass measurements
% 
% Arguments:
%   run_params (struct): running parameters for preprocessing code
% Returns:

%% Load data files
[freqfile, data_dir] = get_raw_file_handle('frequency');
[timefile, ~] = get_raw_file_handle('time');

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
num_segments = get_num_segments(freqfile);
processed_freq_data = analyze_freq_data(run_params, num_segments);
summary_pks_table = processed_to_summary(processed_freq_data);

% Close large raw data files
fclose(freqfile);
fclose(timefile);

%% Manual peak curation and data saving
save_dir = data_dir + "analyzed";
if exist(save_dir, 'dir')
    rmdir(save_dir, 's')
end
mkdir(save_dir);

if run_params.prefs.manual_curation
    % TODO: implement peak curation WITH baseline visualization
    curated = manual_peak_curation();
    writetable(curated, save_dir + filesep + 'peak_data.csv')
else
    writetable(summary_pks_table, save_dir + filesep + 'peak_data.csv')
end

end
