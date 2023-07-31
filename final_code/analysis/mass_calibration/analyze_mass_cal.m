function analyze_mass_cal(run_params, datasmr, save_dir)
% Analyzes peakset data summary from a run of magnetic beads to product
% calibration information. Requires input of bead/carrier fluid data.
% Produces filtered peakset summary (optional) and json with important
% calibration information (required for all analysis types)
%
% Arguments:
%   run_params (struct): parameters necessary for running analysis
%   datasmr (array(double)): peakset summary array 
%   save_dir (str): dir in which to save json/filtered peakset summary

freqs = datasmr(:,3);

fprintf('\nReference calibration particles:\n');
fprintf('    4 um --> 4.000 um\n');
fprintf('    6 um --> 6.007 um\n');
fprintf('    7 um --> 6.976 um\n');
fprintf('    8 um --> 7.979 um\n');
fprintf('    9 um --> 8.956 um\n');
fprintf('    10 um --> 10.12 um\n');
fprintf('    12 um --> 12.01 um\n');
fprintf('    15 um --> 14.97 um\n');
diameter = input('Diameter of calibration particle (um)? : ');

fprintf('\nReference calibration particle densities:\n');
fprintf('    Polystyrene --> 1.05 g/cm^3\n');
density = input('Density of calibration particle (g/cm^3)? : ');

fprintf('\nReference fluid densities:\n');
fprintf('    Water (25C) --> 0.997 g/cm^3\n');
fprintf('    1x PBS (25C) --> 1.00 g/cm^3\n');
fl_density = input('Fluid density (g/cm^3)? : ');

flag2 = 1;
while flag2
    plt_opt = input('Remove outliers in plot (y/n)? : ', 's');
    if lower(plt_opt) == 'y'
        fig1 = figure;
        histogram(rmoutliers(freqs), 50)
        xlabel('Frequency Difference (Hz)')
        ylabel('Count')
        flag2 = 0;
    elseif lower(plt_opt) == 'n'
        fig1 = figure;
        histogram(freqs, 50)
        xlabel('Frequency Difference (Hz)')
        ylabel('Count')
        flag2 = 0;
    else
        fprintf('Invalid input.\n')
    end
end

fprintf('Select frequency gate for particles of interest...\n')
fprintf('Select left boundary...\n')
[x_left, ~] = ginput(1);

fprintf('Select right boundary...\n')
[x_right, ~] = ginput(1);
close(fig1)

freq_gated = freqs((freqs > x_left) & (freqs < x_right));
fig2 = figure; 
histogram(freq_gated, 50)
title('Gated frequency range')
xlabel('Frequency Difference (Hz)')
ylabel('Count')

bead_vol = 4/3 * pi * (diameter / 2)^3 * 10^-12; % cm^3
density_diff = (density - fl_density) * 10^12; % pg/cm^3
gt_mass = bead_vol * density_diff; % pg
avg_freq = mean(freq_gated);
cal_factor = gt_mass / avg_freq; % pg/Hz
cal_freqs = freq_gated * cal_factor;

fprintf('\nGround truth particle buoyant mass: %f pg\n', gt_mass)
fprintf('Average frequency difference: %f Hz\n', avg_freq)

fprintf('\nCalibration factor: %.4f pg/Hz\n', cal_factor)
fprintf('Percent CV of mass: %.2f%%\n', ...
    100 * std(cal_freqs) / mean(cal_freqs))

datasmr_pg_masses = [datasmr((freqs > x_left) & (freqs < x_right), :), ...
    cal_freqs];

if run_params.mass_cal.save_peak_summary
    variable_names = {'peak_time_s', 'peak_time_m', 'avg_pk_ht_hz', ...
        'avg_baseline', 'bl_slope', 'pk_ht1_hz', 'pk_ht2_hz', ...
        'pk_ht3_hz', 'node_dev_1', 'node_dev_2', 'node_dev_mean', ...
        'pk_fwhm', 'transit_t', 'segment_num', 'peak_time_h', ...
        'pk_order', 'mass_pg'};
    summary_pks_table = array2table(datasmr_pg_masses, ...
        'VariableNames', variable_names);
    writetable(summary_pks_table, fullfile(save_dir, "peak_data.csv"))
end

st.ground_truth_mass_pg = gt_mass;
st.avg_freq_hz = avg_freq;
st.cal_factor_pg_per_hz = cal_factor;
st.cv_mass = std(cal_freqs) / mean(cal_freqs);
jsonID = fopen(fullfile(save_dir, "calibration_params.json"), 'w');
js_str = jsonencode(st, PrettyPrint=true);
fprintf(jsonID, js_str);
fclose(jsonID);

end