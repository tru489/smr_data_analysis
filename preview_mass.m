% Quickly preview mass data from a single run.
%
% Runs peak detection on just the first frequency-data segment and shows
% the same real-time progress plot as a normal mass run, then stops.
% Nothing is written to disk: no results directory is created, and no
% curation, stats, or presentation output is generated.
%
% Uses config.yaml for all parameters, with the following in-memory
% overrides applied for this run only (config.yaml is never modified):
%   analysis_type.mass                = true
%   analysis_params.analysismode      = true
%   analysis_params.dispprogress      = true

close all;
addpath(...
    genpath("final_code"),...
    genpath("helpers"))

%% Load parameters and apply preview-only overrides (config.yaml untouched)
run_params = load_run_params();
run_params.analysis_type.mass           = true;
run_params.analysis_params.analysismode = true;
run_params.analysis_params.dispprogress = true;

%% Select data directory and load raw file handles
file_selection.valve_state = 1;
file_selection.mass_cal    = 1;
file_selection.dens_bl_cal = 0;
file_selection.pmt_data    = 0;
file_selection.cc_data     = 0;

[parsed_files, ~, ~] = parse_dir_contents(file_selection, "", ...
    run_params.dir_formatting.default_raw_data_dir);

freqfile = parsed_files.freq_id;
timefile = parsed_files.smr_time_id;
vsfile   = parsed_files.vs_id;

%% Ask whether peaks are inverted
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

%% Preview: analyze only the first data segment; nothing saved
disp('Previewing first data segment (nothing will be saved)...')
analyze_freq_data(run_params, freqfile, timefile, vsfile, rev_peaks_invert, 1);

fclose('all');
disp('Preview complete.')
