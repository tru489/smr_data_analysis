function summary_pks_curated = curation_from_bead_arr(summary_pks, arr_t_ctd)
% Curates detected peaks based on previously curated peaks based on time.
% Used in situations where peak detection criteria (peak fitting/baseline
% fitting parameters) are changed. Use this to use comparable curation
% between different parameter sets (e.g. for parameter gridsearch)
%
% Arguments: 
%   summary_pks (table): candidate peaks from analysis pipeline
%   arr_t_ctd (1d array): time array for curated peaks, indicating where
%       these peaks occur in time

arr_t_cand = summary_pks.real_time_s;

curation_mask = zeros(size(arr_t_cand));
for i = 1:length(arr_t_cand)
    min_diff = min(abs(arr_t_ctd - arr_t_cand(i)));
    if min_diff < .200
        curation_mask(i) = 1;
    end
end
summary_pks_curated = summary_pks(logical(curation_mask), :);
end

