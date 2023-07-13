function peak_idx = S1_get_peak_idx(idx, ydata)
% From ydata, gets peak indices pre-segmentation. Returns final peak index 
% in each set of 3 peaks.
% 
% Arguments:
%   idx (array(int)): indices within ydata which cross the offset
%       threshold for peak detection
%   ydata (array(double)): frequency data

% Find all breaks in y_diff indices; each segment is a peak of 
% interest, with end on idx_end and start on (idx_end + 1)
idx_ends = find(abs(diff(idx)) > 1);
idx_ends = [0 idx_ends' length(idx)];

peak_idx = zeros(1,length(idx_ends) - 1);

for i = 1:length(idx_ends) - 1
    % Focus on the piece of y_diff between two consecutive idx_end 
    % markers
    ydata_segment = ydata(idx(idx_ends(i)+1:idx_ends(i + 1)));
    % Find index of the maximum deviation, i.e. the apex within 
    % the piece
    segment_idx_max = find(ydata_segment == min(ydata_segment), 1);
    global_idx_max = idx(idx_ends(i) + 1) + segment_idx_max - 1;
    % Convert the apex index to the global index within y_diff 
    peak_idx(i) = global_idx_max(1);
end

unique_peaks = diff([peak_idx length(xdata)]) > unqPeakDist;
% For single-cell 2nd-mode peaks we are saving the each third peak
% (i.e. 3n+1)
peak_idx = peak_idx(unique_peaks);

% Now we have the global indices of the main peaks in this 
% segment of the entire frequency data

end

