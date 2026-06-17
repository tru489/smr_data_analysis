close all;
addpath(...
    genpath("final_code"),...
    genpath("helpers"))

% Choose whether to run parameters from those set in config.yaml, or to
% those in a log file from previous analysis
params_from_log = 0;

%% Set run params
if ~params_from_log
    run_params = load_run_params();
else
    run_params = get_json_struct('run parameter');
end

%% Calibration types
if run_params.analysis_type.mass_calibration
    calibrate_mass(run_params)
end

if run_params.analysis_type.base_freq_density_calibration
    base_freq_dens_cal(run_params)
end

if run_params.analysis_type.dens_trap_base_freq_recal
    recal_dens_params(run_params)
end

%% Analysis types
if run_params.analysis_type.mass
    analyze_mass(run_params)
end

if run_params.analysis_type.fl_excl
    analyze_fl_excl(run_params)
end

if run_params.analysis_type.density_trap
    analyze_density_trap(run_params)
end

if run_params.analysis_type.water_content
    analyze_water_content(run_params)
end
