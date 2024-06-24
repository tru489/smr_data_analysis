close all;
addpath(genpath("..\..\helpers"));

aa_pbs_tab = readtable("C:\thomasu\smr_data_analysis\analysis\2024-03-25_RBC_fixed_unfixed\20240322 RBC fSMR data.xlsx", "Sheet","AA_PBS");
ss_pbs_tab = readtable("C:\thomasu\smr_data_analysis\analysis\2024-03-25_RBC_fixed_unfixed\20240322 RBC fSMR data.xlsx", "Sheet","SS_PBS");


fh_mass = figure;
add_swarmchart(fh_mass, 'HbAA', aa_pbs_tab.mass)
add_swarmchart(fh_mass, 'HbSS', ss_pbs_tab.mass)
ylabel('Buoyant Mass (pg)', FontSize=24); ax=gca; ax.FontSize=18;
saveas(fh_mass, 'fig\fl_excl_mass.jpg')

fh_volume = figure;
add_swarmchart(fh_volume, 'HbAA', aa_pbs_tab.volume)
add_swarmchart(fh_volume, 'HbSS', ss_pbs_tab.volume)
ylabel('Voume (fL)', FontSize=24); ax=gca; ax.FontSize=18;
hold on; 
plot([0.5, 1.5], [85 85], Color='k', LineWidth=2)
plot([1.5, 2.5], [82.2 82.2], Color='k', LineWidth=2)
saveas(fh_volume, 'fig\fl_excl_volume.jpg')