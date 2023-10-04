% Resets the default parameters set for directory formatting, specifically
% changing the paths of the default calibration files to be copied during
% auto directory formatting into raw data folders

close all;

run_params = set_run_params();

default_cal_path = run_params.dir_formatting.default_cal_path;

json_read_id = fopen(default_cal_path);
raw = fread(json_read_id, inf);
str_json = char(raw');
format_defaults = jsondecode(str_json);
fclose(json_read_id);

exit_flag = 0;
while ~exit_flag
    disp('Reset default directory formatting preferences...')
    disp('    (1) to reset all preferences')
    disp('    (2) to reset mass calibration')
    disp('    (3) to reset density baseline calibration')
    inp = input('Input here: ');

    switch inp
        case {1, 2, 3}
            exit_flag = 1;
        otherwise
            exit_flag = 0;
            disp("Invalid input.")
    end
end

if inp == 2 || inp == 1
    disp("Select new mass calibration data...")
    [mc_path, mc_dir, ~] = uigetfile('../*.json', ...
        "Select mass calibration file", ' ');
    format_defaults.mass_cal_path = fullfile(mc_dir, mc_path);
end

if inp == 3 || inp == 1
    disp("Select new density baseline calibration data...")
    [dbc_path, dbc_dir, ~] = uigetfile('../*.json', ...
        "Select density baseline calibration file", ' ');
    format_defaults.density_baseline_cal_path = fullfile(dbc_dir, dbc_path);
end

json_write_id = fopen(default_cal_path, 'w');
js_str = jsonencode(format_defaults, PrettyPrint=true);
fprintf(json_write_id, js_str);
fclose(json_write_id);
