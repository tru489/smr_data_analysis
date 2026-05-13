close all;
addpath(genpath("..\..\helpers"));

%% FXM volumes
fromleft = "A:\thomasu\raw_data\2025-11-04\thomas_data\l1210_control_imfsmr_fromleft_rep1\l1210_control_imfsmr_fromleft_rep1 20251104.1014_CELLGROUPED CellInfo.csv";
tab = readtable(fromleft);
fh_left=figure;
histogram(tab.CalibratedWeightedVolume(~isnan(tab.CalibratedWeightedVolume) & tab.CalibratedWeightedVolume > 20), 100)
xlabel('Volume (fL)', FontSize=14)
ylabel('Count', FontSize=14)
title('Flow from left side', FontSize=14)
saveas(fh_left, 'fig\fromleft.jpg')

fromright = "A:\thomasu\raw_data\2025-11-04\thomas_data\l1210_control_imfsmr_fromright_rep1\l1210_control_imfsmr_fromright_rep1 20251104.1043_CELLGROUPED CellInfo.csv";
tab = readtable(fromright);
fh_right=figure;
histogram(tab.CalibratedWeightedVolume(~isnan(tab.CalibratedWeightedVolume) & tab.CalibratedWeightedVolume > 20), 100)
xlabel('Volume (fL)', FontSize=14)
ylabel('Count', FontSize=14)
title('Flow from right side', FontSize=14)
saveas(fh_right, 'fig\fromright.jpg')

%% Optiprep volumes
h2o_paths = [...
    "A:\thomasu\raw_data\2025-11-04\thomas_data\l1210_control_imfsmr_fromleft_rep1\20251126.102630_mass_results\thomas_data_l1210_control_imfsmr_fromleft_rep1.csv",...
    "A:\thomasu\raw_data\2025-11-04\thomas_data\l1210_control_imfsmr_fromleft_rep2\20251126.102717_mass_results\thomas_data_l1210_control_imfsmr_fromleft_rep2.csv",...
    "A:\thomasu\raw_data\2025-11-04\thomas_data\l1210_control_imfsmr_fromright_rep1\20251126.102753_mass_results\thomas_data_l1210_control_imfsmr_fromright_rep1.csv",...
    "A:\thomasu\raw_data\2025-11-04\thomas_data\l1210_control_imfsmr_fromright_rep2\20251126.102830_mass_results\thomas_data_l1210_control_imfsmr_fromright_rep2.csv"];

for i = 1:length(h2o_paths)
    fh=figure;
    tab = readtable(h2o_paths(i));
    histogram(tab.mass_pg,150)
end

slope = -188921.29865172753;
intc = 1.2525573509867985E+6;

h2o_path = "A:\thomasu\raw_data\2025-11-04\thomas_data\l1210_control_imfsmr_fromright_rep1\20251126.102753_mass_results\thomas_data_l1210_control_imfsmr_fromright_rep1.csv";
h2o_tab = readtable(h2o_path);
h2o_slice_idx = [20 90];
h2o_mean = mean(h2o_tab.mass_pg);
h2o_freq = 1062005 - mean(h2o_tab.avg_baseline);
h2o_dens = (h2o_freq - intc) / slope;

opti_path = "A:\thomasu\raw_data\2025-11-04\thomas_data\l1210_control_optiprep_rep1\20251111.112644_mass_results\thomas_data_l1210_control_optiprep_rep1.csv";
opti_tab = readtable(opti_path);
opti_slice_idx = [20 90];
opti_mean = mean(opti_tab.mass_pg);
opti_freq = 1040005 + mean(opti_tab.avg_baseline);
opti_dens = (opti_freq - intc) / slope;

volume = -(h2o_mean + opti_mean) / (h2o_dens - opti_dens)




