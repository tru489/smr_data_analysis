function paired_datasmr = pair_density_trap(run_params, fluid1_datasmr, fluid1_pk_direct, fluid2_datasmr, fluid2_pk_direct)
% Takes preprocessed data files from peak detection and pairs measurements
% based on valve states and times
%   Arguments:
%       run_params (struct): running parameters for analysis
%       fluid_1_datasmr (array(double)): summary file from peak detection 
%           for cells in fluid 1
%       fluid_1_pk_direct (array(double)): peak direction cells in fluid 1.
%           1 indicates cells more dense than fluid, -1 indicates cells
%           less dense than fluid
%       fluid_2_datasmr (array(double)): summary file from peak detection 
%           for cells in fluid 2
%       fluid_2_pk_direct (array(double)): peak direction cells in fluid 2.
%           1 indicates cells more dense than fluid, -1 indicates cells
%           less dense than fluid

%% Unload run params
% Valve state codes indicating whether fluid is in first or second density
% trap fluid
f1_vstate = run_params.density_trap.fluid1_vstate;
f2_vstate = run_params.density_trap.fluid2_vstate;

% Maximum time gap between peaks in fluid 1 and fluid 2
max_time_fl1_fl2 = run_params.density_trap.max_time_gap;

% Minimum time gap between adjacent forward peaks
min_forward_gap = run_params.density_trap.min_forward_gap;

%% Pairing
% Multiply the appropriate columns by peak direction to account for the 
% fact that the fluid is more/less dense than the measured particles
fluid1_datasmr(:, 3:11) = fluid1_pk_direct * fluid1_datasmr(:, 3:11);
fluid2_datasmr(:, 3:11) = fluid2_pk_direct * fluid2_datasmr(:, 3:11);

% Concatenate and sort peaks
full_datasmr = [fluid1_datasmr; fluid2_datasmr];
sorted_full = sortrows(full_datasmr, 1);

% Iterate through rows of full sorted peak list. Pull out groups of peaks
% (i.e. measurements in high and low density fluids) that:
%   1. contains a single first peak in fluid 1 (i.e. instances where 
%       there are multiple peaks in fluid 1 before a peak in fluid 2 will 
%       be discarded)
%   2. has an immediate subsequent second peak in fluid 2
%   3. the time between these peaks is less than the threshold manually set
%   4. there contains exactly one peak in fluid 1 before the
%       next peak in fluid 2
vstates = sorted_full(:, 14);
times = sorted_full(:, 1);
group_indices = strfind(vstates, [f1_vstate, f2_vstate]);

pairable_indices = nan(length(group_indices) * 2, 1);
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
    end
end
pairable_indices = pairable_indices(~isnan(pairable_indices));
paired_datasmr = sorted_full(pairable_indices, :);

if run_params.density_trap.save_pairing
    save_path = run_params.saving.save_abs_path + filesep + ...
        "paired_peaks.csv";
    writematrix(paired_datasmr, save_path)
end

end