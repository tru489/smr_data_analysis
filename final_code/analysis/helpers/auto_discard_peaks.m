function idx_discard = auto_discard_peaks(params, datasmr)
% Based on several parameters, selects peaks for automatic discard. Returns
% an array of indices of the peaks to discard.
%
% Arguments:
%   params (struct): parameters for auto-discard
%   datasmr (array(double)): peakset summary array
% Returns:
%   idx_discard (array(logical)): datasmr row indices to be auto-discarded

% Unload parameters
pk_imbal_thresh = params.pk_imbal_thresh;
nod_imbal_thresh = params.nod_imbal_thresh;
nod_dev_thresh = params.nod_dev_thresh;

% Peak imbalance mask; difference of peak 3 and 1 height / average 
pk_imbal_mask = abs((datasmr(:,6) - datasmr(:,8)) ./ datasmr(:,3)) > ...
    pk_imbal_thresh;

% Node imbalance mask; difference of node deviations 1 and 2 / 
% average of peak 3 and 1 height
nod_imbal_mask = abs((datasmr(:,9) - datasmr(:,10)) ./ datasmr(:,3)) > ...
    nod_imbal_thresh;

% Node deviation mask; average node deviation between nodes 1 and 2 / 
% average of peak 1 and 3 height
nod_dev_mask = abs(datasmr(:,11) ./ datasmr(:,3)) > nod_dev_thresh;

% Indices to discard
idx_discard = find(pk_imbal_mask | nod_imbal_mask | nod_dev_mask);

end