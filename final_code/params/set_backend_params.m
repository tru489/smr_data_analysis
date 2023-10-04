function run_params = set_backend_params(run_params)
% Set backend parameters (data analysis parameters that will likely not
% have to be changed
% 
% Arguments: 
%   run_params (struct): running parameters for analysis
% Returns:
%   run_params (struct): running parameters for analysis with backend
%       parameters added

%% Frequency data parsing
% Size (in datapoints of each data segment) to be read in from full 
% freqeuency/time paired dataset
run_params.backend.datasize = 2e6;

%% Peakset data summary indices
% Sets indices for columns of peakset summary dataset. The fields below
% (top to bottom as listed here) are:
% The following are the column labels for each column in the summary data:
%   (1) real_time_s (global time in seconds at which peak ocurred )
%   (2) peak_time_s (time at which peak occurred in seconds)
%   (3) peak_time_m (time at which peak occurred in minutes)
%   (4) avg_pk_ht_hz (mean of secondary peak heights in hz)
%   (5) avg_baseline (average baseline of left and right peaks)
%   (6) bl_slope (baseline slope)
%   (7) pk_ht1_hz (height of peak 1)
%   (8) pk_ht2_hz (height of peak 2)
%   (9) pk_ht3_hz (height of peak 3)
%   (10) node_dev_1 (node deviation of node 1)
%   (11) node_dev_2 (node deviation of node 2)
%   (12) node_dev_mean (mean of node deviations)
%   (13) pk_fwhm (FWHM of first peak)
%   (14) transit_t (transit time in ms of particle)
%   (15) segment_num (segment number in which peak ocurred)
%   (16) peak_time_h (time at which peak occurred in hours)
%   (17) pk_order (peak index within total peak list)
%   (18) valve_state (valve state at time of peakset; set to 0 for analysis 
%       types that do not use valve state)
%   (19) mass_pg (calibrated mass of particle in pg)

% run_params.pkset_summ_idx.real_time_s = 1;
% run_params.pkset_summ_idx.peak_time_s = 2;
% run_params.pkset_summ_idx.peak_time_m = 3;
% run_params.pkset_summ_idx.avg_pk_ht_hz = 18;
% run_params.pkset_summ_idx.avg_baseline = 5;
% run_params.pkset_summ_idx.bl_slope = 6;
% run_params.pkset_summ_idx.pk_ht1_hz = 12;
% run_params.pkset_summ_idx.pk_ht2_hz = 13;
% run_params.pkset_summ_idx.pk_ht3_hz = 14;
% run_params.pkset_summ_idx.node_dev_1 = 15;
% run_params.pkset_summ_idx.node_dev_2 = 16;
% run_params.pkset_summ_idx.node_dev_mean = 17;
% run_params.pkset_summ_idx.pk_fwhm = 7;
% run_params.pkset_summ_idx.transit_t = 8;
% run_params.pkset_summ_idx.segment_num = 11;
% run_params.pkset_summ_idx.peak_time_h = 4;
% run_params.pkset_summ_idx.pk_order = 10;
% run_params.pkset_summ_idx.valve_state = 9;
% run_params.pkset_summ_idx.mass_pg = 19;

% Indices specifically for the summary data file for density trapping analysis. 
% The fields below (top to bottom as listed here) are:
%   (1) Time of peak in fluid 1 (min)
%   (2) Average frequency difference in fluid 1 (Hz)
%   (3) Slope of baseline in fluid 1
%   (4) Average of baseline in fluid 1 (Hz)
%   (5) Estimated density of fluid 1 (Hz)
%   (6) Peak 1 height in fluid 1 (Hz)
%   (7) Peak 2 height in fluid 1 (Hz)
%   (8) Peak 3 height in fluid 1 (Hz)
%   (9) Time of peak in fluid 2 (min)
%   (10) Average frequency difference in fluid 2 (Hz)
%   (11) Slope of baseline in fluid 2
%   (12) Average of baseline in fluid 2 (Hz)
%   (13) Estimated density of fluid 2 (Hz)
%   (14) Peak 1 height in fluid 2 (Hz)
%   (15) Peak 2 height in fluid 2 (Hz)
%   (16) Peak 3 height in fluid 2 (Hz)
%   (17) Particle density (g/cm^3)
%   (18) Volume (fl)

% run_params.pkset_summ_idx_dt.fl1_real_time_s = 1;
% run_params.pkset_summ_idx_dt.fl1_pk_time_min = 2;
% run_params.pkset_summ_idx_dt.fl1_avg_pk_ht_hz = 3;
% run_params.pkset_summ_idx_dt.fl1_bl_slope = 4;
% run_params.pkset_summ_idx_dt.fl1_bl_avg_hz = 5;
% run_params.pkset_summ_idx_dt.fl1_bl_dens_gcm3 = 6;
% run_params.pkset_summ_idx_dt.fl1_pk_ht_1_hz = 7;
% run_params.pkset_summ_idx_dt.fl1_pk_ht_2_hz = 8;
% run_params.pkset_summ_idx_dt.fl1_pk_ht_3_hz = 9;
% 
% run_params.pkset_summ_idx_dt.fl2_real_time_s = 10;
% run_params.pkset_summ_idx_dt.fl2_pk_time_min = 11;
% run_params.pkset_summ_idx_dt.fl2_avg_pk_ht_hz = 12;
% run_params.pkset_summ_idx_dt.fl2_bl_slope = 13;
% run_params.pkset_summ_idx_dt.fl2_bl_avg_hz = 14;
% run_params.pkset_summ_idx_dt.fl2_bl_dens_gcm3 = 15;
% run_params.pkset_summ_idx_dt.fl2_pk_ht_1_hz = 16;
% run_params.pkset_summ_idx_dt.fl2_pk_ht_2_hz = 17;
% run_params.pkset_summ_idx_dt.fl2_pk_ht_3_hz = 18;
% run_params.pkset_summ_idx_dt.density_gcm3 = 19;
% run_params.pkset_summ_idx_dt.volume_fl = 20;

end

