function run_params = set_run_params()
% Set parameters for running preprocessing scripts for SMR data,
% SMR/fluorescence data, density trapping, etc.
% 
% Returns: 
%   run_params (struct): all parameters necessary for running
%       peak analysis scripts

%% Choose analysis type to run
% ------------------------- Calibration types -------------------------
% Performs mass calibration from bead data
run_params.analysis_type.mass_calibration = 0;
% Performs density calibration from data from different density fluids
run_params.analysis_type.base_freq_density_calibration = 0;
% Performs empirical correction of density baseline calibration using
% mixture of different sizes of beads
run_params.analysis_type.dens_trap_base_freq_recal = 0;

% --------------------------- Analysis types ---------------------------
% Calculates mass measurements from freq/time data
run_params.analysis_type.mass = 1;
% Calculates mass/volume from freq/time/fluorescence data
run_params.analysis_type.fl_excl = 0;
% Calculates density/volume from density trapping data
run_params.analysis_type.density_trap = 0;
% Calculates water content from density trapping with D2O (i.e. freq in two
% fluids/time/fluorescence data)
run_params.analysis_type.water_content = 0;

%% Analysis mode
% Use rapid analysis mode; false stops at each peak, true runs through all peaks
run_params.analysis_params.analysismode = 1;
% Display progress with plots. If rapid analysis mode is not used, this
% defaults to true
run_params.analysis_params.dispprogress = 0;

% Use rapid analysis mode for pmt analysis code
run_params.analysis_params.analysismode_pmt = 1;
% Display progress with plots for pmt analysis
run_params.analysis_params.dispprogress_pmt = 0;

% Display intermediate plots/print statements in fast mode?
run_params.analysis_params.verbose = 0;

%% General peak analysis preferences
% Manually curate peaks
run_params.prefs.manual_curation = 0;

% Option to load curation preferences in from a previous curation session.
% Requires the same peak selection parameters to be used (i.e. the number
% of peaks between the previous session and this one must be the same)
run_params.prefs.load_previous_curation = 0;

%% Special preferences for multi-size bead analysis
% Stiff particles like beads require multiple thresholds to deal with
% variable node deviation across particle sizes. Enables an option to
% iterate through multiple offset thresholds to identify all possible
% peaks. Identifies duplicate peaks across conditions using a time
% threshold; if there are conflicts between peaks detected from separate
% offsets, preference is given to dataset with earlier index below (i.e. index 
% 1 in multi_offset_threshold is given priority 1, index 2 is given 2, etc)
run_params.prefs.multisz_bead_analysis = 0;
run_params.bl_select.multi_offset_threshold = [25, 5, 2];

%% Mass calibration preferences
% Save peak summary raw data
run_params.mass_cal.save_peak_summary = 1;

%% General density trapping analysis preferences
% Valve state codes indicating whether fluid is in first or second density
% trap fluid
run_params.density_trap.fluid1_vstate = 11; % 11 nl
run_params.density_trap.fluid2_vstate = 7; % 7 nl

% Maximum backflush time allowed for reverse peaks to arrive
run_params.density_trap.max_time_gap =  10000; % ms

% Maximum time gap between adjacent forward peaks
run_params.density_trap.min_forward_gap = 200; % ms

% Use multiple bead pairing to pair multiple beads within a single trap
% (using above thresholding)
run_params.density_trap.use_multi_bead_pair = 1;
% Density range in which paired forward and reverse peaks are acceptable
run_params.density_trap.candidate_pair_dens_window = [1.2, 1.8]; % g/cm3

% Whether or not to save unpaired data
run_params.density_trap.save_unpaired = 1;

%% Peak curation preferences
% Peak imbalance threshold; max fraction of average of peaks 1 and 3 in 
% which the secondary peaks are allowed to differ in height
run_params.curation.pk_imbal_thresh = 0.5; % 0.5
% Node imbalance threshold; max fraction of average of peaks 1 and 3 in 
% which the node heights are allowed to differ
run_params.curation.nod_imbal_thresh = 0.5; % 0.5
% Node deviation threshold; max fraction of the average of peaks 1 and 3
% allowed for the average node deviation
run_params.curation.nod_dev_thresh = 0.4; % 0.4
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
% Display baseline fit for each peak when curating
run_params.curation.disp_bl_fit = 1;

% Automatically reject peaks based on auto-reject criteria 
run_params.curation.auto_rejection = 1;

%% Mass baseline selection params
% Use preset parameter sets (presets override parameters set below)
run_params.bl_select.use_presets = 1;

% Estimated # datapoints for full transit
run_params.bl_select.estimated_datapoints = 500; % 500
% Estimate of baseline noise level
run_params.bl_select.estimated_noise = 0.5;
% Length of savitsky-golay filter to filter frequency data
run_params.bl_select.sgolay_length_idx = 4;
% Lower threshold to half-length (in datapoints) of data segment
% surrounding a single peak
run_params.bl_select.segment_threshold = 200;
 
% Derivative threshold to find flat part of baseline
run_params.bl_select.diff_threshold = 0.05; % 0.005
% Window of median filter, which removes the flat part in the anti-node
run_params.bl_select.med_filt_wd = 30; % 200
% Derivative threshold used to remove the flat part in the anti-node
run_params.bl_select.bs_dev_thres = 0.5; % 0.5
% Distance over which there are unique 2nd mode peaks
run_params.bl_select.unqPeakDist = 300; % 250 % 300
% Baseline offset threshold to select for peaks
run_params.bl_select.offset_input = 5; % 3

% Choose the first point left/right of the secondary peaks 40% percent of the average baseline freqvalue
run_params.bl_select.edgethres = 0.12;
% Allow 102% of the minimum standard deviation
run_params.bl_select.stdevmultiplier = 3;
% Allow 90% of the deviation from mean frequency closest to 2ndary peaks
run_params.bl_select.diffmultiplier = 1;
% Number of points searching for baseline collection
run_params.bl_select.winsize = 50; % 120

%% Fluorescent exclusion parameters
% ------------------------- Running parameters -------------------------
% Save peakset summary from frequency data only
run_params.fl_excl.save_peakset_summ = 1;

% Number of PMT channels
run_params.fl_excl.n_pmt_channel = 5;

% ------------------------- Peak selection parameters -------------------------
% Estimated peak width
run_params.fl_excl.Peak_length = 50;
% Establish a segment size (~32Mbytes)
run_params.fl_excl.datasize = 2e4;

% Rough quality check on PMT data being above minimum expected voltage, 
% default is -20 for populational fSMR experiments where light source is 
% always on
run_params.fl_excl.Baseline_rough_cutoff = -20; 
% Full PMT data median filter window size, default 50
run_params.fl_excl.med_filt_length = 5;
% Full PMT data moving-average filter window size, default 5
run_params.fl_excl.moving_average_window_size = 5;
% Baseline median filter window size, sampling distance for extrapolating flat 
% baseline   
run_params.fl_excl.med_filt_window_size = 3 * run_params.fl_excl.Peak_length;
% Minimum distance between peaks, for identifying unique peaks
run_params.fl_excl.min_distance_btw_peaks = 50;
% Number of data points from each side of detection cutoff to be considered as 
% part of the peak
run_params.fl_excl.uni_peak_range_ext = 5;
% Length of data points from each side of detection cutoff to compute the 
% local baseline
run_params.fl_excl.uni_peak_baseline_window_size = 100;

% Below is for choosing which side of the baseline to use when analyzing
% fluorescence exclusion signal. Fxm baseline is flow rate dependent so
% there might be systemetic differences from on side to the other.
% Recommendation: when fluorescence-detection region is close to SMR
% cantiliver, choose the side where cell are travelling the fastest
% (i.e. steady state flow)
% left baseline -> 1
% right baseline -> 2
% average baseline from both side -> 3
run_params.fl_excl.fxm_baseline_choice = 2;

% This is for setting detection threshold for each PMT channel,
% threshold is in the unit of standard deviation of baseline amplitude
% i.e. noise level
% *************** IMPORTANT ******************
% For fluorescence exclusion threshold, always use a negative value,
% and still postitive threshold for downstream channels
run_params.fl_excl.detect_thresh_pmt(1) = -2.5; % -2.5 nl 
run_params.fl_excl.detect_thresh_pmt(2) = 10; 
run_params.fl_excl.detect_thresh_pmt(3) = 10;
run_params.fl_excl.detect_thresh_pmt(4) = 10;
run_params.fl_excl.detect_thresh_pmt(5) = 10;

% For upstream compensation. 0 implies no compensation from upstream channel 
% of fxm channel to initialize
run_params.fl_excl.upstream_compen = 0;

% For signal QC filtering:
% Cutoff for left-right baseline height difference normalized by the signal 
% amplitude
run_params.fl_excl.thresh_baselineDiff_over_sig = 0.05;
% Cutoff for left-right baseline slopes
run_params.fl_excl.thresh_base_slope = 2*10^-3;
run_params.fl_excl.thresh_base_height_range = 0.05; % nl 0.05

% Use calibration with coulter counter data, or use manually input
% parameter?
run_params.fl_excl.use_coulter_calibration = 1;
run_params.fl_excl.manual_fl_per_au_cal_factor = 17.29258035;

%% Visualization preferences
% Create matlab figure windows when analysis is complete
run_params.vis.disp_fig_windows = 0;
% Automatically open powerpoint presentation when analysis is complete
run_params.vis.open_ppt = 1;
% Powerpoint template absolute path 
run_params.vis.ppt_template_abs_path = "C:\thomasu\smr_data_analysis\" + ...
    "final_code\visualization\template.potx";

%% Backend parameters for data processing
run_params = set_backend_params(run_params);

%% Backend parameter modification for some types of analysis
run_params = modify_backend_params(run_params);

%% Automated raw data dir formatting
% Dir in which default calibration path parameters are saved
run_params.dir_formatting.default_cal_path = ...
    "C:\thomasu\smr_data_analysis\" + ...
    "final_code\data_dir_formatting\default_cal_paths.json";

%% Input validation
validate_params(run_params);

end