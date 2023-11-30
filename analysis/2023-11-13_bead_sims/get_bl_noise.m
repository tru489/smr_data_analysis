% close all;
addpath(genpath('../../final_code'))

file_selection.valve_state = 1;
file_selection.mass_cal = 0;
file_selection.dens_bl_cal = 0;
file_selection.pmt_data = 0;
file_selection.cc_data = 0;

[parsed_files, data_dir, formatted_date] = parse_dir_contents(file_selection);

freqfile = parsed_files.freq_id;
timefile = parsed_files.smr_time_id;
vsfile = parsed_files.vs_id;

freq = fread(freqfile, 'float64=>double');
time = fread(timefile, 'float64=>double');

%% Extract noise segments
disp('Extract noise segments...')
num_bl_choices = 10;
block_size = 1e5;

idx_arr = zeros(num_bl_choices, 2);
for i = 1:num_bl_choices
    ivals = block_size * (i+10) + 1:block_size * (i+11);
    xvals = time(ivals);
    yvals = freq(ivals);
    plot(ivals, yvals)
    % input('Ready to select?');
    [idxs, ~] = ginput(2);
    idx_arr(i,:) = sort(idxs);
end

disp('Wavelet analysis on noise to extract alpha value...')
idx_arr = round(idx_arr);

stdev_arr = zeros(size(idx_arr, 1), 1);
alpha_arr = zeros(size(idx_arr, 1), 1);
for i = 1:size(idx_arr, 1)
    fprintf('    Iter %d of %d...\n', i, size(idx_arr, 1))
    noise_bounds = idx_arr(i, :);
    noise = freq(noise_bounds(1):noise_bounds(2));
    
    
    noise_adj = noise;
    % noise_adj = zeros(size(noise));
    % blsize = 200;
    % for j = 1:floor(length(noise) / blsize)
    %     noise_adj((j-1)*blsize+1:j*blsize) = noise((j-1)*blsize+1:j*blsize) - mean(noise((j-1)*blsize+1:j*blsize));
    % end

    % Calculate stdev of noise
    stdev_arr(i) = std(noise_adj);
    
    % Use discrete wavelet analysis to calculate estimated alpha factor of noise
    % (from PSD)
    hexp = wtmm(noise);
    alpha_arr(i) = 2 * hexp + 1;
end

disp('Average and std of std(noise):')
fprintf('    Average = %0.5f\n', mean(stdev_arr))
fprintf('    Std = %0.5f\n', std(stdev_arr))
disp('Average and std of alpha:')
fprintf('    Average = %0.5f\n', mean(alpha_arr))
fprintf('    Std = %0.5f\n', std(alpha_arr))
