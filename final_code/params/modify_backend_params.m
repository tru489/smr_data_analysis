function run_params = modify_backend_params(run_params)
% Based on parameters specified, does some backend modification of those
% parameters to properly run different analysis types
% 
% Arguments:
%   run_params (struct): running parameters for analysis

at = run_params.analysis_type;
is_density_trap = at.density_trap || at.water_content;

% If doing density trapping, use a slighly seperate parameter set (e.g. 
% quadratic baseline fitting)
if is_density_trap
    % IF DOING DENSITY TRAPPING:
    % Uses an extended search baseline segment for identifying edge indices of
    % peakset during baseline identification (perhaps not crucial)
    run_params.backend.extended_bl_detect = 1;
    
    % Determines baseline fit. Integer indicates polynomial order, string
    % indicates another fitting regime
    run_params.backend.baseline_fit_type = 2;
    % Determines whether to use nodes in baseline fitting
    run_params.backend.use_node_bl_fit = false;
    % Determines the weight to use for nodes in baseline fitting (integer
    % factor which node terms are multiplied by in linear regression error
    % function
    run_params.backend.node_bl_weight = 1;
    % Does not use a polynomial fit on antipeaks in peak fitter (perhaps not 
    % crucial)
    
    run_params.backend.antipeak_polyfit = 0;
    % Acquire a shorter baseline segment around each peakset for density 
    % trapping in order to better fit a quadratic baseline
    run_params.backend.shorter_baseline = 1;
    % Change the edge indices chosen for each peakset to for density
    % trapping to better fit quadratic baseline
    run_params.backend.adjusted_edge_indices = 1;
    % Use a different type of frequency data smoothing for density trapping
    run_params.backend.alternative_smoothing = 1;
    % Compensate for large baseline changes introduced by switching flow in
    % density trapping
    run_params.backend.compensate_baseline_fluct = 1;
    % When finding peaksets for mass data (not density trapping), used a
    % fixed threshold (variable threshold still used for initial single peak
    % detection)
    run_params.backend.fixed_peakset_thresh = 0;
else
    run_params.backend.extended_bl_detect = 0;
    
    run_params.backend.baseline_fit_type = 1;
    run_params.backend.use_node_bl_fit = false;
    run_params.backend.node_bl_weight = 1;

    run_params.backend.antipeak_polyfit = 1;
    run_params.backend.shorter_baseline = 0;
    run_params.backend.adjusted_edge_indices = 0;
    run_params.backend.alternative_smoothing = 0;
    run_params.backend.compensate_baseline_fluct = 0;
    run_params.backend.fixed_peakset_thresh = 1;
end

%% Validate analysis mode settings
% If rapid analysis is not selected, default to displaying progress
if ~run_params.analysis_params.analysismode
    run_params.analysis_params.dispprogress = 1;
end

%% Use preset baseline selection parameters
if run_params.bl_select.use_presets
    if is_density_trap
        % Estimated # datapoints for full transit
        run_params.bl_select.estimated_datapoints = 500;  %500
        % Estimate of baseline noise level
        run_params.bl_select.estimated_noise = 0.5;
        % Length of savitsky-golay filter to filter frequency data
        run_params.bl_select.sgolay_length_idx = 4;
        % Lower threshold to half-length (in datapoints) of data segment
        % surrounding a single peak
        run_params.bl_select.segment_threshold = 200;
        
        % Derivative threshold to find flat part of baseline
        run_params.bl_select.diff_threshold = 0.005; % 0.05
        % Window of median filter, which removes the flat part in the anti-node
        run_params.bl_select.med_filt_wd = 30; % 200
        % Derivative threshold used to remove the flat part in the anti-node
        run_params.bl_select.bs_dev_thres = 0.5; % 0.5
        % Distance over which there are unique 2nd mode peaks
        run_params.bl_select.unqPeakDist = 300; % 250
        % Baseline offset threshold to select for peaks
        run_params.bl_select.offset_input = 5; % 3 % 1
        
        % Choose the first point left/right of the secondary peaks 40% percent 
        % of the average baseline freqvalue
        run_params.bl_select.edgethres = 0.03; % 0.12
        % Allow 102% of the minimum standard deviation
        run_params.bl_select.stdevmultiplier = 3;
        % Allow 90% of the deviation from mean frequency closest to 2ndary peaks
        run_params.bl_select.diffmultiplier = 1;
        % Number of points searching for baseline collection
        run_params.bl_select.winsize = 50; % 120
    else
        % Estimated # datapoints for full transit
        run_params.bl_select.estimated_datapoints = 250;
        % Estimate of baseline noise level
        run_params.bl_select.estimated_noise = 2;
        % Length of savitsky-golay filter to filter frequency data
        run_params.bl_select.sgolay_length_idx = 4;
        % Lower threshold to half-length (in datapoints) of data segment
        % surrounding a single peak
        run_params.bl_select.segment_threshold = 200;
        
        % Derivative threshold to find flat part of baseline
        run_params.bl_select.diff_threshold = 0.005;
        % Window of median filter, which removes the flat part in the anti-node
        run_params.bl_select.med_filt_wd = 200;
        % Derivative threshold used to remove the flat part in the anti-node
        run_params.bl_select.bs_dev_thres = 0.5;
        % Distance over which there are unique 2nd mode peaks
        run_params.bl_select.unqPeakDist = 250;
        % Baseline offset threshold to select for peaks
        run_params.bl_select.offset_input = 3; % 3
        
        % Choose the first point left/right of the secondary peaks 40% percent of the average baseline freqvalue
        run_params.bl_select.edgethres = 0.12;
        % Allow 102% of the minimum standard deviation
        run_params.bl_select.stdevmultiplier = 3;
        % Allow 90% of the deviation from mean frequency closest to 2ndary peaks
        run_params.bl_select.diffmultiplier = 1;
        % Number of points searching for baseline collection
        run_params.bl_select.winsize = 120;
    end
end

