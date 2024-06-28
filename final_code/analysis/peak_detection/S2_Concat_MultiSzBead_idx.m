function [idx, ydata_thres_fin] = S2_Concat_MultiSzBead_idx(run_params, ydata, ydata_thres)
% In the case where there beads of multiple sizes to be parsed, multiple
% thresholds are used. Iterates through multiple size thresholds and
% stitches unique peak regions together. Rejects duplicate peaks between
% different offsets by identifying overlap between detected peak index
% regions; if there are overlaps, reject those peaks.
%
% Arguments:
%   run_params (struct): running parameters
%   ydata (array): frequency data
%   ydata_thres (array): baseline-interpolated ydata
% Returns:
%   idx (array): array of  (unique) indices in which peaks cross the 
%       designated set of offsets
%   ydata_thres_fin (array): threshold for ydata. manually set to be lowest
%       threshold for peak detection for visualization clarity

offsets = run_params.bl_select.multi_offset_threshold;
ydata_thres_offset = ydata_thres - offsets(1); 
idx = find(ydata < ydata_thres_offset);

for i = 2:length(offsets)
    % Create an array of peak segment boundaries for the current iteration
    % of idx
    ydata_thres_offset = ydata_thres - offsets(i); 
    idx_temp = find(ydata < ydata_thres_offset);

    if isempty(idx_temp)
        continue
    end

    boundary_list_idx_temp = create_binning(idx_temp);
    if ~isempty(idx)
        intsc_idxs = intersect(idx, idx_temp);
        boundary_list_intsc = create_binning(intsc_idxs);
    
        boundary_list_idx_temp_copy = boundary_list_idx_temp;
        for j = 1:size(boundary_list_intsc,1)
            intc_start_idx = boundary_list_intsc(j,1);
            idx_temp_replace_idx = find(boundary_list_idx_temp_copy(:, 1) <= intc_start_idx & boundary_list_idx_temp_copy(:, 2) >= intc_start_idx, 1);
            boundary_list_idx_temp(idx_temp_replace_idx,:) = zeros(1, 2);
        end
        boundary_list_idx_temp = boundary_list_idx_temp(any(boundary_list_idx_temp,2),:);
    end

    for k = 1:size(boundary_list_idx_temp,1)
        slice_start = find(idx_temp == boundary_list_idx_temp(k, 1));
        slice_end = find(idx_temp == boundary_list_idx_temp(k, 2));
        idx = [idx; idx_temp(slice_start:slice_end)];
    end
    idx = sort(idx);
end

ydata_thres_fin = ydata_thres - min(offsets); 

end

function boundary_list = create_binning(idx)
% Creates 2d array of ranges of continuous indices; rows are different
% ranges, columns are start/end indices (ranges are inclusive of the start/end)
    
num_peak_segments = sum(diff(idx) ~= 1) + 1;
boundary_list = zeros(num_peak_segments, 2);
boundary_list(1,1) = idx(1); boundary_list(end, end) = idx(end);
border_idxs = find(diff(idx) ~= 1);
for i = 1:num_peak_segments - 1
    boundary_list(i, 2) = idx(border_idxs(i));
    boundary_list(i+1, 1) = idx(border_idxs(i)+1); 
end

end