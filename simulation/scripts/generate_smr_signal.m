close all;
format long;

%% Define SMR system-specific parameters (do not change)
CIC=8000;           % CIC rate
Fs=10^8/CIC;        % sampling rate
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
h2o_fluid_dens = ; % kg/m3; value for PBS
h2o_fluid_dyn_visc = ; % Pa*s; value for PBS

% Heavy water density and dynamic viscosity
d2o_fluid_dens = ; % kg/m3; value for 90% D2O-PBS
d2o_fluid_dyn_visc = ; % Pa*s; value for 90% D2O-PBS

%% Define noise parameters
noise_level = 0.022; % standard deviation sigma of noise in (Hz)
alpha_factor = 1;     % decay factor of noise (alpha_factor=0 for white noise, 1 for pink, 2 for brown and 1-2 colored)

%% Start simulation
