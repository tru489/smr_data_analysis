close all;
format long;

addpath(genpath("helpers"))

%% Save path for output files
dir_path = "A:\thomasu\raw_data\2024-01-24\10-31-23_paired_sim_emp_rand_bl_rep1";

%% Define noise parameters
% Standard deviation sigma of noise in (Hz)
noise_level = 0.33; 

% PSD decay factor of SMR baseline noise (alpha_factor=0 for white noise, 1 
% for pink, 2 for brown etc)
alpha_factor = 0;

%% Define peak/segment duration parameters
n_particles = 66; % Number of particles measured

% Forward measurement
fwd_pk_arrival_frac = [0.5]; % percent; percent of total search time at which particle appears
fwd_search_time = 1.5; % s; time taken to seek new particle
fwd_pk_width = [normrnd(396.30, 5.75, [2000,1]); normrnd(419.14, 5.77, [2000,1])]; % datapoints; peak width

%% Fluid physical properties
% Water density and dynamic viscosity
pbs_1x_density = 1000; % kg/m3

fwd_fluid_dens_kgm3 = pbs_1x_density; % kg/m3; value for PBS
fwd_fluid_dyn_visc_pas = 8.891*10^-4; % Pa*s; value for PBS

% Heavy water density and dynamic viscosity
pbs_10x_density = 1100; % kg/m3
d2o_density = 1104.481; % kg/m3

% back_fluid_dens_kgm3 = pbs_10x_density * 0.1 + d2o_density * 0.9; % kg/m3; value for 90% D2O-PBS

%% Cell biophysical properties
cell_dry_density_gcm3 = [1.05]; % g/cm3

vol_fl_emp = 261.6449;

cell_dry_volume_fl = vol_fl_emp; % fl
cell_total_volume_fl = vol_fl_emp; % fl

% cell_dry_volume_fl = [4/3 * pi* (7.979/2)^3]; % fl
% cell_total_volume_fl = [4/3 * pi* (7.979/2)^3]; % fl

%% Baseline curvature
% From baseline polynomial fit
% Forward peak
fwd_pkfit_params = [0; 0; 0; 0];

%% Generate simulated SMR signal
generate_smr_signal_single(...
    noise_level, alpha_factor, ...
    ...
    n_particles, fwd_pk_arrival_frac, fwd_search_time, fwd_pk_width, ...
    ...
    cell_dry_density_gcm3, cell_dry_volume_fl, cell_total_volume_fl, ...
    ...
    fwd_pkfit_params, ... % Each row is a parameter, columns are candidate values
    ...
    fwd_fluid_dens_kgm3, fwd_fluid_dyn_visc_pas, ...
    ...
    dir_path)
