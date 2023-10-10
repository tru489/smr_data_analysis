function generate_smr_signal(...
    noise_level, alpha_factor, ...
    ...
    n_traps, fwd_pk_arrival_frac, fwd_search_time, fwd_pk_width, ...
    back_pk_arrival_frac, back_search_time, back_pk_width, ...
    ...
    cell_dry_density_gcm3, cell_dry_volume_fl, cell_total_volume_fl, ...
    ...
    fwd_pkfit_a, fwd_pkfit_b, fwd_pkfit_c, back_pkfit_a, back_pkfit_b, ...
    back_pkfit_c, ...
    ...
    dir_path)

%% Define SMR system-specific parameters (do not change)
CIC = 10000;    % CIC rate
Fs = 10^8/CIC;  % sampling rate
rng(1);         % define random number generator (fixed value, yields same stochastic numbers)

%% Define physical cantilever properties (do not change)
% Channel height and volume (hollow section of channel; um3)
h_channel_um = 20; % um
v_channel = h_channel_um * (((45 * 415) + (5 * 20) + 0.5 * pi * 20^2) - (5 * 415 + 0.5 * pi * 2.5^2));
l_cantilever = 415 + 20; % um

% Cantilever footprint area (um2)
a_footprint = 0;

% Cantilever silicon volume (um3)
v_silicon = (20 + 2 * 2) * a_footprint - v_channel;

% Cantilever mass (kg)
dens_silicon = 7850; % kg/m^3
m_cantilever = v_silicon * dens_silicon * 1e-18; % kg

% SMR calibration factor (pg/Hz)
mass_cal_factor = 0.8;
mass_cal_cv = 0.01;

% Effective mass fraction (for single-clamped cantilever; from theory)
m_eff_fraction = 0.25;

%% Define fluid properties
% Water density and dynamic viscosity
pbs_1x_density = 1000; % kg/m3
fwd_fluid_dens_kgm3 = pbs_1x_density; % kg/m3; value for PBS
fwd_fluid_dyn_visc_pas = 8.891*10^-4; % Pa*s; value for PBS

% Heavy water density and dynamic viscosity
pbs_10x_density = 1100; % kg/m3
d2o_density = 1104.481; % kg/m3
back_fluid_dens_kgm3 = pbs_10x_density * 0.1 + d2o_density * 0.9; % kg/m3; value for 90% D2O-PBS
back_fluid_dyn_visc_pas = 8.891*10^-4; % Pa*s; value for 100% D2O

%% Baseline SMR frequency values 
fwd_baseline_freq = 1.6e6; % Hz
back_baseline_freq = 1.45e6; % Hz

%% Define peak/segment duration parameters
% Generate indices of final frequency array
fwd_datapoints = fwd_search_time * Fs;
back_datapoints = back_search_time * Fs;
total_datapoints = (fwd_datapoints + back_datapoints) * n_traps;
total_time = (fwd_search_time + back_search_time) * n_traps;
fwd_idx_start_datapoints = 1 + (0:n_traps - 1) * (fwd_datapoints + back_datapoints);
back_idx_start_datapoints = fwd_idx_start_datapoints + back_datapoints;

% Freq, valve state, time arrays
t_offset = 2082844800; % seconds between 01-01-1904 and 01-01-1904 00:00:00 UTC
t_start = convertTo(datetime('now'),'posixtime') + t_offset;
freq = zeros(total_datapoints, 1);
time = t_start + (0:total_datapoints - 1) * 1/Fs;

fwd_vstate = 11;
back_vstate = 7;
valve_state = zeros(total_datapoints, 1);
for i = 1:length(fwd_idx_start_datapoints)
    fwd_start_temp = fwd_idx_start_datapoints(i);
    back_start_temp = back_idx_start_datapoints(i);
    valve_state(fwd_start_temp:back_start_temp - 1) = fwd_vstate;
    valve_state(back_start_temp:fwd_idx_start_datapoints(i+1)) = back_vstate;
end

%% Cell biophysical properties
fl_to_m3 = 1e-18; % fl/m3

rel_water_content = (cell_total_volume_fl - cell_dry_volume_fl) / cell_total_volume_fl;

cell_radius_m = (3 * cell_total_volume_fl / (4 * pi)) ^ (1/3) * 1e-6; % m

%% Generate noise term
Colornoise_2 = dsp.ColoredNoise(alpha_factor, total_datapoints, ...
    'OutputDataType', 'double');
target_noise_Hz = noise_level;
noise_term = Colornoise_2()' / std(Colornoise_2()') * noise_level;

%% Start simulation
% Feature list:
% - Segment baseline curvature fit parameters (fwd: a,b,c; back: a,b,c)
% - Local peak curvatures (fwd, back)
% - Buoyant mass (fwd, back)
% - Cell biophysical parameters (dry mass, dry volume, total volume, water 
%   content)
% - Arrival fractions (% transit through total segment length; fwd, back)
% - Peak widths (in datapoints; fwd, back)

fwd_bl_fit_abc = zeros(n_traps, 3);
back_bl_fit_abc = zeros(n_traps, 3);
local_curv_fwd_back = zeros(n_traps, 2);
buoy_mass_fwd_back = zeros(n_traps, 2);
dry_mass_arr = zeros(n_traps, 1);
dry_vol_arr = zeros(n_traps, 1);
tot_vol_arr = zeros(n_traps, 1);
rel_wc_arr = zeros(n_traps, 1);
arrival_frac_fwd_back = zeros(n_traps, 2);
pk_width_fwd_back = zeros(n_traps, 2);

for j = 1:n_traps
    fwd_start_idx = fwd_idx_start_datapoints(j);
    back_start_idx = back_idx_start_datapoints(j);
    
    % Cantilever mass
    m_eff_theoretical_kg = m_cantilever * m_eff_fraction;

    %% Select stochastic parameters
    % Parameters set to a single value in an array will just use that
    % single value
    fwd_pk_arrival_frac = fwd_pk_arrival_frac(randsample(length(fwd_pk_arrival_frac), 1, true));
    fwd_pk_width = fwd_pk_width(randsample(length(fwd_pk_width), 1, true));
    back_pk_arrival_frac = back_pk_arrival_frac(randsample(length(back_pk_arrival_frac), 1, true));
    back_pk_width = back_pk_width(randsample(length(back_pk_width), 1, true));

    cell_dry_density_gcm3 = cell_dry_density_gcm3(randsample(length(cell_dry_density_gcm3), 1, true));
    cell_dry_volume_fl = cell_dry_volume_fl(randsample(length(cell_dry_volume_fl), 1, true));
    cell_total_volume_fl = cell_total_volume_fl(randsample(length(cell_total_volume_fl), 1, true));

    fwd_pkfit_a = fwd_pkfit_a(randsample(length(fwd_pkfit_a), 1, true));
    fwd_pkfit_b = fwd_pkfit_b(randsample(length(fwd_pkfit_b), 1, true));
    fwd_pkfit_c = fwd_pkfit_c(randsample(length(fwd_pkfit_c), 1, true));
    
    back_pkfit_a = back_pkfit_a(randsample(length(back_pkfit_a), 1, true));
    back_pkfit_b = back_pkfit_b(randsample(length(back_pkfit_b), 1, true));
    back_pkfit_c = back_pkfit_c(randsample(length(back_pkfit_c), 1, true));

    % Append to feature lists
    fwd_bl_fit_abc(j, :) = [fwd_pkfit_a, fwd_pkfit_b, fwd_pkfit_c];
    back_bl_fit_abc(j, :) = [back_pkfit_a, back_pkfit_b, back_pkfit_c];

    %% Simulate forward signal
    % Relevant biophysical properties
    cell_total_density_kgm3 = cell_dry_density_gcm3 * (1 - rel_water_content) + fwd_fluid_dens_kgm3 * rel_water_content;
    fwd_buoy_mass_kg = (cell_total_density_kgm3 - fwd_fluid_dens_kgm3) * cell_total_volume_fl * fl_to_m3;
    kg_to_pg = 1e15;
    fwd_buoy_mass_pg = fwd_buoy_mass_kg * kg_to_pg;

    % Physics simulation parameters
    ab = ab_value(fwd_baseline_freq, cell_radius_m, fwd_fluid_dyn_visc_pas, cell_total_density_kgm3, ...
        fwd_fluid_dens_kgm3);
    [ad, Reynolds_water_height] = ad_value(fwd_baseline_freq, cell_radius_m, fwd_fluid_dyn_visc_pas, ...
        h_channel_um * 1e-6, fwd_fluid_dens_kgm3);
    [u, x, dudx] = U_n(1, 2, fwd_pk_width, 'single-clamped');

    % Peak trace given particle buoyant mass
    Df_disp = -0.5 * ab * u.^2 * fwd_buoy_mass_kg / m_eff_theoretical_kg * fwd_baseline_freq;

    % Antinode correction
    V_dimensionless = ...
        (fwd_fluid_dens_kgm3 * (cell_total_volume_fl * fl_to_m3)^(5/3)) / ...
        (2 * ((6 * pi^2)^(1/3)) * m_eff_theoretical_kg);
    Df_rot = -fwd_baseline_freq * ad * V_dimensionless * dudx.^2 / (l_cantilever * 1e-6)^2;
    Df_peak = Df_disp + 0.2 * Df_rot;

    % Append into frequency array
    append_start_idx = fwd_start_idx + round(fwd_datapoints * fwd_pk_arrival_frac);
    freq_window = freq(append_start_idx:append_start_idx + fwd_pk_width - 1);
    peak_segment = freq_window + Df_peak;
    freq(append_start_idx:append_start_idx + fwd_pk_width - 1) = ...
        peak_segment;

    % Add in baseline curvature
    seg_win_curv = freq(fwd_start_idx:fwd_start_idx + fwd_datapoints - 1);
    curv_idx = 0:fwd_datapoints - 1;
    bl_curv = fwd_pkfit_a * curv_idx.^2 + fwd_pkfit_b * curv_idx + fwd_pkfit_c;
    seg_win_curv = seg_win_curv + bl_curv;
    freq(fwd_start_idx:fwd_start_idx + fwd_datapoints - 1) = ...
        seg_win_curv;
    
    % Local curvature at particle transit location
    fwd_part_x = round(fwd_datapoints * fwd_pk_arrival_frac + fwd_pk_width / 2);
    fwd_local_curvature = ...
        2 * fwd_pkfit_a / (1 + (2 * fwd_pkfit_a * fwd_part_x + fwd_pkfit_b)^2)^(3/2);

    %% Simulate backwards signal
    % Relevant biophysical properties
    cell_total_density_kgm3 = cell_dry_density_gcm3 * (1 - rel_water_content) + back_fluid_dens_kgm3 * rel_water_content;
    back_buoy_mass_kg = (cell_total_density_kgm3 - back_fluid_dens_kgm3) * cell_total_volume_fl * fl_to_m3;
    back_buoy_mass_pg = back_buoy_mass_kg * kg_to_pg;

    % Physics simulation parameters
    ab = ab_value(back_baseline_freq, cell_radius_m, back_fluid_dyn_visc_pas, cell_total_density_kgm3, ...
        back_fluid_dens_kgm3);
    [ad, Reynolds_water_height] = ad_value(back_baseline_freq, cell_radius_m, back_fluid_dyn_visc_pas, ...
        h_channel_um * 1e-6, back_fluid_dens_kgm3);
    [u, x, dudx] = U_n(1, 2, back_pk_width, 'single-clamped');

    % Peak trace given particle buoyant mass
    Df_disp = -0.5 * ab * u.^2 * back_buoy_mass_kg / m_eff_theoretical_kg * back_baseline_freq;

    % Antinode correction
    V_dimensionless = ...
        (back_fluid_dens_kgm3 * (cell_total_volume_fl * fl_to_m3)^(5/3)) / ...
        (2 * ((6 * pi^2)^(1/3)) * m_eff_theoretical_kg);
    Df_rot = -back_baseline_freq * ad * V_dimensionless * dudx.^2 / (l_cantilever * 1e-6)^2;
    Df_peak = Df_disp + 0.2 * Df_rot;

    % Append into frequency array
    append_start_idx = back_start_idx + round(back_datapoints * back_pk_arrival_frac);
    freq_window = freq(append_start_idx:append_start_idx + back_pk_width - 1);
    peak_segment = freq_window + Df_peak;
    freq(append_start_idx:append_start_idx + back_pk_width - 1) = ...
        peak_segment;

    % Add in baseline curvature
    seg_win_curv = freq(back_start_idx:back_start_idx + back_datapoints - 1);
    curv_idx = 0:back_datapoints - 1;
    bl_curv = back_pkfit_a * curv_idx.^2 + back_pkfit_b * curv_idx + back_pkfit_c;
    seg_win_curv = seg_win_curv + bl_curv;
    freq(back_start_idx:back_start_idx + back_datapoints - 1) = ...
        seg_win_curv;

    % Local curvature at particle transit location
    back_part_x = round(back_datapoints * back_pk_arrival_frac + back_pk_width / 2);
    back_local_curvature = ...
        2 * back_pkfit_a / (1 + (2 * back_pkfit_a * back_part_x + back_pkfit_b)^2)^(3/2);

    % Save parameters to arrays
    local_curv_fwd_back(j, :) = [fwd_local_curvature, back_local_curvature];
    buoy_mass_fwd_back(j, :) = [fwd_buoy_mass_pg, back_buoy_mass_pg];
    dry_mass_arr(j, :) = cell_dry_density_gcm3;
    dry_vol_arr(j, :) = cell_dry_volume_fl;
    tot_vol_arr(j, :) = cell_total_volume_fl;
    rel_wc_arr(j, :) = (cell_total_volume_fl - cell_dry_volume_fl) / cell_total_volume_fl;
    arrival_frac_fwd_back(j, :) = [fwd_pk_arrival_frac, back_pk_arrival_frac];
    pk_width_fwd_back(j, :) = [fwd_pk_width, back_pk_width];

    %% Add in noise term
    freq = freq + noise_term;
end

%% Write data to binary files
datestr_ = string(datetime('now', 'Format', 'yyyyMMdd.hhmm'));

% Write frequency data
freq_fname = datestr_ + "_frequencies";
freq_fid = fopen(fullfile(dir_path, freq_fname), 'w', 'b');
fwrite(freq_fid, freq);

% Write time data
time_fname = datestr_ + "_time";
time_fid = fopen(fullfile(dir_path, time_fname), 'w', 'b');
fwrite(time_fid, time);

% Write valve state data
vs_fname = datestr_ + "_valvestates";
vs_fid = fopen(fullfile(dir_path, vs_fname), 'w', 'b');
fwrite(vs_fid, valve_state);

fclose('all');

%% Write mass calibration json file
datestr_ = string(datetime('now', 'Format', 'yyyyMMdd'));
st.cal_factor_pg_per_hz = mass_cal_factor;
st.cv_mass = mass_cal_cv;
fname = datestr_ + "_12um_mass_calibration.json";
json_id = fopen(fullfile(dir_path, fname), 'w');
js_str = jsonencode(st, PrettyPrint=true);
fprintf(jsonID, js_str);
fclose(json_id);

%% Write density baseline frequency calibration json file
slope = (back_baseline_freq - fwd_baseline_freq) / ...
    ((back_fluid_dens_kgm3 - fwd_fluid_dens_kgm3) / 1000);
intercept = fwd_baseline_freq - slope * (fwd_fluid_dens_kgm3 / 1000);

st.slope = slope;
st.intercept = intercept;
fname = datestr_ + "_density_baseline_calibration.json";
json_id = fopen(fullfile(dir_path, fname), 'w');
js_str = jsonencode(st, PrettyPrint=true);
fprintf(jsonID, js_str);
fclose(json_id);

%% Write ground truth file
gt_table = table();
gt_table.particle_idx = (1:n_traps)';
gt_table.fwd_bl_fit_a = fwd_bl_fit_abc(:, 1);
gt_table.fwd_bl_fit_b = fwd_bl_fit_abc(:, 2);
gt_table.fwd_bl_fit_c = fwd_bl_fit_abc(:, 3);
gt_table.back_bl_fit_a = back_bl_fit_abc(:, 1);
gt_table.back_bl_fit_b = back_bl_fit_abc(:, 2);
gt_table.back_bl_fit_c = back_bl_fit_abc(:, 3);
gt_table.fwd_local_curv = local_curv_fwd_back(:, 1);
gt_table.back_local_curv = local_curv_fwd_back(:, 2);
gt_table.fwd_buoy_mass = buoy_mass_fwd_back(:, 1);
gt_table.back_buoy_mass = buoy_mass_fwd_back(:, 2);
gt_table.dry_mass_gcm3 = dry_mass_arr;
gt_table.dry_vol_fl = dry_vol_arr;
gt_table.tot_vol_fl = tot_vol_arr;
gt_table.rel_water_content = rel_wc_arr;
gt_table.fwd_arrival_frac = arrival_frac_fwd_back(:, 1);
gt_table.back_arrival_frac = arrival_frac_fwd_back(:, 2);
gt_table.fwd_pk_width_dp = pk_width_fwd_back(:, 1);
gt_table.back_pk_width_dp = pk_width_fwd_back(:, 2);

writetable(gt_table, fullfile(dir_path, "ground_truth_per_cell.csv"))

end