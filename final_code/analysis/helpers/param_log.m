function param_log(run_params, save_dir)
% Save a log json file with all parameters used for a run of the code
%
% Arguments:
%   run_params (struct): running parameters necessary for analysis
%   save_dir (str): dir in which to save log file

jsonID = fopen(fullfile(save_dir + "log.json"), 'w');
js_str = jsonencode(run_params, PrettyPrint=true);
fprintf(jsonID, js_str);
fclose(jsonID);

end

