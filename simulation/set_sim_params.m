function sim_params = set_sim_params()
% Sets simulation parameters 
%
% Returns:
%   sim_params (struct): parameters for running simulation

% TODO
%   add params for cantilever size
%   characterize noise color for feedback

%% Set fundamental SMR parameters
sim_params = struct;
sim_params = set_smr_params(sim_params);

sim_params.noise_level = 0.022; % standard deviation sigma of noise in (Hz)
sim_params.alpha_factor = 1;     % decay factor of noise (alpha_factor=0 for white noise, 1 for pink, 2 for brown and 1-2 colored)

% 

sim_params
sim_params

end

