function create_curation_log(run_params, samplepeak, ...
    sampletime, sample_baseline_fits, datasmr)
% Creates curation log from analysis data 
% 
% Arguments:
%   run_params (struct): running parameters
%   samplepeak (array): compiled peak data
%   sampletime (array): compiled time data
%   sample_baseline_fits (array): compiled baseline fitting data
%   datasmr (array): analyzed frequency data metrics

%% Setup
% samplepeak looks like [(..data...), 1000, pkorder, sectionnumber, etc...]
% Finds the number of peaks (i.e. number of "1000s" in array)
dataidx = [];
idx0 = find(isnan(samplepeak));

% Creates local struct to store high-level peak data
Peak.count = length(idx0);
Peak.start = zeros(1, Peak.count);
Peak.process = zeros(1, Peak.count); % 2 = peak rejected; 1 = accepted
Peak.peakorder = zeros(1, Peak.count);
Peak.start(1) = 1;


end