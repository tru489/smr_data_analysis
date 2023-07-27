function segmentbound = S1_get_seg_bound(peak_idx, xdata)
% Given indices of peaks, returns indices of boundaries between each
% adjacent peaks to identify chunks of data within which to search for
% peaks
%
% Arguments:
%   peak_idx (array(int)): indices of peaks within frequency data
%   xdata (array(int)): indices in array of frequency data
% Returns:
%   segmentbound (array(int)): indices of boundaries between adjacent peaks
%       in frequency data

segmentbound = zeros(1,length(peak_idx));
    
segmentbound(1) = peak_idx(1) + round((peak_idx(2) - peak_idx(1))/2);

for i = 2:length(peak_idx)-1
    segmentbound(i) = peak_idx(i) + round((peak_idx(i+1) - peak_idx(i))/2);
end
segmentbound(end) = xdata(end);
segmentbound = [1 segmentbound];

end