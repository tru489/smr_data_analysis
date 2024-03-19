close all;

save_path = "C:\thomasu\smr_data_analysis\analysis\2024-02-12_5-12um_bead_pops\fig";
h2o_path = "A:\thomasu\raw_data\2024-02-07\5-12um_beads_h2o_pbs\20240208.085026_mass_results\2024-02-07_5-12um_beads_h2o_pbs.csv";
d2o_path = "A:\thomasu\raw_data\2024-02-07\5-12um_beads_d2o_pbs\20240208.110002_mass_results\2024-02-07_5-12um_beads_d2o_pbs.csv";
slope = -148384.10411106463;
intercept = 1.3077455175537597E+6;

h2o_rf = 1158731;
d2o_rf = 1142351;

h2o_tab = readtable(h2o_path);
d2o_tab = readtable(d2o_path);

p_dens = 1.05;
diams = [5.0000    6.0070    6.9760    7.9790    8.9560   10.1200   12.0100];

p1_vol = 4/3 * pi * (diams / 2).^3;
p2_vol = 4/3 * pi * (diams / 2).^3;

bl_dens1 = (h2o_rf - intercept) / slope;
bl_dens2 = (d2o_rf - intercept) / slope;

bm1 = p1_vol .* (p_dens - bl_dens1');
bm2 = p2_vol .* (p_dens - bl_dens2'); %  / 0.90648331479612432 * 0.8050

h2o_slice = h2o_tab.mass_pg(h2o_tab.mass_pg < 52) / 0.90648331479612432 * 0.8050;
d2o_slice = -d2o_tab.mass_pg(-d2o_tab.mass_pg > -70) / 0.90648331479612432 * 0.8050;

fh_hist_h2o = figure; 
xline(bm1(1), LineWidth=1.5, DisplayName='Theoretical BMs'); 
xline(bm1(2:end), LineWidth=1.5, HandleVisibility='off'); 
hold on;
[N, edges] = histcounts(h2o_slice, 'BinWidth', 0.4);
histogram('BinEdges', edges, 'BinCounts', N / sum(N), 'FaceColor', 'red', 'FaceAlpha', 0.2, 'EdgeAlpha', 0.2, 'DisplayName', 'Population BMs')
title('H2O population buoyant masses'); xlabel('Buoyant mass (pg)'); ylabel('Probability density');
legend(Location='northoutside')

fh_hist_d2o = figure; 
xline(bm2(1), LineWidth=1.5, DisplayName='Theoretical BMs'); 
xline(bm2(2:end), LineWidth=1.5, HandleVisibility='off'); 
hold on;
[N, edges] = histcounts(d2o_slice, 'BinWidth', 0.4);
histogram('BinEdges', edges, 'BinCounts', N / sum(N), 'FaceColor', 'red', 'FaceAlpha', 0.2, 'EdgeAlpha', 0.2, 'DisplayName', 'Population BMs')
title('D2O population buoyant masses'); xlabel('Buoyant mass (pg)'); ylabel('Probability density');
legend(Location='northoutside')

%% Slicing for pop vol/density 
pop_slices_h2o = {...
    h2o_slice > 2 & h2o_slice < 5,...
    h2o_slice > 5 & h2o_slice < 7,...
    h2o_slice > 8.5 & h2o_slice < 10,...
    h2o_slice > 13 & h2o_slice < 15,...
    h2o_slice > 18 & h2o_slice < 21,...
    h2o_slice > 25 & h2o_slice < 29,...
    h2o_slice > 45 & h2o_slice < 51,...
    };
pop_slices_d2o = {...
    d2o_slice > -5 & d2o_slice < -3,...
    d2o_slice > -8.5 & d2o_slice < -6.5,...
    d2o_slice > -12 & d2o_slice < -10,...
    d2o_slice > -18 & d2o_slice < -14,...
    d2o_slice > -24 & d2o_slice < -21,...
    d2o_slice > -35 & d2o_slice < -29,...
    d2o_slice > -59 & d2o_slice < -50,...
    };

bead_siz_lab = ["5um beads", "6um beads", "7um beads", "8um beads", "9um beads", "10um beads", "12um beads"];
colors = ["r", "g", "b", "c", "m", "k", "#7E2F8E"];
f_scatter = figure;
for i = 1:length(pop_slices_h2o)
    h2o_mean_bm = mean(h2o_slice(pop_slices_h2o{i}));
    d2o_mean_bm = mean(d2o_slice(pop_slices_d2o{i}));
    
    density = (bl_dens2 * h2o_mean_bm - bl_dens1 * d2o_mean_bm) ./ (h2o_mean_bm - d2o_mean_bm);
    vol = (h2o_mean_bm - d2o_mean_bm) / (bl_dens2 - bl_dens1);
    s1 = scatter(density, vol, 70, '+', 'blue', LineWidth=3, HandleVisibility='off'); 
    s1.MarkerFaceAlpha = 0.3;
    hold on;
    gt_volume = 4/3 * pi * (diams(i) / 2) .^ 3;
    s2 = scatter(1.05, gt_volume, 70, '+', 'red', LineWidth=3, HandleVisibility='off'); 
    yline(gt_volume, ':r', LineWidth=2)
    s2.MarkerFaceAlpha = 0.6;
    xlabel('Dry density (g/cm3)'); ylabel('Dry volume (fl)');
end

multi_trap_path = "A:\thomasu\raw_data\2023-12-17\6_8_10_um_denstrap\20240129.111646_density_trap_results\peakset_summary_paired_clean.csv";
mt_tab = readtable(multi_trap_path);
s2 = scatter(mt_tab.density_gcm3, mt_tab.volume_fl, 35, '.', 'magenta', LineWidth=2, HandleVisibility='off'); 
s2.MarkerFaceAlpha = 0.4;

saveas(f_scatter, fullfile(save_path, "scatter.jpg"))
saveas(fh_hist_h2o, fullfile(save_path, "hist_h2o.jpg"))
saveas(fh_hist_d2o, fullfile(save_path, "hist_d2o.jpg"))