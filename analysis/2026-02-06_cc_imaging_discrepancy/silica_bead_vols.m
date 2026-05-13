close all;
addpath(genpath("..\..\helpers"));

na_fluor_tab = readtable("A:\thomasu\raw_data\2026-03-02_silica_bead\0.2mgmL_NaFluorescein\0 20260302.1632_CELLGROUPED CellInfo.csv");
fitc_dex_tab = readtable("A:\thomasu\raw_data\2026-03-02_silica_bead\10mgmL_fitc_dextran\10mgmL_fitc_dextran 20260302.1606_CELLGROUPED CellInfo.csv");

na_fluor_vol = na_fluor_tab.Volume(~isnan(na_fluor_tab.Volume));
fitc_dex_vol = fitc_dex_tab.Volume(~isnan(fitc_dex_tab.Volume));

coulter_tab = readtable("A:\thomasu\raw_data\2026-02-27_silica_beads\2026-02-27_silica_beads_sc_volumes.csv",...
    VariableNamingRule="preserve");
coulter_vols = coulter_tab.('6um_silica_beads');
coulter_vols = coulter_vols(coulter_vols < 800);

bead_vol = 4/3 * pi * (6.1/2)^3;

fh = figure(Position=[2209         160        1073         736]);
add_swarmchart(fh, 'Coulter Counter', coulter_vols)
add_swarmchart(fh, 'NaFluorescein, 0.2 mg/mL', na_fluor_vol*1.2)
add_swarmchart(fh, 'FITC-Dextran, 10 mg/mL', fitc_dex_vol*1.2)
yline(bead_vol,LineWidth=2)
ax=gca; ax.FontSize=13;
ylabel('Volume (fL)', FontSize=14)
title('6.10\mum silica beads', FontSize=14)
saveas(fh, '0302_silica_bead_fig\swarms.jpg')

coulter_slice = coulter_vols(coulter_vols<300 & coulter_vols>50);
fitc_dex_vol = fitc_dex_vol*1.2;
fitc_dex_slice = fitc_dex_vol(fitc_dex_vol>20&fitc_dex_vol<200);
fprintf('Coulter to fitc-dextran ratio: %.4f\n', mean(coulter_slice) / mean(fitc_dex_slice))