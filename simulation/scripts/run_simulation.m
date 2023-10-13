close all;
format long;

%% Save path for output files
dir_path = '';

%% Define noise parameters
% Standard deviation sigma of noise in (Hz)
noise_level = 0.6; 

% PSD decay factor of noise (alpha_factor=0 for white noise, 1 for pink, 
% 2 for brown and 1-2 colored)
alpha_factor = 1;

%% Define peak/segment duration parameters
n_traps = 300; % Number of particles measured

% Forward measurement
fwd_pk_arrival_frac = [0.6]; % percent; percent of total search time at which particle appears
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
% From baseline polynomial fit
% Forward peak
fwd_pkfit_params = [0; 0; 0];

% Backward peak
back_pkfit_params = [-3.5 / (1e4)^2; 35 / 1e4; 50];


