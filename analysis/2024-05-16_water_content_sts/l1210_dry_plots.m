close all;
addpath(genpath("..\..\helpers"));

t1 = readtable("A:\thomasu\raw_data\2024-04-24\l1210_trap_h2opbs_d2opbs\20240506.180113_density_trap_results\peakset_summary_paired.csv");
t1 = t1(t1.volume_fl > 0 & (t1.density_gcm3 > 0 & t1.density_gcm3 < 2), :);
fh = figure(Position=[2428         200         920         458]); 
subplot(1,2,1); histogram(t1.volume_fl, 55); ylabel('Dry volume (fL)')
subplot(1,2,2); histogram(t1.density_gcm3, 55); ylabel('Dry density (g/cm3)')
saveas(fh, 'fig\dry_l1210_rep1.jpg')

t2 = readtable("A:\thomasu\raw_data\2024-04-24\l1210_trap_h2opbs_d2opbs_oscill_baseline\20240506.180258_density_trap_results\peakset_summary_paired.csv");
t2 = t2(t2.volume_fl > 0 & (t2.density_gcm3 > 0 & t2.density_gcm3 < 2), :);
fh = figure(Position=[2428         200         920         458]); 
subplot(1,2,1); histogram(t2.volume_fl, 55); ylabel('Dry volume (fL)')
subplot(1,2,2); histogram(t2.density_gcm3, 55); ylabel('Dry density (g/cm3)')
saveas(fh, 'fig\dry_l1210_rep2.jpg')

