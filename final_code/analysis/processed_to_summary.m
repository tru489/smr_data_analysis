function summary_pks = processed_to_summary(run_params, processed_freq_data, init_time, ...
    mass_cal_factor)
% Takes processed frequency data from preprocessing scripts and converts to
% summary of peak data used for downstream analysis
%
% Arguments:
%   run_params (struct): running params for analysis
%   processed_freq_data (double): processed frequency peak data from
%       preprocessing scripts
%   init_time (double): initial global time at which the first data
%       acquisition event ocurred in order to allow for comparability with
%       PMT data
%   mass_cal_factor (double): pg to Hz mass calibration factor. Optional;
%       if not specified than this function is likely being called for mass
%       calibration
% Returns:
%   summary_pks (table): table containing summary peak information

arguments
    run_params
    processed_freq_data
    init_time
    mass_cal_factor = NaN
end

%% Convert processed individual peak data to peak summary data
% Filter out zero columns
idx_nonzero = processed_freq_data(12,:) > 0;
processed_nonzero = processed_freq_data(:, idx_nonzero);

% Find indices of unique peak sets (i.e. start indices of sets 3 peaks)
idx = find(diff(processed_nonzero(12,:)) ~= 0);
idx = [0 idx];

% Preallocate summary array
pk_ht1_hz = zeros(length(idx), 1);
pk_ht2_hz = zeros(length(idx), 1);
pk_ht3_hz = zeros(length(idx), 1);
real_time_s = zeros(length(idx), 1);
peak_time_s = zeros(length(idx), 1);
peak_time_m = zeros(length(idx), 1);
peak_time_h = zeros(length(idx), 1);
avg_pk_ht_hz = zeros(length(idx), 1);
avg_baseline = zeros(length(idx), 1);
pk_fwhm = zeros(length(idx), 1);
node_dev_1 = zeros(length(idx), 1);
node_dev_2 = zeros(length(idx), 1);
node_dev_mean = zeros(length(idx), 1);
bl_slope = zeros(length(idx), 1);
segment_num = zeros(length(idx), 1);
transit_t = zeros(length(idx), 1);
pk_order = zeros(length(idx), 1);
valve_state = zeros(length(idx), 1);
mass_pg = zeros(length(idx), 1);

% Iterate through each unique peak set
for i=1:length(idx)
    % Temporary indices of this peakset
    if i == length(idx)
        temp_idx = idx(i) + 1:length(processed_nonzero);
    else
        temp_idx = idx(i) + 1:idx(i+1);
    end
    
    % Peak heights
    m1 = processed_nonzero(2, temp_idx(1));
    m3 = processed_nonzero(2, temp_idx(end));
    
    % Node deviations
    nd1 = processed_nonzero(8, temp_idx(1));
    nd2 = processed_nonzero(8, temp_idx(2));

    % Times of first and last peaks
    t1 = processed_nonzero(1, temp_idx(1));
    t2 = processed_nonzero(1, temp_idx(end));
    
    % Heights of left, middle, and right peaks
    pk_ht1_hz(i) = processed_nonzero(2, temp_idx(1));
    pk_ht2_hz(i) = processed_nonzero(2, temp_idx(2));
    pk_ht3_hz(i) = processed_nonzero(2, temp_idx(end));
    
    % Average baseline of left and right peak
    b1 = mean([processed_nonzero(4, temp_idx(1)) ...
        processed_nonzero(5, temp_idx(1))]);
    b2 = mean([processed_nonzero(4, temp_idx(end)) ...
        processed_nonzero(5, temp_idx(end))]);
    
    % Populate summary pk array
    real_time_s(i) = mean([t1, t2]) + init_time;
    peak_time_s(i) = mean([t1, t2]);
    peak_time_m(i) = mean([t1, t2]) / 60;
    peak_time_h(i) = mean([t1, t2]) / 3600;
    avg_pk_ht_hz(i) = mean([m1, m3]);
    avg_baseline(i) = mean([b1, b2]);
    pk_fwhm(i) = processed_nonzero(9, temp_idx(1));
    node_dev_1(i) = processed_nonzero(8, temp_idx(1));
    node_dev_2(i) = processed_nonzero(8, temp_idx(2));
    node_dev_mean(i) = mean([nd1, nd2]);
    bl_slope(i) = processed_nonzero(7, temp_idx(1));
    segment_num(i) = processed_nonzero(10, temp_idx(1));
    transit_t(i) = processed_nonzero(6, temp_idx(1));
    pk_order(i) = processed_nonzero(12, temp_idx(1));
    valve_state(i) = processed_nonzero(13, temp_idx(2));

    if ~isnan(mass_cal_factor)
        mass_pg(i) = avg_pk_ht_hz(i) * mass_cal_factor;
    end
end

summary_pks = table();

summary_pks.real_time_s = real_time_s;
summary_pks.peak_time_s = peak_time_s;
summary_pks.peak_time_m = peak_time_m;
summary_pks.peak_time_h = peak_time_h;
summary_pks.avg_baseline = avg_baseline;
summary_pks.bl_slope = bl_slope;
summary_pks.pk_fwhm = pk_fwhm;
summary_pks.transit_t = transit_t;
summary_pks.valve_state = valve_state;
summary_pks.pk_order = pk_order;
summary_pks.segment_num = segment_num;
summary_pks.pk_ht1_hz = pk_ht1_hz;
summary_pks.pk_ht2_hz = pk_ht2_hz;
summary_pks.pk_ht3_hz = pk_ht3_hz;
summary_pks.node_dev_1 = node_dev_1;
summary_pks.node_dev_2 = node_dev_2;
summary_pks.node_dev_mean = node_dev_mean;
summary_pks.avg_pk_ht_hz = avg_pk_ht_hz;
summary_pks.mass_pg = mass_pg;

% variable_names = {'real_time_s', 'peak_time_s', 'peak_time_m', 'peak_time_h', ...
%         'avg_baseline', 'bl_slope', 'pk_fwhm', 'transit_t', 'valve_state', ...
%         'pk_order', 'segment_num', 'pk_ht1_hz', 'pk_ht2_hz', 'pk_ht3_hz', ...
%         'node_dev_1', 'node_dev_2', 'node_dev_mean', 'avg_pk_ht_hz', 'mass_pg'};
% summary_arr = [real_time_s, peak_time_s, peak_time_m, peak_time_h, ...
%     avg_baseline, bl_slope, pk_fwhm, transit_t, valve_state, pk_order, ...
%     segment_num, pk_ht1_hz, pk_ht2_hz, pk_ht3_hz, node_dev_1, node_dev_2, ...
%     node_dev_mean, avg_pk_ht_hz, mass_pg];

% if ~isnan(mass_cal_factor)
%     summary_pks = array2table(summary_arr, 'VariableNames', variable_names);
% else
%     summary_pks = array2table(summary_arr(:, 1:end-1), ...
%         'VariableNames', variable_names(1:end-1));
% end

if ~isnan(mass_cal_factor)
    summary_pks.mass_pg = mass_pg;
end

end