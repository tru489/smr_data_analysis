function stats_cell = get_water_content_stats(run_params, ...
    full_summary, paired_datasmr, mass_cal_factor, vol_cal_factor, ...
    detected_smr_peaks, output_pmt_table, vsfile)
% Generates cell array of important summary stats from water content
% analysis

dt = run_params.density_trap;

stats_cell = {}; i = 1;

% Mass calibration factor (smr calibration)
stats_cell{i} = ...
    strcat("Mass calibration factor: ", num2str(mass_cal_factor), " pg/Hz");
i = i + 1;

% Volume calibration factor (from coulter counter + pmt calibration)
stats_cell{i} = ...
    strcat("Volume calibration factor: ", num2str(vol_cal_factor), " fl/au");
i = i + 1;

% Forward/back peak detection
fl1_vs = dt.fluid1_vstate;
fl2_vs = dt.fluid2_vstate;

num_fwd = sum(detected_smr_peaks.valve_state == fl1_vs);
num_back = sum(detected_smr_peaks.valve_state == fl2_vs);
num_pair_peaks = height(paired_datasmr);

frewind(vsfile);
valve_state = fread(vsfile);
vs_strip_repeats = valve_state([true; diff(valve_state) ~= 0]);
num_vs_changes = length(strfind(vs_strip_repeats', [fl1_vs, fl2_vs]));
stats_cell{i} = strcat("Number of fluid switches: ", num2str(num_vs_changes));
i = i + 1;

stats_cell{i} = ...
    strcat("Number of forward peaks: ", num2str(num_fwd));
i = i + 1;
stats_cell{i} = ...
    {sprintf("Pair rate of forward peaks: %0.3f%%", 100 * num_fwd / num_pair_peaks)};
i = i + 1;
stats_cell{i} = ...
    {sprintf("Occurrence rate of forward peaks: %0.3f%%", 100 * num_fwd / num_vs_changes)};
i = i + 1;

stats_cell{i} = ...
    strcat("Number of back peaks: ", num2str(num_back));
i = i + 1;
stats_cell{i} = ...
    {sprintf("Pair rate of back peaks: %0.3f%%", 100 *  num_back / num_pair_peaks)};
i = i + 1;
stats_cell{i} = ...
    {sprintf("Occurrence rate of back peaks: %0.3f%%", 100 * num_back / num_vs_changes)};
i = i + 1;

stats_cell{i} = ...
    strcat("Number of forward and back peaks paired: ", num2str(height(paired_datasmr)));
i = i + 1;

stats_cell{i} = ...
    strcat("Number of PMT peaks: ", num2str(height(output_pmt_table)));
i = i + 1;

stats_cell{i} = ...
    sprintf("Pair rate of paired SMR data with PMT peaks: %0.3f%%", ...
    height(full_summary) / height(paired_datasmr));
i = i + 1;

stats_cell{i} = ...
    strcat("Number of paired final peaks: ", num2str(height(full_summary)));
i = i + 1;

end

