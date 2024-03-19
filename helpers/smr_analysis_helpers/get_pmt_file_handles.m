function pmt_file_ID = get_pmt_file_handles(run_params)
% Iterates through a given number of PMT channels to get a file for each
% one
%
% Arguments:
%   run_params (struct): running parameters for analysis

n_pmt_channel = run_params.fl_excl.n_pmt_channel;
pmt_file_ID = zeros(n_pmt_channel, 1); % PMT local file IDs

% Loop through to get each PMT local file ID
for i = 1:n_pmt_channel
    % Open PMT file and create a local file ID for extracting data 
    % downstream
    [pmt_file_ID(i), ~] = get_raw_file_handle(sprintf('PMT channel %d', i));
end

end