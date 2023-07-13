close all;
addpath(...
    "params", ...
    "analysis", ...
    "analysis" + filesep + "helpers", ...
    "analysis" + filesep + "peak_detection")

run_params = set_run_params();

if run_params.analysis_type.mass
    mass_preprocess(run_params)
end

if run_params.analysis_type.fl_excl

end

if run_params.analysis_type.density_trap

end

if run_params.analysis_type.water_content

end