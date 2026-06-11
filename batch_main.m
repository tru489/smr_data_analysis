close all;
addpath(...
    genpath("final_code\params"), ...
    genpath("final_code\analysis"), ...
    genpath("final_code\scripts"), ...
    genpath("final_code\visualization"), ...
    genpath("final_code\data_dir_formatting"), ...
    genpath("helpers"))

%% Load parameters
run_params = load_run_params();

% Batch mode: interactive curation is incompatible with an unattended loop
run_params.prefs.manual_curation = false;
run_params.prefs.load_previous_curation = false;

%% Select superdir
superdir = uigetdir('A:\thomasu\raw_data', 'Select parent directory to batch analyze...');
if isequal(superdir, 0), error('No directory selected.'); end

%% Collect immediate subdirectories
entries = dir(superdir);
subdirs = entries([entries.isdir] & ~ismember({entries.name}, {'.', '..'}));
if isempty(subdirs)
    error('No subdirectories found in: %s', superdir)
end
fprintf('Found %d subdirectories to analyze.\n', numel(subdirs))

%% Ask shared questions once (applied to every subdir)
flag = 1;
while flag
    peak_reversal = input('Are peaks inverted? (y/n): ', 's');
    if lower(peak_reversal) == 'y'
        flag = 0; rev_peaks_invert = 1;
    elseif lower(peak_reversal) == 'n'
        flag = 0; rev_peaks_invert = 0;
    else
        disp('Invalid input.')
    end
end

%% Loop over subdirs
failed = {};
for i = 1:numel(subdirs)
    data_dir = fullfile(superdir, subdirs(i).name);
    fprintf('\n[%d/%d] Processing: %s\n', i, numel(subdirs), subdirs(i).name)
    try
        analyze_mass(run_params, data_dir, rev_peaks_invert);
    catch err
        warning('Failed on %s:\n  %s', subdirs(i).name, err.message)
        failed{end+1} = subdirs(i).name; %#ok<AGROW>
    end
end

%% Summary
fprintf('\nBatch complete: %d/%d succeeded.\n', numel(subdirs) - numel(failed), numel(subdirs))
if ~isempty(failed)
    fprintf('Failed directories:\n')
    for i = 1:numel(failed)
        fprintf('  %s\n', failed{i})
    end
end
