function [parsed_files, dirpath, date] = parse_dir_contents(file_selection)
% Upon selection of a directory where data is stored, parses directory
% contents to return relevant data/file handles. Regardless of file
% selection, always returns SMR time and frequency file handles
% 
% Arguments:
%   file_selection (struct): preferences for file types required for
%       certain analysis type. Always includes the following fields:
%           valve_state: valve state binary file IDs
%           mass_cal: mass calibration json file
%           dens_bl_cal: density baseline calibration json file
%           pmt_data: PMT frequency and time data binary file IDs
%           cc_data: coulter counter .#m4 file
% Returns:
%   parsed_files (struct): file data for parsed files. Contains the
%       following fields (unused fields are set as NaN):
%           freq_id: file id of frequency file
%           smr_time_id: file id of time file for SMR data
%           vs_id: file id of valve state file
%           mass_cal: struct containing mass calibration parameters
%           dens_bl_cal: struct containing mass baseline calibration
%           pmt_channels_id: array of file ids for PMT channels
%           pmt_time_id: file id of time file for PMT data
%           cc_data: table of coulter counter data
%   dirpath (str): path to data directory
%   date (str): formatted datestring at which data was collected

% Get path of dir containing data
disp('Select data folder...')
dirpath = uigetdir('A:\thomasu\raw_data', 'Select data folder...');
files = dir(dirpath);
contents = {files(~[files.isdir]).name};
contents = contents(~ismember(contents ,{'.','..'}));

% Get frequency file
[freq_id, date] = match_rawdata_file(dirpath, contents, 'frequency', ...
    '^\d+\.\d+_frequencies$');
parsed_files.freq_id = freq_id;

% Get SMR time file
smr_time_id = match_rawdata_file(dirpath, contents, 'smr time', ...
    '^\d+\.\d+_time$');
parsed_files.smr_time_id = smr_time_id;

% Get valve state file
if file_selection.valve_state
    vs_id = match_rawdata_file(dirpath, contents, 'valve state', ...
        '^\d+\.\d+_valvestates$');
    parsed_files.vs_id = vs_id;
else
    parsed_files.vs_id = nan;
end

% Get mass calibration file
if file_selection.mass_cal
    fname_match = regexp(contents, '^\d+_\d+um_mass_calibration.json$', ...
        'match');
    fname_match = fname_match(~cellfun('isempty', fname_match));

    if length(fname_match) == 1
        f_handle = fopen(fullfile(dirpath, fname_match{1}{1}));
        raw = fread(f_handle, inf);
        str_json = char(raw');
        parsed_files.mass_cal = jsondecode(str_json);
    elseif length(fname_match) > 1
        error("RuntimeError: Multiple mass calibration .json files detected")
    else
        error("RuntimeError: No mass calibration .json file detected")
    end
else
    parsed_files.mass_cal = nan;
end

% Get density baseline calibration file
if file_selection.dens_bl_cal
    fname_match = regexp(...
        contents, '^\d+_density_baseline_calibration.json$', 'match');
    fname_match = fname_match(~cellfun('isempty', fname_match));

    if length(fname_match) == 1
        f_handle = fopen(fullfile(dirpath, fname_match{1}{1}));
        raw = fread(f_handle, inf);
        str_json = char(raw');
        parsed_files.dens_bl_cal = jsondecode(str_json);
    elseif length(fname_match) > 1
        error("RuntimeError: Multiple density baseline calibration " + ...
            ".json files detected")
    else
        error("RuntimeError: No density baseline calibration " + ...
            ".json file detected")
    end
else
    parsed_files.dens_bl_cal = nan;
end

% Get PMT channels and time data
if file_selection.pmt_data
    pmt_channels_id = match_rawdata_file(dirpath, contents, 'PMT channels', ...
        '^\d+\.\d+_PMT_ch\d.bin$', 1);
    parsed_files.pmt_channels_id = pmt_channels_id;
    
    pmt_time_id = match_rawdata_file(dirpath, contents, 'PMT time', ...
        '^\d+\.\d+_PMT_time.bin$');
    parsed_files.pmt_time_id = pmt_time_id;
else
    parsed_files.pmt_channels_id = nan;
    parsed_files.pmt_time_id = nan;
end

if file_selection.cc_data
    fname_match = regexp(contents, '^.+\.#m4$', 'match');
    fname_match = fname_match(~cellfun('isempty', fname_match));

    if length(fname_match) == 1
        file = fullfile(dirpath, fname_match{1}{1});
        parsed_files.cc_data = readtable(file, 'FileType', 'text', ...
            'Delimiter', ' ');
    elseif length(fname_match) > 1
        error("RuntimeError: Multiple coulter counter .#m4 files detected")
    else
        error("RuntimeError: No coulter counter .#m4 file detected")
    end
else
    parsed_files.cc_data = nan;
end

end

