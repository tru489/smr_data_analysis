function [final_opt_paired, slope_opt, intercept_opt] = ...
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
%   final_opt_paired (table): paired data containing single-cell density and
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
% paired_data = gate_outliers_dens_vol(paired_data);

%% Gate particle populations into groups by density/volume
fprintf('\nReference calibration particle densities:\n');
fprintf('    Polystyrene --> 1.05 g/cm^3\n');
gt_density = input('Density of calibration particle (g/cm^3)? : ');

num_particle_groups = input('Number of bead populations: ');
group_logis = cell(1, num_particle_groups);
group_vols = zeros(1, num_particle_groups);

% plot_scatter_histogram(paired_data, 'density_gcm3', 'volume_fl', ...
%     'Dry density (g/cm3)', 'Dry volume (fl)', 1)
scatter(paired_data.density_gcm3, paired_data.volume_fl);
xlabel('Density (g/cm^3)'); ylabel('Volume (fl)');

for i = 1:num_particle_groups
    fprintf('Gate density and volume for particle %d...', i)
    [density_gate, volume_gate] = ginput(2);
    dens_logi = paired_data.density_gcm3 > min(density_gate) & ...
        paired_data.density_gcm3 < max(density_gate);
    vol_logi = paired_data.volume_fl > min(volume_gate) & ...
        paired_data.volume_fl < max(volume_gate);
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
        dens_errors(k) = (mean(pd_slice.density_gcm3) - gt_density) ^ 2;
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

slope_min_bnd = min(0.75 * slope, 1.25 * slope);
slope_max_bnd = max(0.75 * slope, 1.25 * slope);
slope_opt = fminbnd(erf_handle_vol, slope_min_bnd, slope_max_bnd);

paired_data_vol_opt = ...
    calc_particle_dens_vol(paired_data, fl1_ref_freq, fl2_ref_freq, ...
    intercept, slope_opt, mass_cal_factor);

% Display metrics 
for i = 1:length(group_logis)
    sliced_unopt = paired_data(group_logis{i}, :);
    sliced_vol_unopt = sliced_unopt.volume_fl;
    
    sliced_opt = paired_data_vol_opt(group_logis{i}, :);
    sliced_vol_opt = sliced_opt.volume_fl;
    
    radius_for_disp = 2 * (3 * group_vols(i) / (4 * pi)) ^ (1/3);
    fprintf('%.03f um particle:\n', radius_for_disp)
    fprintf('    Mean volume (optimized): %.03f fl\n', mean(sliced_vol_opt))
    fprintf('      Ground truth volume: %.03f fl\n', group_vols(i))
    fprintf('      Mean volume (unoptimized): %.03f fl\n', mean(sliced_vol_unopt))
    fprintf('    CV volume (optimized): %.03f%%\n', 100 * std(sliced_vol_opt) / mean(sliced_vol_opt))
    fprintf('      CV volume (unoptimized): %.03f%%\n', 100 * std(sliced_vol_unopt) / mean(sliced_vol_unopt))
end

% Plot volume optimization
disp('Plotting unoptimized and optimized volume values...')
vol_opt_fig = figure;
subplot(1, 2, 1); 
scatter(before_opt_paired_data.density_gcm3, before_opt_paired_data.volume_fl)
title('Before optimization')
xlabel('Density (g/cm^3)'); ylabel('Volume (fl)');
before_ylim = ylim;
subplot(1, 2, 2); 
scatter(paired_data_vol_opt.density_gcm3, paired_data_vol_opt.volume_fl)
title('After volume optimization')
xlabel('Density (g/cm^3)'); ylabel('Volume (fl)');
ylim(before_ylim)
input('Continue? (any key)')
close(vol_opt_fig)

%% Adjust density via single-variable optimization of intercept
disp('Optimizing baseline density calibration intercept value...')
erf_handle_dens = ...
    @(temp_intercept) density_avg_error(paired_data, fl1_ref_freq, ...
        fl2_ref_freq, temp_intercept, slope_opt, mass_cal_factor, gt_density, ...
        group_logis);

intercept_min_bnd = min(0.75 * intercept, 1.25 * intercept);
intercept_max_bnd = max(0.75 * intercept, 1.25 * intercept);
intercept_opt = fminbnd(erf_handle_dens, intercept_min_bnd, intercept_max_bnd);

paired_data_all_opt = ...
    calc_particle_dens_vol(paired_data, fl1_ref_freq, fl2_ref_freq, ...
    intercept_opt, slope_opt, mass_cal_factor);

% Display metrics 
for i = 1:length(group_logis)
    sliced_unopt = paired_data(group_logis{i}, :);
    sliced_dens_unopt = sliced_unopt.density_gcm3;
    
    sliced_opt = paired_data_all_opt(group_logis{i}, :);
    sliced_dens_opt = sliced_opt.density_gcm3;
    
    radius_for_disp = 2 * (3 * group_vols(i) / (4 * pi)) ^ (1/3);
    fprintf('%.03f um particle:\n', radius_for_disp)
    fprintf('    Mean density (optimized): %.03f g/cm3\n', mean(sliced_dens_opt))
    fprintf('      Ground truth density: %.03f g/cm3\n', gt_density)
    fprintf('      Mean density (unoptimized): %.03f g/cm3\n', mean(sliced_dens_unopt))
    fprintf('    CV density (optimized): %.03f%%\n', 100 * std(sliced_dens_opt) / mean(sliced_dens_opt))
    fprintf('      CV density (unoptimized): %.03f%%\n', 100 * std(sliced_dens_unopt) / mean(sliced_dens_unopt))
end

% Plot volume and density optimization
all_opt_fig = figure;
subplot(1, 2, 1); 
scatter(before_opt_paired_data.density_gcm3, before_opt_paired_data.volume_fl)
title('Before optimization')
xlabel('Density (g/cm^3)'); ylabel('Volume (fl)');
before_ylim = ylim;
subplot(1, 2, 2); 
scatter(paired_data_all_opt.density_gcm3, paired_data_all_opt.volume_fl)
title('After density optimization')
xlabel('Density (g/cm^3)'); ylabel('Volume (fl)');
ylim(before_ylim);
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
            final_opt_paired = after_manual_opt;
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
else
    final_opt_paired = paired_data_all_opt;
end

end