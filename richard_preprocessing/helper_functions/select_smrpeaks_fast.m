function [datasmr_good, number_bad_peaks] = select_smrpeaks_fast(datasmr)
    % datasmr_good format is [tm' tm'/60 mm' bm' bs' m1' m2' m3' nd1' nd2' 
    % ndm' w' bd' vs' sectnum' tm'/3600 mm'/2 pkorder' ndm'./mm'];
    
    % Peak imbalance in percentage relative to mean mass
    coeff_peak_bal = 0.1;
    coeff_node_bal = analysis_params.estimated_noise * 4;
    coeff_node_peak = 0.2; % Node that is bigger than 20% is ditched
    
    idx_discard_bmdiff = find(abs((datasmr(:,6) - datasmr(:,8)) ./ ...
        datasmr(:,3)) > coeff_peak_bal);
    idx_discard_nd_diff_base = find(abs(datasmr(:,9) - datasmr(:,10)) > ...
        coeff_node_bal );
    idx_discard_nd_bm = find(abs(datasmr(:,11) ./ datasmr(:,3)) > ...
        coeff_node_peak);
    
    idx_discard = unique([idx_discard_bmdiff; idx_discard_nd_diff_base; ...
        idx_discard_nd_bm]);
    
    datasmr_good = datasmr;
    datasmr_good(idx_discard,:) = [];
    number_bad_peaks = length(idx_discard);
end