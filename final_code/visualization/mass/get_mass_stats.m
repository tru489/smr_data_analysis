function stats_cell = get_mass_stats(run_params, summary_pks, curated, ...
    mass_cal_factor)
%GET_MASS_STATS Summary of this function goes here
%   Detailed explanation goes here

stats_cell = {}; i = 1;

% Auto-reject used?
if run_params.curation.auto_rejection
    ar_used = "Yes";
else
    ar_used = "No";
end
stats_cell{i} = ...
    strcat("Were peak auto-rejection criteria used? : ", ar_used);
i = i + 1;

% Manual curation?
if run_params.prefs.manual_curation
    mc_used = "Yes";
else
    mc_used = "No";
end
stats_cell{i} = ...
    strcat("Was peak manual curation used? : ", mc_used);
i = i + 1;

% Number of peaks pre-curation
stats_cell{i} = strcat("Number of peaks pre-curation: ", num2str(height(summary_pks)));
i = i + 1;

% Number of peaks rejected
stats_cell{i} = strcat("Number of peaks rejected: ", ...
    num2str(height(summary_pks) - height(curated)));
i = i + 1;

% Number of peaks post-curation
stats_cell{i} = strcat("Number of peaks post-curation: ", num2str(height(curated)));
i = i + 1;

% Mass calibration factor
stats_cell{i} = strcat("Mass calibration factor: ", num2str(mass_cal_factor), " pg/Hz");
i = i + 1;

end

