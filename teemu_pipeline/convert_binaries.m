function convert_binaries()
close all;

fprintf('Getting SMR data...\n')
[input_info.smr_filename, input_info.smr_dir, exist_smr] = ...
    uigetfile('../*.*','Select SMR File',' ');

% Load file if it exists
if(exist_smr ~= 0)
    smr_file_ID = fopen(strcat(input_info.smr_dir, ...
        input_info.smr_filename), 'r');
    fprintf('    %s selected for conversion\n', input_info.smr_filename)
else
    fprintf('Quitting conversion program now...')
    return
end

% User input for smr time file location
fprintf('Getting time data...\n')
[input_info.smr_time_filename, input_info.smr_time_dir, ...
    exist_time] = uigetfile('../*.*','Select time File',' ');

% Load time file if it exists
if(exist_time ~= 0)
    smr_time_file_ID = fopen(strcat(input_info.smr_time_dir, ...
        input_info.smr_time_filename), 'r', 'b');
    fprintf('    %s selected for conversion\n', ...
        input_info.smr_time_filename)
else
    fprintf('Quitting conversion program now...')
    return
end

rawdata_smr = read_freq_from_binary(smr_file_ID);
rawdata_smr = rawdata_smr';






% PUT A MEDIAN FILTER ON FREQ DATA TO FILTER OUT NOISE......
rawdata_smr = medfilt1(rawdata_smr, 3);





rawdata_smr_time = fread(smr_time_file_ID,'float64=>double');
rawdata_smr_time(1)=[];

smr_converted_ID = fopen([input_info.smr_dir, input_info.smr_filename, '_converted'],'w');
fwrite(smr_converted_ID, rawdata_smr, 'float64', 0, 'b');
fclose(smr_converted_ID);

smr_time_converted_ID = fopen([input_info.smr_time_dir, input_info.smr_time_filename, '_converted'],'w');
fwrite(smr_time_converted_ID, rawdata_smr_time, 'float64', 0, 'b');
fclose(smr_time_converted_ID);

end