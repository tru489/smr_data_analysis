close all;
format long;

%% Define SMR system-specific parameters (do not change)
CIC = 10000;           % CIC rate
Fs = 10^8/CIC;        % sampling rate
rng(1);             % define random number generator (fixed value, yields same stochastic numbers)

%% Define physical cantilever properties (do not change)
% Channel volume (hollow section of channel; um3)
v_channel = 20 * (((45 * 415) + (5 * 20) + 0.5 * pi * 20^2) - (5 * 415 + 0.5 * pi * 2.5^2));

% Cantilever footprint area (um2)
a_footprint = 0;

% Cantilever silicon volume (um3)
v_silicon = (20 + 2 * 2) * a_footprint - v_channel;

% Cantilever mass (kg)
dens_silicon = 7850; % kg/m^3
m_cantilever = v_silicon * dens_silicon * 1e-18; % kg

% SMR calibration factor (pg/Hz)
mass_cal_factor = 0.8;

% Effective mass fraction (for single-clamped cantilever; from theory)
m_eff_fraction = 0.25;

%% Define fluid properties
% Water density and dynamic viscosity
fwd_fluid_dens = ; % kg/m3; value for PBS
fwd_fluid_dyn_visc = ; % Pa*s; value for PBS

% Heavy water density and dynamic viscosity
back_fluid_dens = ; % kg/m3; value for 90% D2O-PBS
back_fluid_dyn_visc = ; % Pa*s; value for 90% D2O-PBS

%% Define noise parameters
noise_level = 0.022; % standard deviation sigma of noise in (Hz)
alpha_factor = 1;     % decay factor of noise (alpha_factor=0 for white noise, 1 for pink, 2 for brown and 1-2 colored)

%% Baseline SMR frequency values 
fwd_baseline_freq = 1.6e6; % Hz
back_baseline_freq = 1.45e6; % Hz

%% Define peak/segment duration parameters
n_traps = 300; % Number of particles measured

% Forward measurement
fwd_pk_arrival_frac = 0.9; % percent; percent of total search time at which particle appears
fwd_search_time = 3; % s; time taken to seek new particle
fwd_pk_width = 300; % datapoints; peak width

% Backward measurement
back_pk_arrival_frac = 0.5; % percent; percent of total search time at which particle appears
back_search_time = 8; % s; time taken to seek new particle
back_pk_width = 300; % datapoints; peak width

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
back_vstate - 7;
valve_state = zeros(total_datapoints, 1);
for i = 1:length(fwd_idx_start_datapoints)
    fwd_start_temp = fwd_idx_start_datapoints(i);
    back_start_temp = back_idx_start_datapoints(i);
    valve_state(fwd_start_temp:back_start_temp - 1) = fwd_vstate;
    valve_state(back_start_temp:fwd_idx_start_datapoints(i+1)) = back_vstate;
end

%% Generate noise term
Colornoise_2 = dsp.ColoredNoise(alpha_factor, total_datapoints, ...
    'OutputDataType', 'double');
target_noise_Hz = noise_level;
noise_term = Colornoise_2()'/std(Colornoise_2()') * noise_level;

%% Start simulation
for j = 1:n_traps
    fwd_start_idx = fwd_idx_start_datapoints(j);
    back_start_idx = back_idx_start_datapoints(j);
    
    % Cantilever mass
    m_eff_theoretical_kg = m_cantilever * m_eff_fraction;

    % Physics simulation parameters ----------- TODO
    ab = ab_value(fo_Hz, r_active_m, dyn_visc, density_current_kgm3, ...
        density_w_kgm3);
    [ad, Reynolds_water_height] = ad_value(fo_Hz, rs_m, dyn_visc, ...
        channel_height_m, density_w_kgm3);
    [u, x, dudx] = U_n(1, mode_number, number_points, type_of_resonator);


end
