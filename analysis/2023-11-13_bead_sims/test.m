close all;
addpath(genpath("C:\thomasu\smr_data_analysis"))

fpaths = ls("C:\thomasu\smr_data_analysis\analysis\2023-11-13_bead_sims\data\10um\emp");


for i = 1:length(fpaths)
    fp = fpaths{i};
    tab = readtable(fp);
    figure; scatter(1:length(tab.mass_pg), tab.mass_pg)
end