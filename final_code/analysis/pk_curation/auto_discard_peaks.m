function idx_discard = auto_discard_peaks(run_params, discard_params, datasmr)
% Based on several parameters, selects peaks for automatic discard. Returns
% an array of indices of the peaks to discard.
%
% Arguments:
%   run_params (struct): running parameters necessary for analysis
%   discard_params (struct): parameters for auto-discard
%   datasmr (array(double)): peakset summary array
% Returns:
%   idx_discard (array(logical)): datasmr row indices to be auto-discarded


% Unload parameters
pk_imbal_thresh = discard_params.pk_imbal_thresh;
nod_imbal_thresh = discard_params.nod_imbal_thresh;
nod_dev_thresh = discard_params.nod_dev_thresh;

% Unload columns from summary array
pk_ht1 = datasmr.pk_ht1_hz;
pk_ht3 = datasmr.pk_ht3_hz;
avg_pk_ht = datasmr.avg_pk_ht_hz;
node_dev_1 = datasmr.node_dev_1;
node_dev_2 = datasmr.node_dev_2;
node_dev_mean = datasmr.node_dev_mean;

% Peak imbalance mask; difference of peak 3 and 1 height / average 
pk_imbal_mask = abs((pk_ht1 - pk_ht3) ./ avg_pk_ht) > pk_imbal_thresh;

% Node imbalance mask; difference of node deviations 1 and 2 / 
% average of peak 3 and 1 height
nod_imbal_mask = abs((node_dev_1 - node_dev_2) ./ avg_pk_ht) > ...
    nod_imbal_thresh;

% Node deviation mask; average node deviation between nodes 1 and 2 / 
% average of peak 1 and 3 height
nod_dev_mask = abs(node_dev_mean ./ avg_pk_ht) > nod_dev_thresh;

% Indices to discard
idx_discard = find(pk_imbal_mask | nod_imbal_mask | nod_dev_mask);

end