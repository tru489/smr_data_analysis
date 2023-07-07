close all;
%% Parameters
% Valve state for low and high density fluids
low_density_vstate = 11;
high_density_vstate = 7;

% Max time threshold between high and low density measurements
max_time_threshold = 15; % s

%% Processing
% Select datasmr files for peaks detected in high and low density fluids
disp('Select file for buoyant masses in less dense fluid...')
[less_dense_fname, less_dense_path] = uigetfile('*.csv');
less_dense_datasmr = readmatrix([less_dense_path less_dense_fname]);
less_dense_datasmr = less_dense_datasmr(less_dense_datasmr(:, 14) == ...
    low_density_vstate, :);

disp('Select file for buoyant masses in more dense fluid...')
[more_dense_fname, more_dense_path] = uigetfile('*.csv');
more_dense_datasmr = readmatrix([more_dense_path, more_dense_fname]);
more_dense_datasmr = more_dense_datasmr(more_dense_datasmr(:, 14) == ...
    high_density_vstate, :);

% Multiply the appropriate columns by -1 to account for the fact that the
% fluid is more dense than the measured particles
more_dense_datasmr(:, 3:11) = -more_dense_datasmr(:, 3:11);

% Concatenate and sort peaks
full_datasmr = [less_dense_datasmr; more_dense_datasmr];
sorted_full = sortrows(full_datasmr, 1);

% Iterate through rows of full sorted peak list. Pull out pairs of peaks
% (i.e. measurements in high and low density fluids) that:
%   1. contains a first peak in low density fluid
%   2. has an immediate subsequent second peak in high density fluid
%   3. the time between these peaks is less than the threshold manually set
%   4. there contains exactly one peak in high density fluid before the
%       next peak in low density fluid
complete = 0; i = 1; add_idx = 1;
filtered_full = zeros(size(sorted_full));
while ~complete
    is_low = sorted_full(i, 14) == low_density_vstate;
    has_high = sorted_full(i + 1, 14) == high_density_vstate;
    time_in_range = (sorted_full(i + 1, 1) - sorted_full(i, 1)) < ...
        max_time_threshold;
    
    if (i + 2) <= size(sorted_full, 1)
        has_single_return = sorted_full(i + 2, 14) == low_density_vstate;
        acceptable = is_low && has_high && has_single_return && ...
            time_in_range;
    else
        acceptable = is_low && has_high && time_in_range;
    end
    
    if acceptable
        filtered_full(add_idx:add_idx + 1, :) = sorted_full(i:i + 1, :);
        
        % Increment index at which to add new data into the result matrix
        add_idx = add_idx + 2;
        
        % Increment row in filtered_full to consider
        i = i + 2;
    else
        i = i + 1;
    end
    
    if i >= size(sorted_full, 1)
        complete = 1;
    end
end

% Slice out high and low density fluid peaks from the filtered matrix, and
% re-concatenate them in the format expected for the peak match script
filtered_full = filtered_full(filtered_full(:, 1) ~= 0, :);
low_dens_slice = filtered_full(filtered_full(:,14) == ...
    low_density_vstate, :);
high_dens_slice = filtered_full(filtered_full(:,14) == ...
    high_density_vstate, :);
complete_filtered = [low_dens_slice; high_dens_slice];
writematrix(complete_filtered, ...
    [more_dense_path 'filtered_combined_datasmr.csv'])