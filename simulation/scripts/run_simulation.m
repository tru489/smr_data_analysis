close all;
format long;

%% Save path for output files
dir_path = '';

%% Define noise parameters
% Standard deviation sigma of noise in (Hz)
noise_level = 0.022; 

% PSD decay factor of noise (alpha_factor=0 for white noise, 1 for pink, 
% 2 for brown and 1-2 colored)
alpha_factor = 1;

%% Define peak/segment duration parameters
n_traps = 300; % Number of particles measured

% Forward measurement
fwd_pk_arrival_frac = [0.9]; % percent; percent of total search time at which particle appears
fwd_search_time = 3; % s; time taken to seek new particle
fwd_pk_width = [300]; % datapoints; peak width

% Backward measurement
back_pk_arrival_frac = [0.5]; % percent; percent of total search time at which particle appears
back_search_time = 8; % s; time taken to seek new particle
back_pk_width = [300]; % datapoints; peak width

%% Cell biophysical properties
cell_dry_density_gcm3 = [nan]; % g/cm3
cell_dry_volume_fl = [nan]; % fl
cell_total_volume_fl = [nan]; % fl

%% Baseline curvature
% From baseline polynomial fit of form a*x^2 + bx + c
% Forward peak
fwd_pkfit_a = [0];
fwd_pkfit_b = [0];
fwd_pkfit_c = [0];

% Backward peak
back_pkfit_a = [-3.5 / (1e4)^2];
back_pkfit_b = [35 / 1e4];
back_pkfit_c = [50];


