function stats_cell = get_fl_excl_stats(run_params, ...
    full_summary, summary_pks, mass_cal_factor, vol_cal_factor, ...
    output_pmt_table, curated)

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

% Volume calibration factor (from coulter counter + pmt calibration)
stats_cell{i} = ...
    strcat("Volume calibration factor: ", num2str(vol_cal_factor), " fl/au");
i = i + 1;

stats_cell{i} = ...
    strcat("Number of PMT peaks: ", string(height(output_pmt_table)));
i = i + 1;

stats_cell{i} = ...
    sprintf("Pair rate of paired SMR data with PMT peaks: %0.3f%%", ...
    height(full_summary) / height(curated) * 100);
i = i + 1;

stats_cell{i} = ...
    strcat("Number of paired final peaks: ", string(height(full_summary)));
i = i + 1;

end

