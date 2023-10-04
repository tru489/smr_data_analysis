function paired_data = pair_density_trap(run_params, fluid1_datasmr, ...
    fluid1_pk_direct, fluid2_datasmr, fluid2_pk_direct, cal_params, ...
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

%% Unload run params
% Valve state codes indicating whether fluid is in first or second density
% trap fluid
f1_vstate = run_params.density_trap.fluid1_vstate;
f2_vstate = run_params.density_trap.fluid2_vstate;

% Maximum time gap between peaks in fluid 1 and fluid 2
max_time_fl1_fl2 = run_params.density_trap.max_time_gap / 1000; % s

% Minimum time gap between adjacent forward peaks
min_forward_gap = run_params.density_trap.min_forward_gap / 1000; % s

%% Pairing
% Multiply the appropriate columns by peak direction to account for the 
% fact that the fluid is more/less dense than the measured particles
rev_cols = {'avg_pk_ht_hz', 'avg_baseline', 'bl_slope', 'pk_ht1_hz', ...
    'pk_ht2_hz', 'pk_ht3_hz', 'node_dev_1', 'node_dev_2', ...
    'node_dev_mean', 'mass_pg'};
for i = 1:length(rev_cols)
    fluid1_datasmr.(rev_cols{i}) = ...
        fluid1_pk_direct * fluid1_datasmr.(rev_cols{i});
    fluid2_datasmr.(rev_cols{i}) = ...
        fluid2_pk_direct * fluid2_datasmr.(rev_cols{i});
end

% Concatenate and sort peaks
full_datasmr = [fluid1_datasmr; fluid2_datasmr];
sorted_full = sortrows(full_datasmr, 'peak_time_s');

% Iterate through rows of full sorted peak list. Pull out groups of peaks
% (i.e. measurements in high and low density fluids) that:
%   1. contains a single first peak in fluid 1 (i.e. instances where 
%       there are multiple peaks in fluid 1 before a peak in fluid 2 will 
%       be discarded)
%   2. has an immediate subsequent second peak in fluid 2
%   3. the time between these peaks is less than the threshold manually set
%   4. there contains exactly one peak in fluid 1 before the
%       next peak in fluid 2
vstates = sorted_full.valve_state;
times = sorted_full.peak_time_s;
group_indices = strfind(vstates', [f1_vstate, f2_vstate]);

pairable_indices = nan(length(group_indices) * 2, 1);
pair_id = 1;
pair_id_arr = nan(length(group_indices) * 2, 1);
for i = 1:length(group_indices)
    pair_flag = 1;
    prev_idx = group_indices(i) - 1;
    forward_idx = group_indices(i);
    backward_idx = group_indices(i) + 1;
    next_idx = group_indices(i) + 2;

    if prev_idx >= 1 && vstates(prev_idx) == f1_vstate && ...
            times(forward_idx) - times(prev_idx) < min_forward_gap
        pair_flag = 0;
    end
    if next_idx <= length(vstates) && vstates(next_idx) == f2_vstate
        pair_flag = 0;
    end
    if times(backward_idx) - times(forward_idx) > max_time_fl1_fl2
        pair_flag = 0;
    end
    
    if pair_flag
        pairable_indices(2*i-1:2*i) = [forward_idx, backward_idx];
        pair_id_arr(2*i-1:2*i) = [pair_id, pair_id];
        pair_id = pair_id + 1;
    end
end
pairable_indices = pairable_indices(~isnan(pairable_indices));
paired_datasmr = sorted_full(pairable_indices, :);
paired_datasmr.pair_id = pair_id_arr(~isnan(pair_id_arr));
num_pairs = pair_id - 1;

% Populate the output pairing summary file
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
    
    % slope = bl_dens_cal_params.slope;
    % intercept = bl_dens_cal_params.intercept;
    
    bl1_avg(j) = fwd_pk.fl1_avg_baseline(1);

    % --------
    % fl1_bl_dens_gcm3(j) = (fl1_ref_freq - bl1_avg - intercept) ./ slope; 
    % bl1_density = fl1_bl_dens_gcm3(j);
    % --------
    
    bl2_avg(j) = back_pk.fl2_avg_baseline(1);

    % --------
    % fl2_bl_dens_gcm3(j) = (fl2_ref_freq - bl2_avg - intercept) ./ slope; 
    % bl2_density = fl2_bl_dens_gcm3(j);
    % --------
    
    % cal_f = cal_params.cal_factor_pg_per_hz;
    % fl1_avg_freq = fwd_pk.fl1_avg_pk_ht_hz(1);
    % fl2_avg_freq = back_pk.fl2_avg_pk_ht_hz(1);

    % density_gcm3(j) = ...
    %     (bl2_density .* fl1_avg_freq + bl1_density .* -fl2_avg_freq) ./ ...
    %     (fl1_avg_freq - fl2_avg_freq);
    % volume_fl(j) = ...
    %     cal_f * (fl1_avg_freq - fl2_avg_freq) ./ (bl2_density - bl1_density);
end

% fl1_bl_dens_gcm3 = array2table(fl1_bl_dens_gcm3, ...
%     'VariableNames', {'fl1_bl_dens_gcm3'});
% fl2_bl_dens_gcm3 = array2table(fl2_bl_dens_gcm3, ...
%     'VariableNames', {'fl2_bl_dens_gcm3'});
fl1_bl_avg_hz = array2table(bl1_avg, 'VariableNames', {'fl1_bl_avg_hz'});
fl2_bl_avg_hz = array2table(bl2_avg, 'VariableNames', {'fl2_bl_avg_hz'});

% dens_vol = array2table([density_gcm3, volume_fl], ...
%     'VariableNames', {'density_gcm3', 'volume_fl'});

% paired_data = [fl1_pair_summ, fl1_bl_dens_gcm3, fl2_pair_summ, ...
%     fl2_bl_dens_gcm3, dens_vol];
paired_data = [fl1_pair_summ, fl1_bl_avg_hz, fl2_pair_summ, ...
    fl2_bl_avg_hz];

if ~run_params.analysis_type.dens_trap_base_freq_recal
    paired_data = ...
        calc_particle_dens_vol(paired_data, fl1_ref_freq, fl2_ref_freq, ...
        intercept, slope, mass_cal_factor);
    paired_data = gate_outliers_dens_vol(paired_data);
else
    paired_data = optimize_base_freq_params(paired_data, fl1_ref_freq, ...
        fl2_ref_freq, intercept, slope, mass_cal_factor);
end


% vol_fig = figure;
% histogram(volume_fl, 'NumBins', 50)
% xlabel('Volume (fl)', 'FontSize', 12)
% ylabel('Count', 'FontSize', 12)
% 
% disp('Select left and right boundaries...')
% [vol_gate, ~] = ginput(2);
% if vol_gate(1) > vol_gate(2)
%     vol_gate = vol_gate(end:-1:1);
% end
% close(vol_fig)
% 
% dens_fig = figure;
% histogram(density_gcm3, 'NumBins', 50)
% xlabel('Density (g/cm^3)', 'FontSize', 12)
% ylabel('Count', 'FontSize', 12)
% 
% disp('Select left and right boundaries...')
% [dens_gate, ~] = ginput(2);
% if dens_gate(1) > dens_gate(2)
%     dens_gate = dens_gate(end:-1:1);
% end
% close(dens_fig)
% 
% gated_vol = volume_fl > vol_gate(1) & volume_fl < vol_gate(2);
% gated_dens = density_gcm3 > dens_gate(1) & density_gcm3 < dens_gate(2);
% paired_data = paired_data(gated_vol & gated_dens, :);

end