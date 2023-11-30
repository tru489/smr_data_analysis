close all;
addpath(genpath('../../final_code'),...
    genpath('helpers'))

%% Params
fwd_vs = 11;
back_vs = 7;

%% Paths
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
valve_state = fread(vsfile);

% valve_state, just with all the repeated values removed
vs_strip_repeats = valve_state([true; diff(valve_state) ~= 0]);
vs_strip_repeats_fwd_back = vs_strip_repeats(vs_strip_repeats == back_vs | vs_strip_repeats == fwd_vs);

% freq, vs, time files, just with all data for valve states not
% corresponding to the forward or back measurements removed
% Also: trim arrays so the first valve state "block" contains the fwd vs
% and the last contains the back vs
freq_strip = freq(valve_state == fwd_vs | valve_state == back_vs);
time_strip = time(valve_state == fwd_vs | valve_state == back_vs);
vs_strip = valve_state(valve_state == fwd_vs | valve_state == back_vs);

for j = 1:length(vs_strip)
    if vs_strip(j) == fwd_vs
        leading_trim = j;
        break
    end
end

for k = 0:length(vs_strip) - 1
    if vs_strip(length(vs_strip) - k) == back_vs
        trailing_trim = length(vs_strip) - k;
        break
    end
end

freq_strip = freq_strip(leading_trim:trailing_trim);
time_strip = time_strip(leading_trim:trailing_trim);
vs_strip = vs_strip(leading_trim:trailing_trim);

%% Extract baselines for forward peaks
fwd_vs_logi = vs_strip == fwd_vs;
state_change_diff = diff(fwd_vs_logi);
fwd_start_idxs = [1, 1 + find(state_change_diff == 1)'];
fwd_end_idxs = find(state_change_diff == -1)';
back_start_idxs = fwd_end_idxs + 1;
back_end_idxs = [fwd_start_idxs(2:end) - 1, length(vs_strip)];

%% Polynomial fit for each segment
% for i = 1:length(fwd_start_idxs)
%     start_idx_temp = fwd_start_idxs(i);
%     end_idx_temp = fwd_end_idxs(i);
%     bl_seg = freq_strip(start_idx_temp:end_idx_temp);
%     bl_seg = bl_seg(100:end);
% end

for i = 1:length(back_start_idxs) % 1:length(back_start_idxs)
    start_idx_temp = back_start_idxs(i);
    end_idx_temp = back_end_idxs(i);
    bl_seg = freq_strip(start_idx_temp:end_idx_temp);
    bl_seg = bl_seg(find(abs(diff(bl_seg)) > 10, 1, 'first') + 50:end);

    figure; 
    plot(bl_seg, 'DisplayName', 'raw', 'LineWidth', 2); 
    hold on;

    pf2 = polyfit(1:length(bl_seg), bl_seg, 2);
    pf3 = polyfit(1:length(bl_seg), bl_seg, 3);
    pf_log = polyfit(log(((1:length(bl_seg)) + 600)), bl_seg, 1);
    pf_exp = polyfit(exp(-(1:length(bl_seg))), bl_seg, 1);

    pf2_fit = polyval(pf2, 1:length(bl_seg));
    pf2_rsq = get_rsq(bl_seg, pf2_fit');
    pf2_dname = sprintf("$$ax^2+bx+c, r^2 = %0.2f$$", pf2_rsq);
    plot(pf2_fit, 'r--', 'DisplayName', pf2_dname, 'LineWidth', 2);

    pf3_fit = polyval(pf3, 1:length(bl_seg));
    pf3_rsq = get_rsq(bl_seg, pf3_fit');
    pf3_dname = sprintf("$$ax^3+bx^2+cx+d, r^2 = %0.2f$$", pf3_rsq);
    plot(pf3_fit, 'g--', 'DisplayName', pf3_dname, 'LineWidth', 2);
    
    pf_log_fit = polyval(pf_log, log(((1:length(bl_seg)) + 600)));
    pf_log_rsq = get_rsq(bl_seg, pf_log_fit');
    pf_log_dname = sprintf("$$alog(x)+b, r^2 = %0.2f$$", pf_log_rsq);
    plot(pf_log_fit, 'b--', 'DisplayName', pf_log_dname, 'LineWidth', 2);

    % pf_exp_fit = polyval(pf_exp, exp(-(1:length(bl_seg))));
    % pf_exp_rsq = get_rsq(bl_seg, pf_exp_fit');
    % pf_exp_dname = sprintf("$$-ae^{-x}+b, r^2 = %0.2f$$", pf_exp_rsq);
    % plot(pf_exp_fit, 'k--', 'DisplayName', pf_exp_dname, 'LineWidth', 2);
    
    legend('Location', 'southwest', 'FontSize', 10, 'Interpreter', 'latex')
    % input('Continue? ');
end

%% Select segments of baseline for SMR baseline noise analysis
num_bl_choices = 20;
block_size = 1e6;

idx_arr = zeros(num_bl_choices, 2);
for i = 1:num_bl_choices
    ivals = block_size * (i-1) + 1:block_size * i;
    xvals = time(ivals);
    yvals = freq(ivals);
    plot(xvals, yvals)
    input('Ready to select?');
    [idxs, ~] = ginput(2);
    idx_arr(i,:) = sort(idxs);
end

stdev_arr = zeros(size(idx_arr, 1), 1);
alpha_arr = zeros(size(idx_arr, 1), 1);
for i = 1:size(idx_arr, 1)
    noise_bounds = idx_arr(1, :);
    noise = freq(noise_bounds(1):noise_bounds(2));

    % Calculate stdev of noise
    stdev_arr(i) = std(noise);
    
    % Use discrete wavelet analysis to calculate estimated alpha factor of noise
    % (from PSD)
    [dh, hb, cp] = dwtleader(noise);
    alpha_arr(i) = -2 * cp(1) - 1;
end

disp('Average and std of std(noise):')
fprintf('    Average = %0.5f', mean(stdev_arr))
fprintf('    Std = %0.5f', std(stdev_arr))
disp('Average and std of alpha: ')
fprintf('    Average = %0.5f', mean(alpha_arr))
fprintf('    Std = %0.5f', std(alpha_arr))

%% Write feature extraction file
num_vs_changes = length(strfind(vs_strip_repeats', [11, 7]));
