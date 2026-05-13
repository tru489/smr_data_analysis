function paired_data = pair_density_trap(run_params, fluid1_datasmr, ...
    fluid2_datasmr, cal_params, ...
    bl_dens_cal_params, fl1_ref_freq, fl2_ref_freq)
% Takes preprocessed data files from peak detection and pairs measurements
% based on valve states and times
% 
% Arguments:
%   run_params (struct): running parameters for analysis
%       fluid_1_datasmr (array(double)): summary file from peak detection 
%       for cells in fluid 1
%   fluid_1_pk_direct (array(double)): peak direction cells in fluid 1.
%       1 indicates cells more dense than fluid, -1 indicates cells
%       less dense than fluid
%   fluid_2_datasmr (array(double)): summary file from peak detection 
%       for cells in fluid 2
%   fluid_2_pk_direct (array(double)): peak direction cells in fluid 2.
%       1 indicates cells more dense than fluid, -1 indicates cells
%       less dense than fluid
%   cal_params (struct): mass calibration parameters
%   bl_dens_cal_params (struct): density baseline calibration parameters
%   fl1_ref_freq (double): feedback frequency reference for fluid 1
%   fl2_ref_freq (double): feedback frequency reference for fluid 2
% Returns:
%   paired_datasmr (table): paired peak data with volume and
%       density (or dry volume/dry density)

%% Calibration data
intercept = bl_dens_cal_params.intercept;
slope = bl_dens_cal_params.slope;
mass_cal_factor = cal_params.cal_factor_pg_per_hz;

%% Unload run params
% Valve state codes indicating whether fluid is in first or second density
% trap fluid
f1_vstate = run_params.density_trap.fluid1_vstate;
f2_vstate = run_params.density_trap.fluid2_vstate;

% Maximum backflush time allowed for reverse peaks to arrive
max_time_gap = run_params.density_trap.max_time_gap / 1000; % ms

% Maximum time gap between adjacent forward peaks
min_forward_gap = run_params.density_trap.min_forward_gap / 1000; % ms

% Density range in which paired forward and reverse peaks are acceptable
candidate_pair_dens_window = run_params.density_trap.candidate_pair_dens_window;

%% Pairing
% Multiply the appropriate columns by peak direction to account for the 
% fact that the fluid is more/less dense than the measured particles

% Concatenate and sort peaks
fluid1_datasmr = fluid1_datasmr(fluid1_datasmr.valve_state == f1_vstate, :);
fluid2_datasmr = fluid2_datasmr(fluid2_datasmr.valve_state == f2_vstate, :);
full_datasmr = [fluid1_datasmr; fluid2_datasmr];
sorted_full = sortrows(full_datasmr, 'peak_time_s');

%% Pairing algorithm
% Iterate through rows of full sorted peak list. Pull out groups of peaks
% (i.e. measurements in high and low density fluids) that:
% Old pairing algorithm:
%   1. contains a single first peak in fluid 1 (i.e. instances where 
%       there are multiple peaks in fluid 1 before a peak in fluid 2 will 
%       be discarded)
%   2. has an immediate subsequent second peak in fluid 2
%   3. the time between these peaks is less than the threshold manually set
%   4. there contains exactly one peak in fluid 1 before the
%       next peak in fluid 2
%
% New pairing algorithm: 
%      Same principle as old algorithm, but considers multiple forward and
%      backward peaks as candidate peaks within each trap. Discriminates
%      between multiple candidate peak pairs by taking each permutation of
%      forward and reverse peaks and calculating the dry properties of a
%      particle with those values. If the values are outside of a
%      specified reasonable range for those values, the candidate peak
%      pairing is rejected. After all permutations are considered, only the
%      unique pairing combinations that can be discriminated from all other
%      candidates (i.e. combinations with forward peaks that match with 
%      multiple backward peaks will be rejected, and vice versa) will be kept 
%      as the finalized, unique pairing.

vstates = sorted_full.valve_state;
times = sorted_full.peak_time_s;
group_indices = strfind(vstates', [f1_vstate, f2_vstate]);

num_f1_vstate = sum(vstates == f1_vstate);
num_f2_vstate = sum(vstates == f2_vstate);
pairable_indices = nan(max([num_f1_vstate, num_f2_vstate]), 1);
pair_id = 1;
pair_id_arr = nan(max([num_f1_vstate, num_f2_vstate]), 1);
for i = 1:length(group_indices)
    % Given initial forward-back adjacent pairs, select peaks around this
    % initial pairing to be considered for pairing within this single
    % individual particle trap
    fwd_idx = group_indices(i);
    fwd_t = times(fwd_idx);
    fwd_cand_idx = find(times > fwd_t - min_forward_gap & times <= fwd_t & vstates==f1_vstate);

    back_idx = group_indices(i) + 1;
    back_t = times(back_idx);
    back_cand_idx = find(times >= back_t & times < back_t + max_time_gap & vstates==f2_vstate);

    % If only one particle is detected for each of the forward and reverse
    % measurements during a peak, add this pairing to the pair array and
    % continue
    if length(fwd_cand_idx) == 1 && length(back_cand_idx) == 1
        pairable_indices(2*pair_id-1:2*pair_id) = [fwd_cand_idx, back_cand_idx];
        pair_id_arr(2*pair_id-1:2*pair_id) = [pair_id, pair_id];
        pair_id = pair_id + 1;
        continue;
    end
    
    if run_params.density_trap.use_multi_bead_pair
        % Iterate through each candidate pair and check if it is within the
        % target range
        cand_pair_bool_arr = zeros(length(fwd_cand_idx), length(back_cand_idx));
        for j = 1:length(fwd_cand_idx)
            for k = 1:length(back_cand_idx)
                fwd_idx_temp = fwd_cand_idx(j);
                back_idx_temp = back_cand_idx(k);
    
                fwd_cand_data = sorted_full(fwd_idx_temp, :);
                back_cand_data = sorted_full(back_idx_temp, :);
    
                [density_gcm3, ~] = calc_particle_dv_single(fwd_cand_data, back_cand_data, ...
                    fl1_ref_freq, fl2_ref_freq, intercept, slope, mass_cal_factor);
                cand_pair_bool_arr(j, k) = ...
                    candidate_pair_dens_window(1) < density_gcm3 & ...
                    candidate_pair_dens_window(2) > density_gcm3;
            end
        end
    
        % Parse candidate pair matrix to eliminate non-unique pairing
        % instances
        row_select_mask = sum(cand_pair_bool_arr, 2) == 1;
        col_select_mask = sum(cand_pair_bool_arr, 1) == 1;
    
        filt_fwd_cand_idx = fwd_cand_idx(row_select_mask);
        filt_back_cand_idx = back_cand_idx(col_select_mask);
        
        filt_bool_arr = cand_pair_bool_arr(row_select_mask, :);
        filt_bool_arr = filt_bool_arr(:, col_select_mask);
        if sum(filt_bool_arr, "all") == 0
            filt_bool_arr = [];
        end
    
        % Scan through filtered pair matrix to find unique pairing indices
        if ~isempty(filt_bool_arr)
            for m = 1:length(filt_fwd_cand_idx)
                fwd_unq_pair_idx = filt_fwd_cand_idx(m);
                back_unq_pair_idx = filt_back_cand_idx(filt_bool_arr(m, :) == 1);
        
                pairable_indices(2*pair_id-1:2*pair_id) = [fwd_unq_pair_idx, back_unq_pair_idx];
                pair_id_arr(2*pair_id-1:2*pair_id) = [pair_id, pair_id];
                pair_id = pair_id + 1;
            end
        end
    end
end
pairable_indices = pairable_indices(~isnan(pairable_indices));
paired_datasmr = sorted_full(pairable_indices, :);
paired_datasmr.pair_id = pair_id_arr(~isnan(pair_id_arr));
num_pairs = pair_id - 1;

%% Populate the output pairing summary file
fl1_bl_dens_gcm3 = zeros(num_pairs, 1);
fl2_bl_dens_gcm3 = zeros(num_pairs, 1);

bl1_avg = zeros(num_pairs, 1);
bl2_avg = zeros(num_pairs, 1);

density_gcm3 = zeros(num_pairs, 1);
volume_fl = zeros(num_pairs, 1);

fl1_pair = paired_datasmr(paired_datasmr.valve_state == f1_vstate, :);
fl1_pair_summ = ...
    renamevars(fl1_pair, fl1_pair.Properties.VariableNames, ...
    "fl1_" + fl1_pair.Properties.VariableNames);

fl2_pair = paired_datasmr(paired_datasmr.valve_state == f2_vstate, :);
fl2_pair_summ = ...
    renamevars(fl2_pair, fl2_pair.Properties.VariableNames, ...
    "fl2_" + fl2_pair.Properties.VariableNames);

for j = 1:num_pairs
    fwd_pk = fl1_pair_summ(fl1_pair_summ.fl1_pair_id == j, :);
    back_pk = fl2_pair_summ(fl2_pair_summ.fl2_pair_id == j, :);
    
    bl1_avg(j) = fwd_pk.fl1_avg_baseline(1);
    bl2_avg(j) = back_pk.fl2_avg_baseline(1);
end

fl1_bl_avg_hz = array2table(bl1_avg, 'VariableNames', {'fl1_bl_avg_hz'});
fl2_bl_avg_hz = array2table(bl2_avg, 'VariableNames', {'fl2_bl_avg_hz'});

paired_data = [fl1_pair_summ, fl1_bl_avg_hz, fl2_pair_summ, ...
    fl2_bl_avg_hz];

if ~run_params.analysis_type.dens_trap_base_freq_recal
    paired_data = ...
        calc_particle_dens_vol(paired_data, fl1_ref_freq, fl2_ref_freq, ...
        intercept, slope, mass_cal_factor);
    % paired_data = gate_outliers_dens_vol(paired_data);
else
    paired_data = optimize_base_freq_params(paired_data, fl1_ref_freq, ...
        fl2_ref_freq, intercept, slope, mass_cal_factor);
end

end