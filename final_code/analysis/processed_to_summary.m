function summary_pks_table = processed_to_summary(processed_freq_data)
% Takes processed frequency data from preprocessing scripts and converts to
% summary of peak data used for downstream analysis
%
% Arguments:
%   processed_freq_data (double): processed frequency peak data from
%       preprocessing scripts
% Returns:
%   summary_pks_table (table): table containing summary peak information
% 
% 
% The following are the column labels for each column in the summary data:
%   (1) peak_time_s (time at which peak occurred in seconds)
%   (2) peak_time_m (time at which peak occurred in minutes)
%   (3) pk_ht_hz (mean of secondary peak heights in hz)
%   (4) avg_baseline (average baseline of left and right peaks)
%   (5) bl_slope (baseline slope)
%   (6) pk_ht1_hz (height of peak 1)
%   (7) pk_ht2_hz (height of peak 2)
%   (8) pk_ht3_hz (height of peak 3)
%   (9) node_dev_1 (node deviation of node 1)
%   (10) node_dev_2 (node deviation of node 2)
%   (11) node_dev_mean (mean of node deviations)
%   (12) pk_fwhm (FWHM of first peak)
%   (13) transit_t (transit time in ms of particle)
%   (14) segment_num (segment number in which peak ocurred)
%   (15) peak_time_h (time at which peak occurred in hours)
%   (16) pk_order (peak index within total peak list)

% Filter out zero columns
idx_nonzero = processed_freq_data(12,:) > 0;
processed_nonzero = processed_freq_data(:, idx_nonzero);

% Find indices of unique peak sets (i.e. start indices of sets 3 peaks)
idx = find(diff(processed_nonzero(12,:)) ~= 0);
idx = [0 idx];

% Preallocate summary array
summary_pks = zeros(length(idx), 16);

% Iterate through each unique peak set
for i=1:length(idx)
    % Temporary indices of this peakset
    if i == length(idx)
        temp_idx = idx(i) + 1:length(processed_nonzero);
    else
        temp_idx = idx(i) + 1:idx(i+1);
    end
    
    % Times of first and last peaks
    t1 = processed_nonzero(1, temp_idx(1));
    t2 = processed_nonzero(1, temp_idx(end));
    
    % Heights of left, middle, and right peaks
    summary_pks(i, 6) = processed_nonzero(2, temp_idx(1));
    summary_pks(i, 7) = processed_nonzero(2, temp_idx(2));
    summary_pks(i, 8) = processed_nonzero(2, temp_idx(end));
    
    % Average baseline of left and right peak
    b1 = mean([processed_nonzero(4, temp_idx(1)) ...
        processed_nonzero(5, temp_idx(1))]);
    b2 = mean([processed_nonzero(4, temp_idx(end)) ...
        processed_nonzero(5, temp_idx(end))]);
    
    % Populate summary pk array
    summary_pks(i, 1) = mean([t1, t2]);
    summary_pks(i, 2) = mean([t1, t2]) / 60;
    summary_pks(i, 15) = mean([t1, t2]) / 3600;
    summary_pks(i, 3) = mean([m1(i), m3(i)]);
    summary_pks(i, 4) = mean([b1(i), b2(i)]);
    summary_pks(i, 12) = processed_nonzero(9, temp_idx(1));
    summary_pks(i, 9) = processed_nonzero(8, temp_idx(1));
    summary_pks(i, 10) = processed_nonzero(8, temp_idx(2));
    summary_pks(i, 11) = mean([nd1(i), nd2(i)]);
    summary_pks(i, 5) = processed_nonzero(7, temp_idx(1));
    summary_pks(i, 14) = processed_nonzero(10, temp_idx(1));
    summary_pks(i, 13) = processed_nonzero(6, temp_idx(1));
    summary_pks(i, 16) = processed_nonzero(12, temp_idx(1));
end

variable_names = {'peak_time_c', 'peak_time_m', 'pk_ht_hz', ...
    'avg_baseline', 'bl_slope', 'pk_ht1_hz', 'pk_ht2_hz', 'pk_ht3_hz', ...
    'node_dev_1', 'node_dev_2', 'node_dev_mean', 'pk_fwhm', ...
    'transit_t', 'segment_num', 'peak_time_h', 'pk_order'};
summary_pks_table = array2table(summary_pks, ...
    'VariableNames', variable_names);

end