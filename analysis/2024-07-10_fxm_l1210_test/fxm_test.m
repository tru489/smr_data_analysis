close all;
addpath(genpath("..\..\helpers"));

fxm_data_tab = readtable("A:\thomasu\raw_data\2024-07-09\l1210_fl_excl\20240710.102350_fl_excl_results\2024-07-09_l1210_fl_excl.csv");

bm = fxm_data_tab.mass_pg;
vol = fxm_data_tab.total_volume_fl;
dens = fxm_data_tab.total_density_gcm3;

f1 = figure; histogram(bm, 150); xlabel('Buoyant Mass (pg)'); ylabel('Count'); saveas(f1, 'fig\bm_hist.jpg')
f2 = figure; histogram(vol, 150); xlabel('Volume (fL)'); ylabel('Count'); saveas(f2, 'fig\vol_hist.jpg')
f3 = figure; histogram(dens, 150); xlabel('Density (g/cm3)'); ylabel('Count'); saveas(f3, 'fig\dens_hist.jpg')

fprintf('fSMR volume stats\n  Vol mean: %f\n  Vol STD: %f\n', ...
    mean(vol(vol>600 & vol<1900)), std(vol(vol>600 & vol<1900)))