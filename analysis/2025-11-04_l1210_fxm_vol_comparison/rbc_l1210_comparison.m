close all; clear;
addpath(genpath("..\..\helpers"));

l1210_path = "A:\thomasu\raw_data\2025-10-22\400fps_opt_focus\400fps_opt_focus 20251022.1348_CELLGROUPED CellInfo.csv";
rbc_path = "A:\thomasu\raw_data\2025-11-18\teemu_rbc_rep2\teemu_rbc_rep2 20251118.1616_CELLGROUPED CellInfo.csv";

l1210_tab = readtable(l1210_path);
rbc_tab = readtable(rbc_path);

fh = figure;
add_swarmchart(fh, 'L1210', l1210_tab.UncalibratedVolume(~isnan(l1210_tab.UncalibratedVolume) & l1210_tab.UncalibratedVolume > 0 & l1210_tab.UncalibratedVolume < 500))
ylabel('Volume (au)', FontSize=14)
ax=gca; ax.FontSize=13;
exportgraphics(fh, 'fig\l1210_sample_fig.pdf', ContentType='vector')

fh = figure;
add_swarmchart(fh, 'RBC', rbc_tab.UncalibratedVolume(~isnan(rbc_tab.UncalibratedVolume) & rbc_tab.UncalibratedVolume > 15 & rbc_tab.UncalibratedVolume < 35))
ylabel('Volume (au)', FontSize=14)
ax=gca; ax.FontSize=13;
exportgraphics(fh, 'fig\rbc_sample_fig.pdf', ContentType='vector')