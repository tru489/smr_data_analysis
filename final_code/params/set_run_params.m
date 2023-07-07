function run_params = set_run_params()
% Set parameters for running preprocessing scripts for SMR data,
% SMR/fluorescence data, density trapping, etc.
% 
% Returns: 
%   run_params (struct): all parameters necessary for running
%       preprocessing scripts

%% Choose analysis type to run
% Calculates mass measurements from freq/time data
run_params.analysis_type.mass = 0;
% Calculates mass/volume from freq/time/fluorescence data
run_params.analysis_type.fl_excl = 0;
% Calculates density/volume from density trapping data (i.e. freq in two 
% fluids/time data) 
run_params.analysis_type.density_trap = 0;
% Calculates water content from density trapping with D2O (i.e. freq in two
% fluids/time/fluorescence data)
run_params.analysis_type.water_content = 0;

%% Preprocessing preferences
% Manually curate peaks
run_params.prefs.manual_curation = 0;

%% Mass baseline selection params
% Estimated # datapoints for full transit
run_params.bl_select.estimated_datapoints = 500;
% Estimate of baseline noise level
run_params.bl_select.estimated_noise = 2;

% Derivative threshold to find flat part of baseline
run_params.bl_select.diff_threshold = 0.005;
% Window of median filter, which removes the flat part in the anti-node
run_params.bl_select.med_filt_wd = 200;
% Derivative hreshold used to remove the flat part in the anti-node
run_params.bl_select.bs_dev_thres = 0.5;
% Distance over which there are unique 2nd mode peaks
run_params.bl_select.unqPeakDist = 250;
% Baseline offset threshold to select for peaks
run_params.bl_select.offset_input = 3;

% Choose the first point left/right of the secondary peaks 40% percent of the average baseline freqvalue
run_params.bl_select.edgethres = 0.12;
% Allow 102% of the minimum standard deviation
run_params.bl_select.stdevmultiplier = 3;
% Allow 90% of the deviation from mean frequency closest to 2ndary peaks
run_params.bl_select.diffmultiplier = 1;
% Number of points searching for baseline collection
run_params.bl_select.winsize = 120;

%% Input validation
validate_params(run_params)

end