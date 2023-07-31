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
run_params.analysis_type.mass_calibration = 1;
% Performs density calibration from data from different density fluids
run_params.analysis_type.base_freq_density_calibration = 0;

% --------------------------- Analysis types ---------------------------
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

%% Analysis mode (for all analysis types)
% Analysis mode; false stops at each peak, true runs through all peaks
run_params.analysis_params.analysismode = 1;
% Display progress with plots
run_params.analysis_params.dispprogress = 0;

%% Peak analysis preferences
% Manually curate peaks
run_params.prefs.manual_curation = 0;

%% Mass calibration preferences
% Save peak summary raw data
run_params.mass_cal.save_peak_summary = 1;

%% Density trapping analysis preferences
% Valve state codes indicating whether fluid is in first or second density
% trap fluid
run_params.density_trap.fluid1_vstate = 11;
run_params.density_trap.fluid2_vstate = 7;

% Whether or not to save paired data 
run_params.density_trap.save_pairing = 1;

%% Peak curation preferences
% Peak imbalance threshold; max fraction of average of peaks 1 and 3 in 
% which the secondary peaks are allowed to differ in height
run_params.curation.pk_imbal_thresh = 0.5;
% Node imbalance threshold; max fraction of average of peaks 1 and 3 in 
% which the node heights are allowed to differ
run_params.curation.nod_imbal_thresh = 0.5;
% Node deviation threshold; max fraction of the average of peaks 1 and 3
% allowed for the average node deviation
run_params.curation.nod_dev_thresh = 0.4;

% Display baseline fit for each peak when curating
run_params.curation.disp_bl_fit = 1;

% Automatically reject peaks based on auto-reject criteria EVEN IF manual
% peak curation is not picked
run_params.curation.always_auto_reject = 1;

%% Mass baseline selection params
% Estimated # datapoints for full transit
run_params.bl_select.estimated_datapoints = 500;
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
run_params.bl_select.offset_input = 3;

% Choose the first point left/right of the secondary peaks 40% percent of the average baseline freqvalue
run_params.bl_select.edgethres = 0.12;
% Allow 102% of the minimum standard deviation
run_params.bl_select.stdevmultiplier = 3;
% Allow 90% of the deviation from mean frequency closest to 2ndary peaks
run_params.bl_select.diffmultiplier = 1;
% Number of points searching for baseline collection
run_params.bl_select.winsize = 120;

%% Backend parameters for data processing
run_params = set_backend_params(run_params);

%% Input validation
validate_params(run_params)

end