close all;
addpath(...
    "params", ...
    fullfile("analysis", "helpers"), ...
    fullfile("analysis", "peak_detection"), ...
    fullfile("analysis", "density_trapping"), ...
    fullfile("analysis", "mass_calibration"))

run_params = set_run_params();

%% Calibration types
% if run_params.analysis_type.mass_calibration
% 
% end

if run_params.analysis_type.base_freq_density_calibration
    base_freq_dens_cal(run_params)
end

%% Analysis types
if run_params.analysis_type.mass
    mass_preprocess(run_params)
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