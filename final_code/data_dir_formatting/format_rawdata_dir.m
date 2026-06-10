% Automatically formats raw data directory based on default calibration
% file paths. Copies the calibration files from their sources into this dir
% for convenience.

close all;

run_params = load_run_params();

data_dir = uigetdir('A:\thomasu\raw_data');

default_cal_path = run_params.dir_formatting.default_cal_path;
f_handle = fopen(default_cal_path);
raw = fread(f_handle, inf);
str_json = char(raw');
format_defaults = jsondecode(str_json);
fclose(f_handle);

copyfile(format_defaults.mass_cal_path, data_dir)
copyfile(format_defaults.density_baseline_cal_path, data_dir)

