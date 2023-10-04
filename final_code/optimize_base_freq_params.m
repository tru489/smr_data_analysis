function [paired_dv, opt_slope, opt_intercept] = ...
    optimize_base_freq_params(paired_data, fl1_ref_freq, fl2_ref_freq, ...
    intercept, slope, mass_cal_factor)
% Automated/manual optimization of density baseline calibration parameters
% using two rounds of single variable optimization (first to minimize mean
% error of volume measurements, second to minimize mean error of density
% measurements)
%
% Arguments:
%   paired_data (table): paired data comprising data from paired particles
%   fl1_ref_freq (double): reference frequency for fluid 1
%   fl2_ref_freq (double): reference frequency for fluid 2
%   intercept (double): intercept for linear regression of density baseline
%       calibration
%   slope (double): slope for linear regression of density baseline calibration
%   mass_cal_factor (double): mass calibration factor (pg/Hz)
% Returns:
%   paired_dv (table): paired data containing single-cell density and
%       volume information
%   opt_slope (double): optimized slope value for density baseline
%       calibration
%   opt_intercept (double): optimized intercept value for density baseline
%       calibration

% Using non-calibrated parameters, generate first round of density/volume
% values
paired_data = ...
    calc_particle_dens_vol(paired_data, fl1_ref_freq, fl2_ref_freq, ...
    intercept, slope, mass_cal_factor);
paired_data = gate_outliers_dens_vol(paired_data);

%% Gate particle populations into groups by density/volume
fprintf('\nReference calibration particle densities:\n');
fprintf('    Polystyrene --> 1.05 g/cm^3\n');
gt_density = input('Density of calibration particle (g/cm^3)? : ');

sel_fig = figure; 
plot(paired_data.density_gcm3, paired_data.volume_fl)
xlabel('Density (g/cm^3)'); ylabel('Volume (fl)');

num_particle_groups = input('Number of bead populations: ');
group_logis = cell(1, num_particle_groups);
group_vols = zeros(1, num_particle_groups);
for i = 1:num_particle_groups
    fprintf('Gate density and volume for particle %d...', i)
    [density_gate, volume_gate] = ginput(2);
    dens_logi = paired_data.density_gcm3 > min(density_gate) & ...
        paired_data.density_gcm3 < min(density_gate);
    vol_logi = paired_data.volume_fl > min(volume_gate) & ...
        paired_data.volume_fl < min(volume_gate);
    group_logis{i} = dens_logi & vol_logi;

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
    group_vols(i) = 4/3 * pi * (diameter / 2)^3; % fl
end

%% Define error functions for automatic optimization
function avg_error = volume_avg_error(paired_data, fl1_ref_freq, ...
        fl2_ref_freq, intercept, slope, mass_cal_factor, group_vols, ...
        group_logis)
    vol_errors = zeros(1,length(group_logis));
    for j = 1:length(group_logis)
        pd_slice = paired_data(group_logis{j}, :);
        pd_slice = ...
            calc_particle_dens_vol(pd_slice, fl1_ref_freq, fl2_ref_freq, ...
            intercept, slope, mass_cal_factor);
        gt_vol = group_vols(j);
        vol_errors(j) = (mean(pd_slice.volume_fl) - gt_vol) ^ 2;
    end
    avg_error = mean(vol_errors);
end

function avg_error = density_avg_error(paired_data, fl1_ref_freq, ...
        fl2_ref_freq, intercept, slope, mass_cal_factor, gt_density, ...
        group_logis)
    dens_errors = zeros(1,length(group_logis));
    for k = 1:length(group_logis)
        pd_slice = paired_data(group_logis{k}, :);
        pd_slice = ...
            calc_particle_dens_vol(pd_slice, fl1_ref_freq, fl2_ref_freq, ...
            intercept, slope, mass_cal_factor);
        dens_errors(k) = (mean(pd_slice.volume_fl) - gt_density) ^ 2;
    end
    avg_error = mean(dens_errors);
end

%% Adjust volume via single-variable optimization of slope
disp('Optimizing baseline density calibration slope value...')
before_opt_paired_data = paired_data;
erf_handle_vol = ...
    @(temp_slope) volume_avg_error(paired_data, fl1_ref_freq, ...
        fl2_ref_freq, intercept, temp_slope, mass_cal_factor, group_vols, ...
        group_logis);
slope_opt = fminbnd(erf_handle_vol, 0.75 * slope, 1.25 * slope);

paired_data_vol_opt = ...
    calc_particle_dens_vol(paired_data, fl1_ref_freq, fl2_ref_freq, ...
    intercept, slope_opt, mass_cal_factor);

% Plot volume optimization
vol_opt_fig = figure;
subplot(1, 2, 1); 
plot(before_opt_paired_data.density_gcm3, before_opt_paired_data.volume_fl)
title('Before optimization')
xlabel('Density (g/cm^3)'); ylabel('Volume (fl)');
subplot(1, 2, 2); 
plot(paired_data_vol_opt.density_gcm3, paired_data_vol_opt.volume_fl)
title('After volume optimization')
xlabel('Density (g/cm^3)'); ylabel('Volume (fl)');
input('Continue? (any key)')
close(vol_opt_fig)

%% Adjust density via single-variable optimization of intercept
disp('Optimizing baseline density calibration intercept value...')
erf_handle_dens = ...
    @(temp_intercept) volume_avg_error(paired_data, fl1_ref_freq, ...
        fl2_ref_freq, temp_intercept, slope_opt, mass_cal_factor, ...
        group_vols, group_logis);
intercept_opt = fminbnd(erf_handle_dens, 0.75 * intercept, 1.25 * intercept);

paired_data_all_opt = ...
    calc_particle_dens_vol(paired_data, fl1_ref_freq, fl2_ref_freq, ...
    intercept_opt, slope_opt, mass_cal_factor);

% Plot volume and density optimization
all_opt_fig = figure;
subplot(1, 2, 1); 
plot(before_opt_paired_data.density_gcm3, before_opt_paired_data.volume_fl)
title('Before optimization')
xlabel('Density (g/cm^3)'); ylabel('Volume (fl)');
subplot(1, 2, 2); 
plot(paired_data_all_opt.density_gcm3, paired_data_all_opt.volume_fl)
title('After density optimization')
xlabel('Density (g/cm^3)'); ylabel('Volume (fl)');
input('Continue? (any key)')
close(all_opt_fig)

%% Manual optimization to refine parameters
do_manual_opt = input('Perform manual optimiziation (y/n)? ', 's');
if do_manual_opt == 'y'
    disp('Original parameters:')
    fprintf('    Slope: %0.5f\n', slope)
    fprintf('    Intercept: %0.5f\n', intercept)

    before_manual_opt = before_opt_paired_data;
    after_manual_opt = paired_data_all_opt;
    
    complete = 0;
    while ~complete
        disp('Modified parameters:')
        fprintf('    Slope: %0.5f\n', slope_opt)
        fprintf('    Intercept: %0.5f\n', intercept_opt)

        man_opt_fig = figure;
        subplot(1, 2, 1); 
        plot(before_manual_opt.density_gcm3, before_manual_opt.volume_fl)
        title('Before parameter change')
        xlabel('Density (g/cm^3)'); ylabel('Volume (fl)');
        subplot(1, 2, 2); 
        plot(after_manual_opt.density_gcm3, after_manual_opt.volume_fl)
        title('After parameter change')
        xlabel('Density (g/cm^3)'); ylabel('Volume (fl)');
        
        is_complete = input('Finish manual optimization (y/n)? ', 's');
        if is_complete == 'y'
            break
        end

        slope_opt = input('Modified slope value: ');
        intercept_opt = input('Modified intercept value: ');

        paired_data_new = ...
            calc_particle_dens_vol(paired_data, fl1_ref_freq, fl2_ref_freq, ...
            intercept_opt, slope_opt, mass_cal_factor);
        
        before_manual_opt = after_manual_opt;
        after_manual_opt = paired_data_new;
    end
end

end