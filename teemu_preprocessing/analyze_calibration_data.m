% Script for determining calibration factor from bead measurements
close all;

[path, dir] = uigetfile('../*.*','Select Data File',' ');
data = readmatrix([dir path]);
freqs = data(:,3);

fprintf('\nReference calibration particles:\n');
fprintf('    7 um --> 6.976 um\n');
fprintf('    9 um --> 8.956 um\n');
fprintf('    10 um --> 10.12 um\n');
fprintf('    12 um --> 12.01 um\n');
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
fprintf('Percent CV of mass: %.2f%%\n', 100 * std(cal_freqs) / mean(cal_freqs))

data_pg_masses = [data((freqs > x_left) & (freqs < x_right), :), ...
    cal_freqs];
[full_path, fname, ext] = fileparts([dir path]);
new_fpath = [full_path filesep fname '_pg_masses' ext];
writematrix(data_pg_masses, new_fpath)

fileID = fopen([full_path filesep 'calibration.txt'], 'w');
fprintf(fileID, 'Ground truth particle buoyant mass: %f pg\n', gt_mass);
fprintf(fileID, 'Average frequency difference: %f Hz\n', avg_freq);

fprintf(fileID, '\nCalibration factor: %.4f pg/Hz\n', cal_factor);
fprintf(fileID, 'Percent CV of mass: %.2f%%\n', ...
    100 * std(cal_freqs) / mean(cal_freqs));

