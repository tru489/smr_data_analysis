function run_params = load_run_params(config_path)
% Load run parameters from a YAML config file and build the run_params struct.
%
% Requires the MathWorks yaml toolbox (File Exchange ID 106765, R2020a+).
% Install via Add-Ons > Get Add-Ons, search "YAML".
%
% Arguments:
%   config_path (string, optional): absolute path to config YAML file.
%       Defaults to config.yaml in final_code/ (next to this file's parent dir).
% Returns:
%   run_params (struct): all parameters for running analysis scripts,
%       with the same field structure as previously returned by set_run_params().

arguments
    config_path string = ""
end

%% Resolve config file path
if config_path == ""
    this_dir = fileparts(mfilename('fullpath'));      % .../final_code/params
    config_path = fullfile(fileparts(fileparts(this_dir)), 'config.yaml');
end

if ~isfile(config_path)
    template_path = fullfile(fileparts(config_path), 'config.template.yaml');
    error(['config.yaml not found at: ' newline '  ' char(config_path) newline ...
           'Copy config.template.yaml to config.yaml and edit it:' newline ...
           '  ' char(template_path)]);
end

%% Parse YAML
cfg = yaml.loadFile(config_path);
repo_root = fileparts(config_path);

%% Map YAML sections to run_params struct
run_params.analysis_type   = cfg.analysis_type;
run_params.analysis_params = cfg.analysis_params;
run_params.prefs           = cfg.prefs;
run_params.mass_cal        = cfg.mass_cal;
run_params.density_trap    = cfg.density_trap;
run_params.curation        = cfg.curation;
run_params.bl_select       = cfg.bl_select;
run_params.fl_excl         = cfg.fl_excl;
run_params.vis             = cfg.vis;
run_params.dir_formatting  = cfg.dir_formatting;
run_params.backend         = cfg.backend;

%% Resolve relative paths to absolute paths
run_params.vis.ppt_template_abs_path = ...
    fullfile(final_code_dir, run_params.vis.ppt_template_abs_path);
run_params.dir_formatting.default_cal_path = ...
    fullfile(final_code_dir, run_params.dir_formatting.default_cal_path);

%% Normalize arrays to row vectors (yaml toolbox may return column vectors)
run_params.fl_excl.detect_thresh_pmt = ...
    reshape(run_params.fl_excl.detect_thresh_pmt, 1, []);
run_params.prefs.multi_offset_threshold = ...
    reshape(run_params.prefs.multi_offset_threshold, 1, []);
run_params.density_trap.candidate_pair_dens_window = ...
    reshape(run_params.density_trap.candidate_pair_dens_window, 1, []);

%% Apply derived backend parameters and validate
run_params = modify_backend_params(run_params);
validate_params(run_params);

end
