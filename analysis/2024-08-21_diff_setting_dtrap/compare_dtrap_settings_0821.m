close all;
addpath(genpath("..\..\helpers"));

%% Get data
org_params = readtable('data\orig_params.csv');
org_mask = org_params.density_gcm3 < 1.056 & org_params.density_gcm3 > 1.044;
org_params = org_params(org_mask, :);

mod_params = readtable('data\mod_params.csv');
org_mask = mod_params.density_gcm3 < 1.064 & mod_params.density_gcm3 > 1.047;
mod_params = mod_params(org_mask, :);

%% Create plots
% Full mod
fh_mod_full = figure;
s2 = scatter(mod_params.volume_fl, mod_params.density_gcm3, 40, 'b', 'filled'); 
s2.MarkerFaceAlpha=0.3;
xlabel('Dry volume (fL)', FontSize=14); ylabel('Dry density (g/cm3)', FontSize=14);
ax=gca; ax.FontSize=13;
saveas(fh_mod_full, 'fig\mod_full_dv.jpg')

% Timeseries density mod
fh_ts_dens_mod = figure;
s2 = scatter(mod_params.fl1_peak_time_s, mod_params.density_gcm3, 40, 'b', 'filled'); 
s2.MarkerFaceAlpha=0.3;
xlabel('Time (s)', FontSize=14); ylabel('Dry density (g/cm3)', FontSize=14);
ax=gca; ax.FontSize=13;
saveas(fh_ts_dens_mod, 'fig\mod_ts_dens.jpg')

ts_mask = mod_params.fl1_peak_time_s > 3000;
mod_params_filt = mod_params(ts_mask,:);

% Comparing bead populations
fh_comp = figure(Position=[612   348   560   541]); hold on;
s1 = scatter(org_params.volume_fl, org_params.density_gcm3, 40, 'r', 'filled', DisplayName='No D2O jiggle'); 
s1.MarkerFaceAlpha=0.3;

s2 = scatter(mod_params_filt.volume_fl, mod_params_filt.density_gcm3, 40, 'b', 'filled', DisplayName='With D2O jiggle'); 
s2.MarkerFaceAlpha=0.3;

xlabel('Dry volume (fL)', FontSize=14); ylabel('Dry density (g/cm3)', FontSize=14);
ax=gca; ax.FontSize=13;
legend(Location='southoutside')
saveas(fh_ts_dens_mod, 'fig\fh_comp.jpg')

% colormap jet
% colorbar