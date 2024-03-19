function paired_datasmr = run_single_search(run_params, file_selection, ...
    bin_dir_path, fl1_ref_freq, fl2_ref_freq, rev_peaks_invert, ...
    fwd_arr_t, back_arr_t)

%% Unload parameters
% Density trap params
dt = run_params.density_trap;

%% Load data files
[parsed_files, data_dir, formatted_date] = ...
    parse_dir_contents(file_selection, bin_dir_path);

freqfile = parsed_files.freq_id;
timefile = parsed_files.smr_time_id;
vsfile = parsed_files.vs_id;
cal_params = parsed_files.mass_cal;
bl_dens_cal_params = parsed_files.dens_bl_cal;

run_params.density_trap.fl1_ref_freq = fl1_ref_freq;
run_params.density_trap.fl2_ref_freq = fl2_ref_freq;

%% Add file to save processed data
run_params.saving.save_abs_path = "C:\Users\Blue\Desktop\junk";
save_abs_path = run_params.saving.save_abs_path;

%% Analyze frequency data to get peaks
if ~rev_peaks_invert
    % ---------------- If reverse peaks are not inverted... ----------------
    [processed_freq_data, pass_struct, init_time] = ...
        analyze_freq_data(run_params, freqfile, timefile, vsfile);
    summary_pks = processed_to_summary(run_params, processed_freq_data, ...
        init_time, cal_params.cal_factor_pg_per_hz);
   
    
    % ---------------- Density trap peak pairing ----------------
    fluid1_datasmr = curated(curated.valve_state == dt.fluid1_vstate, :);
    fluid1_pk_direct = 1;
    fluid2_datasmr = curated(curated.valve_state == dt.fluid2_vstate, :);
    fluid2_pk_direct = 1;
    paired_datasmr = pair_density_trap(run_params, fluid1_datasmr, ...
        fluid1_pk_direct, fluid2_datasmr, fluid2_pk_direct, cal_params, ...
        bl_dens_cal_params, run_params.density_trap.fl1_ref_freq, ...
        run_params.density_trap.fl2_ref_freq);
else
    % ---------------- If reverse peaks are inverted... ----------------
    % (repeat analysis twice, once normally and once for inverted frequency
    % data)
    
    % -- Detect forward peaks --
    [processed_freq_data_fl1, pass_struct_fluid1, init_time_fluid1] = analyze_freq_data(run_params, ...
        freqfile, timefile, vsfile);
    summary_pks_fluid1 = processed_to_summary(run_params, ...
        processed_freq_data_fl1, init_time_fluid1, cal_params.cal_factor_pg_per_hz);
    
    % -- Detect backward peaks --
    [processed_freq_data_fl2, pass_struct_fluid2, init_time_fluid2] = analyze_freq_data(run_params, ...
        freqfile, timefile, vsfile, 1);
    summary_pks_fluid2 = processed_to_summary(run_params, processed_freq_data_fl2, ...
        init_time_fluid2, cal_params.cal_factor_pg_per_hz);
    
    % ---------------- Manual peak curation and data saving ----------------
    curated_fluid1 = summary_pks_fluid1;
    curated_fluid2 = summary_pks_fluid2;
    
    % ---------------- Density trap peak pairing ----------------
    fluid1_datasmr = curated_fluid1(curated_fluid1.valve_state == dt.fluid1_vstate, :);
    fluid1_pk_direct = 1;
    fluid2_datasmr = curated_fluid2(curated_fluid2.valve_state == dt.fluid2_vstate, :);
    fluid2_pk_direct = -1;
    paired_datasmr = pair_density_trap(run_params, fluid1_datasmr, ...
        fluid1_pk_direct, fluid2_datasmr, fluid2_pk_direct, cal_params, ...
        bl_dens_cal_params, run_params.density_trap.fl1_ref_freq, ...
        run_params.density_trap.fl2_ref_freq);
    curated = [curated_fluid1; curated_fluid2];
end
fclose('all');
end

