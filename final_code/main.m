close all;
addpath(...
    genpath("params"), ...
    genpath("analysis"))

run_params = set_run_params();

%% Calibration types
if run_params.analysis_type.mass_calibration
    calibrate_mass(run_params)
end

if run_params.analysis_type.base_freq_density_calibration
    base_freq_dens_cal(run_params)
end

%% Analysis types
if run_params.analysis_type.mass
    analyze_mass(run_params)
end

% if run_params.analysis_type.fl_excl
% 
% end
% 
% if run_params.analysis_type.density_trap
% 
% end
% 
% if run_params.analysis_type.water_content
% 
% end