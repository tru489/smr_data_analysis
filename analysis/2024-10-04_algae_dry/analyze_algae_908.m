close all;
addpath(genpath("..\..\helpers"));

pth = "C:\thomasu\smr_data_analysis\analysis\2024-10-04_algae_dry\data\2024-10-04_908_low_h2o_rep1.csv";
tab = readtable(pth);
figure; histogram(tab.mass_pg, 150)
tab = tab(tab.mass_pg > 20, :);
writetable(tab, 'results\2024-10-04_908_low_h2o_rep1.csv')


pth = "C:\thomasu\smr_data_analysis\analysis\2024-10-04_algae_dry\data\2024-10-04_908_low_h2o_rep2.csv";
tab = readtable(pth);
figure; histogram(tab.mass_pg, 150)
tab = tab(tab.mass_pg > 20, :);
writetable(tab, 'results\2024-10-04_908_low_h2o_rep2.csv')