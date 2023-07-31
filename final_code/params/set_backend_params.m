function run_params = set_backend_params(run_params)
% Set backend parameters (data analysis parameters that will likely not
% have to be changed
% 
% Arguments: 
%   run_params (struct): running parameters for analysis
% Returns:
%   run_params (struct): running parameters for analysis with backend
%       parameters added

%% Frequency data parsing
% Size (in datapoints of each data segment) to be read in from full 
% freqeuency/time paired dataset
run_params.backend.datasize = 2e6;

end

