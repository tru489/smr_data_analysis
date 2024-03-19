close all;
addpath(genpath("..\..\final_code"))

dens_bl_st = get_json_struct("cal", "A:\thomasu\raw_data\2024-02-20\baseline_density_cal\20240220.143252_base_freq_density_calibration_results\20240220_density_baseline_calibration.json");
slope = dens_bl_st.slope;
intc = dens_bl_st.intercept;

% slope = -148319.2;
% intc = 1307761;


%% H2O-PBS+RPMI
h2o_pth = "A:\thomasu\raw_data\2024-02-20\l1210_rpmi_h2o_pbs\20240220.144432_mass_results\2024-02-20_l1210_rpmi_h2o_pbs.csv";
h2o_tab = readtable(h2o_pth);
h2o_bm = mean(h2o_tab.mass_pg(h2o_tab.mass_pg > 28 & h2o_tab.mass_pg < 85));
h2o_bl = mean(h2o_tab.avg_baseline);
h2o_rf = 1158935 - h2o_bl;
h2o_dens = (h2o_rf - intc) / slope;

%% D2O-PBS+RPMI
d2o_pth = "A:\thomasu\raw_data\2024-02-20\l1210_rpmi_d2o_pbs\20240220.144331_mass_results\2024-02-20_l1210_rpmi_d2o_pbs.csv";
d2o_tab = readtable(d2o_pth);
d2o_bm = mean(d2o_tab.mass_pg(d2o_tab.mass_pg > 20 & d2o_tab.mass_pg < 80));
d2o_bl = mean(d2o_tab.avg_baseline);
d2o_rf = 1150355 - d2o_bl;
% d2o_dens = (d2o_rf - intc) / slope;
d2o_dens = 1.05;

%% Optiprep+RPMI
op_pth = "A:\thomasu\raw_data\2024-02-20\l1210_rpmi_optiprep\20240220.144506_mass_results\2024-02-20_l1210_rpmi_optiprep.csv";
op_tab = readtable(op_pth);
op_bm = -mean(op_tab.mass_pg(op_tab.mass_pg > 28 & op_tab.mass_pg < 120));
op_bl = mean(op_tab.avg_baseline);
op_rf = 1132855 + op_bl;
% op_dens = (op_rf - intc) / slope;
op_dens = 1.155;

%% Density and vol calcs
dry_density_gcm3 = (d2o_dens .* h2o_bm + h2o_dens .* -d2o_bm) ./ (h2o_bm - d2o_bm);
dry_volume_fl = (h2o_bm - d2o_bm) ./ (d2o_dens - h2o_dens); 
total_volume_fl = (h2o_bm - op_bm) ./ (op_dens - h2o_dens); 
fprintf("Dry density (g/cm3): %.3f\n", dry_density_gcm3)
fprintf("Dry volume (fl): %.3f\n", dry_volume_fl)
fprintf("Total volume (fl): %.3f\n", total_volume_fl)
fprintf("Water content (v/v): %.3f\n", (total_volume_fl - dry_volume_fl) / total_volume_fl)

fprintf('H2O baseline density (g/cm3): %.3f\n', h2o_dens)
fprintf('D2O baseline density (g/cm3): %.3f\n', d2o_dens)
fprintf('Optiprep baseline density (g/cm3): %.3f\n', op_dens)

fprintf('H2O avg bm (pg): %.3f\n', h2o_bm)
fprintf('D2O avg bm (pg): %.3f\n', d2o_bm)
fprintf('Optiprep avg bm (pg): %.3f\n', op_bm)
disp('---------------------------------------------')

%% Calibration Solutions
d2o_100_rf = 1141380; d2o_100_gt_dens = 1.1;
fprintf('100%% D2O calculated density (g/cm3): %.3f\n', (d2o_100_rf - intc) / slope)
d2o_50_rf = 1150648; d2o_50_gt_dens = 1.05;
fprintf('50%% D2O calculated density (g/cm3): %.3f\n', (d2o_50_rf - intc) / slope)
op_50_rf = 1133026; op_50_gt_dens = 1.16;
fprintf('50%% optiprep calculated density (g/cm3): %.3f\n', (op_50_rf - intc) / slope)
op_25_rf = 1146480; op_25_gt_dens = 1.08;
fprintf('25%% optiprep calculated density (g/cm3): %.3f\n', (op_25_rf - intc) / slope)
h2o_cal_rf = 1160143; h2o_cal_gt_dens = 0.997;
fprintf('diH2O calculated density (g/cm3): %.3f\n', (h2o_cal_rf - intc) / slope)
disp('---------------------------------------------')


%% Calibration correction?
dens_vals = [d2o_100_gt_dens, d2o_50_gt_dens, op_50_gt_dens, op_25_gt_dens, h2o_cal_gt_dens];
rf_vals = [d2o_100_rf, d2o_50_rf, op_50_rf, op_25_rf, h2o_cal_rf];
figure; scatter(dens_vals, rf_vals/1e6, HandleVisibility='off'); hold on;
p = polyfit(dens_vals, rf_vals, 1);
plot(dens_vals, polyval(p, dens_vals)/1e6, 'red', LineWidth=2, DisplayName='Original calibration')
plot(dens_vals, polyval([slope, intc], dens_vals)/1e6, 'blue', LineWidth=2, DisplayName='Calibration from optiprep/d2o')
xlabel('Fluid density (g/cm3)'); ylabel('Reference frequency (MHz)')
legend('Location', 'northoutside')

fprintf('Original slope: %.5e\n', slope)
fprintf('Original intc: %.5e\n', intc)

fprintf('New cal slope: %.5e\n', p(1))
fprintf('New cal intc: %.5e\n', p(2))