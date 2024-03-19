function save_abs_path = create_results_dir(run_params, data_dir)
% Creates a directory in which to save results from analysis
%
% Arguments:
%   run_params (struct): running parameters for analysis
%   data_dir (str): directory in which to create results folder

analysis_name = get_analysis_type(run_params);

timestamp = string(datetime('now', 'TimeZone', 'local', ...
    'Format', 'yyyyMMdd.HHmmss'));

dir_name = timestamp + "_" + analysis_name + "_results";

mkdir(fullfile(data_dir, dir_name))
save_abs_path = fullfile(data_dir, dir_name);

end