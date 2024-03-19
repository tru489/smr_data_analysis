close all;
addpath(genpath('..\..\final_code'))

h2o_pth = "A:\thomasu\raw_data\2024-02-22\5-12um_bead_pop_50pct-h2oPBS-50pct-dih2o\20240225.165633_mass_results\2024-02-22_5-12um_bead_pop_50pct-h2oPBS-50pct-dih2o.csv";
d2o_pth = "A:\thomasu\raw_data\2024-02-22\5-12um_bead_pop_100pct_d2o_pbs\20240225.165851_mass_results\2024-02-22_5-12um_bead_pop_100pct_d2o_pbs.csv";
opti_pth = "A:\thomasu\raw_data\2024-02-22\5-12um_bead_pop_50pct-optiprep-50pct-h2oPBS\20240225.165753_mass_results\2024-02-22_5-12um_bead_pop_50pct-optiprep-50pct-h2oPBS.csv";

old_cal = get_json_struct('cal', "A:\thomasu\raw_data\2024-02-24\old_dens_bl_calibration\20240225.141934_base_freq_density_calibration_results\20240224_density_baseline_calibration.json");
new_cal = get_json_struct('cal', "A:\thomasu\raw_data\2024-02-24\new_dens_bl_calibration\20240225.141906_base_freq_density_calibration_results\20240224_density_baseline_calibration.json");

h2o_tab = readtable(h2o_pth); 
h2o_bm = h2o_tab.mass_pg; h2o_rf = 1159515 - mean(h2o_tab.avg_baseline);
gt_dens_h2o = (0.997 + 1.0056) / 2;

d2o_tab = readtable(d2o_pth); 
d2o_bm = -d2o_tab.mass_pg; d2o_rf = 1143155 - mean(d2o_tab.avg_baseline);
gt_dens_d2o = (1.0675 * 0.1 + 1.1 * 0.9);

opti_tab = readtable(opti_pth); 
opti_bm = -opti_tab.mass_pg; opti_rf = 1133305 + mean(opti_tab.avg_baseline);
gt_dens_opti = 1.32 * 0.5 + 1.0056 * 0.5;

fprintf('--- OLD CALIBRATION ---\n')
fprintf('    Calculated 50-50 dih2o-h2oPBS measurement density vs GT: %.3f / %.3f\n', (h2o_rf - old_cal.intercept) / old_cal.slope, gt_dens_h2o)
fprintf('    Calculated 100%% D2O measurement density vs GT: %.3f / %.3f\n', (d2o_rf - old_cal.intercept) / old_cal.slope, gt_dens_d2o)
fprintf('    Calculated 50-50 optiprep-h2oPBS measurement density vs GT: %.3f / %.3f\n', (opti_rf - old_cal.intercept) / old_cal.slope, gt_dens_opti)
fprintf('--- NEW CALIBRATION ---\n')
fprintf('    Calculated 50-50 dih2o-h2oPBS measurement density vs GT: %.3f / %.3f\n', (h2o_rf - new_cal.intercept) / new_cal.slope, gt_dens_h2o)
fprintf('    Calculated 100%% D2O measurement density vs GT: %.3f / %.3f\n', (d2o_rf -new_cal.intercept) / new_cal.slope, gt_dens_d2o)
fprintf('    Calculated 50-50 optiprep-h2oPBS measurement density vs GT: %.3f / %.3f\n\n', (opti_rf - new_cal.intercept) / new_cal.slope, gt_dens_opti)

figure; hold on;
scatter([gt_dens_h2o, gt_dens_d2o, gt_dens_opti], [h2o_rf, d2o_rf, opti_rf], DisplayName='Ground truth density vs emp freqs')
xv = 0.997:0.005:1.16;
plot(xv, old_cal.slope * xv + old_cal.intercept, DisplayName='Old calibration')
plot(xv, new_cal.slope * xv + new_cal.intercept, DisplayName='New calibration')
p = polyfit([gt_dens_h2o, gt_dens_d2o, gt_dens_opti], [h2o_rf, d2o_rf, opti_rf], 1);
plot([gt_dens_h2o, gt_dens_d2o, gt_dens_opti], polyval(p, [gt_dens_h2o, gt_dens_d2o, gt_dens_opti]), DisplayName='Empirical fit')

p2 = [-1.71306e+05, 1.33099e+06];
% p2 = [-1.73443e+05, 1.33317e+06];
plot([gt_dens_h2o, gt_dens_d2o, gt_dens_opti], polyval(p2, [gt_dens_h2o, gt_dens_d2o, gt_dens_opti]), DisplayName='Corrected fit')
legend('Location', 'northoutside')

fprintf('Results from empirical fitting: slope = %.3e, intc = %.3e\n', p(1), p(2))
fprintf('                Old fit params: slope = %.3e, intc = %.3e\n', old_cal.slope, old_cal.intercept)
fprintf('                New fit params: slope = %.3e, intc = %.3e\n', new_cal.slope, new_cal.intercept)

h2o_slices = {...
    h2o_bm > 2.5 & h2o_bm < 4.5, ...
    h2o_bm > 5 & h2o_bm < 6.5, ...
    h2o_bm > 8 & h2o_bm < 9.5, ...
    h2o_bm > 12 & h2o_bm < 13.7, ...
    h2o_bm > 17 & h2o_bm < 19.1, ...
    h2o_bm > 24 & h2o_bm < 27, ...
    h2o_bm > 41 & h2o_bm < 48, ...
    };

d2o_slices = {...
    d2o_bm < -2.4 & d2o_bm > -3.6, ...
    d2o_bm < -4.8 & d2o_bm > -6.2, ...
    d2o_bm < -7.5 & d2o_bm > -9, ...
    d2o_bm < -11.6 & d2o_bm > -12.8, ...
    d2o_bm < -16.5 & d2o_bm > -18.5, ...
    d2o_bm < -23.5 & d2o_bm > -26, ...
    d2o_bm < -40 & d2o_bm > -44.5, ...
    };

opti_slices = {...
    opti_bm < -5 & opti_bm > -8, ...
    opti_bm < -11 & opti_bm > -14, ...
    opti_bm < -17.5 & opti_bm > -20, ...
    opti_bm < -26 & opti_bm > -30, ...
    opti_bm < -38.5 & opti_bm > -42, ...
    opti_bm < -53 & opti_bm > -59, ...
    opti_bm < -93 & opti_bm > -100.5, ...
    };

h2o_dens = get_dens(p2, h2o_rf);
d2o_dens = get_dens(p2, d2o_rf);
opti_dens = get_dens(p2, opti_rf);



p_dens = 1.05;
diams = [5.0000    6.0070    6.9760    7.9790    8.9560   10.1200   12.0100];
gt_vols = 4/3 * pi * (diams / 2).^3;
gt_bm_h2o = gt_vols * (p_dens - h2o_dens);
gt_bm_d2o = gt_vols * (p_dens - d2o_dens);
gt_bm_opti = gt_vols * (p_dens - opti_dens);

f1 = figure; histogram(h2o_bm, 200, DisplayName='Experimental buoyant mass'); title('Buoyant mass in H_2O'); xlim([0 50])
xline(gt_bm_h2o(1), LineWidth=2, Color='red', DisplayName='Expected buoyant mass')
xline(gt_bm_h2o(2:end), LineWidth=2, Color='red', HandleVisibility='off')
xlabel('Buoyant mass (pg)'); ylabel('Count');
% legend(Location='southoutside')
saveas(f1, 'fig\bead_mix_h2o_rep2.jpg')

f2 = figure; histogram(d2o_bm, 200); title('Buoyant mass in D_2O'); xlim([-50 0])
xline(gt_bm_d2o, LineWidth=2, Color='red')
xlabel('Buoyant mass (pg)'); ylabel('Count');
saveas(f2, 'fig\bead_mix_d2o_rep2.jpg')

f3 = figure; histogram(opti_bm, 200); title('Buoyant mass in Optiprep'); xlim([-110 0])
xline(gt_bm_opti, LineWidth=2, Color='red')
xlabel('Buoyant mass (pg)'); ylabel('Count');
saveas(f3, 'fig\bead_mix_opt_rep2.jpg')


fprintf('\n\n\n\n--- RESCALED CALIBRATION ---\n')
fprintf('    Calculated 50-50 dih2o-h2oPBS measurement density vs GT: %.3f / %.3f\n', h2o_dens, gt_dens_h2o)
fprintf('    Calculated 100%% D2O measurement density vs GT: %.3f / %.3f\n', d2o_dens, gt_dens_d2o)
fprintf('    Calculated 50-50 optiprep-h2oPBS measurement density vs GT: %.3f / %.3f\n', opti_dens, gt_dens_opti)


bead_siz_lab = ["5um beads", "6um beads", "7um beads", "8um beads", "9um beads", "10um beads", "12um beads"];
colors = ["r", "g", "b", "c", "m", "k", "#7E2F8E"];
f_scatter = figure; hold on;
for i = 1:length(h2o_slices)
    h2o_mean_bm = mean(h2o_bm(h2o_slices{i}));
    d2o_mean_bm = mean(d2o_bm(d2o_slices{i}));
    opti_mean_bm = mean(opti_bm(opti_slices{i}));
    
    density_d2o = (d2o_dens * h2o_mean_bm - h2o_dens * d2o_mean_bm) ./ (h2o_mean_bm - d2o_mean_bm);
    vol_d2o = (h2o_mean_bm - d2o_mean_bm) / (d2o_dens - h2o_dens);
    if i == 1
        s1 = scatter(density_d2o, vol_d2o, 70, '+', 'blue', LineWidth=3, DisplayName='Density/Volume calculated from H2O/D2O measurements'); 
        s1.MarkerFaceAlpha = 0.3;
    else
        s1 = scatter(density_d2o, vol_d2o, 70, '+', 'blue', LineWidth=3, HandleVisibility='off'); 
        s1.MarkerFaceAlpha = 0.3;
    end

    density_opti = (opti_dens * h2o_mean_bm - h2o_dens * opti_mean_bm) ./ (h2o_mean_bm - opti_mean_bm);
    vol_opti = (h2o_mean_bm - opti_mean_bm) / (opti_dens - h2o_dens);
    
    if i == 1
        s1 = scatter(density_opti, vol_opti, 70, '+', 'magenta', LineWidth=3, DisplayName='Density/Volume calculated from H2O/D2O measurements'); 
        s1.MarkerFaceAlpha = 0.3;
    else
        s1 = scatter(density_opti, vol_opti, 70, '+', 'magenta', LineWidth=3, HandleVisibility='off'); 
        s1.MarkerFaceAlpha = 0.3;
    end

    gt_volume = 4/3 * pi * (diams(i) / 2) .^ 3;
    
    if i == 1
        s2 = scatter(1.05, gt_volume, 70, '+', 'red', LineWidth=3, DisplayName='Ground truth'); 
        s2.MarkerFaceAlpha = 0.6;
    else
        s2 = scatter(1.05, gt_volume, 70, '+', 'red', LineWidth=3, HandleVisibility='off'); 
        s2.MarkerFaceAlpha = 0.6;
    end
    
    
    xlabel('Density (g/cm3)'); ylabel('Volume (fl)');
end
% title('blue = d2o, magenta = optiprep, red = GT')
% legend(Location='southoutside')
saveas(f_scatter, 'fig\bead_mix_scatter_rep2.jpg')

function dens = get_dens(p, q_val)
    dens = (q_val - p(2)) / p(1);
end
