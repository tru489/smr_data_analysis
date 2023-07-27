function save_abs_path = create_results_dir(run_params, data_dir)
% Creates a directory in which to save results from analysis
%
% Arguments:
%   run_params (struct): running parameters for analysis
%   data_dir (str): directory in which to create results folder

fields = fieldnames(run_params.analysis_type);
for i = 1:length(fields)
    if run_params.analysis_type.(fields{i})
        analysis_name = fields{i};
        break;
    end
end

timestamp = string(datetime('now', 'TimeZone', 'local', ...
    'Format', 'yyyyMMdd.HHmmss'));

dir_name = timestamp + "_" + analysis_name + "_results";

mkdir(fullfile(data_dir, dir_name))
save_abs_path = fullfile(data_dir, dir_name);
disp('Analysis complete.')

end