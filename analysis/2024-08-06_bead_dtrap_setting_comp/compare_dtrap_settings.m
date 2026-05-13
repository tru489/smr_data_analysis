close all;
addpath(genpath("..\..\helpers"));

orig_set = readtable("C:\thomasu\smr_data_analysis\analysis\2024-08-06_bead_dtrap_setting_comp\data\9um_bead_dens_trap_orig_settings.csv");
dens_gate = orig_set.volume_fl < 400 & orig_set.volume_fl > 345;
vol_gate = orig_set.density_gcm3 > 1.046 & orig_set.density_gcm3 < 1.054;
orig_set = orig_set(dens_gate & vol_gate, :);

figure; scatter(orig_set.volume_fl, orig_set.density_gcm3)
fprintf('-- Original settings --\n')
fprintf('    Volume std: %.5f | Volume avg: %.5f\n', std(orig_set.volume_fl), mean(orig_set.volume_fl))
fprintf('    Density std: %.5f | Density avg: %.5f\n\n', std(orig_set.density_gcm3), mean(orig_set.density_gcm3))

%%
mod_set = readtable("C:\thomasu\smr_data_analysis\analysis\2024-08-06_bead_dtrap_setting_comp\data\9um_bead_dens_trap_mod_settings.csv");
dens_gate = mod_set.volume_fl < 380 & mod_set.volume_fl > 330;
vol_gate = mod_set.density_gcm3 > 1.051 & mod_set.density_gcm3 < 1.055;
mod_set = mod_set(dens_gate & vol_gate, :);

mod_set2 = readtable("C:\thomasu\smr_data_analysis\analysis\2024-08-06_bead_dtrap_setting_comp\data\9um_bead_dens_trap_mod_settings_rep2.csv");
dens_gate = mod_set2.volume_fl < 380 & mod_set2.volume_fl > 330;
vol_gate = mod_set2.density_gcm3 > 1.051 & mod_set2.density_gcm3 < 1.055;
mod_set2 = mod_set2(dens_gate & vol_gate, :);

mod_set_comb = [mod_set; mod_set2];

% figure; hold on;
% scatter(mod_set.volume_fl, mod_set.density_gcm3)
% scatter(mod_set2.volume_fl, mod_set2.density_gcm3)

figure; hold on;
scatter(mod_set_comb.volume_fl, mod_set_comb.density_gcm3)
fprintf('-- Modified settings --\n')
fprintf('    Volume std: %.5f | Volume avg: %.5f\n', std(mod_set_comb.volume_fl), mean(mod_set_comb.volume_fl))
fprintf('    Density std: %.5f | Density avg: %.5f\n\n', std(mod_set_comb.density_gcm3), mean(mod_set_comb.density_gcm3))