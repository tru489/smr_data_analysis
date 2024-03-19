close all;

ss1_pbs_man_tab = readtable("A:\thomasu\raw_data\2024-02-21\ss1_rpmi_mannitol_h2oPBS\20240225.165225_mass_results\2024-02-21_ss1_rpmi_mannitol_h2oPBS.csv");
figure; histogram(ss1_pbs_man_tab.mass_pg, 150); title('ss1 pbs mannitol')

ss1_pbs_sms_tab = readtable("A:\thomasu\raw_data\2024-02-21\ss1_rpmi_sms_h2oPBS\20240225.165446_mass_results\2024-02-21_ss1_rpmi_sms_h2oPBS.csv");
figure; histogram(ss1_pbs_sms_tab.mass_pg, 150); title('ss1 pbs sms')

ss1_d2o_man_tab = readtable("A:\thomasu\raw_data\2024-02-21\ss1_rpmi_mannitol_d2oPBS\20240225.164746_mass_results\2024-02-21_ss1_rpmi_mannitol_d2oPBS.csv");
figure; histogram(ss1_d2o_man_tab.mass_pg, 150); title('ss1 d2o mannitol')

ss1_d2o_sms_tab = readtable("A:\thomasu\raw_data\2024-02-21\ss1_rpmi_sms_d2oPBS\20240225.165406_mass_results\2024-02-21_ss1_rpmi_sms_d2oPBS.csv");
figure; histogram(ss1_d2o_sms_tab.mass_pg, 150); title('ss1 d2o sms')

ss1_opt_sms_tab = readtable("A:\thomasu\raw_data\2024-02-21\ss1_rpmi_sms_optiprep_15pct_op_conc\20240225.165536_mass_results\2024-02-21_ss1_rpmi_sms_optiprep_15pct_op_conc.csv");
figure; histogram(ss1_opt_sms_tab.mass_pg, 150); title('ss1 optiprep sms')



% aa1_pbs_man_tab = readtable("A:\thomasu\raw_data\2024-02-21\aa1_rpmi_mannitol_h2oPBS\20240225.161227_mass_results\2024-02-21_aa1_rpmi_mannitol_h2oPBS.csv");
% figure; histogram(aa1_pbs_man_tab.mass_pg, 150); title('aa1 pbs mannitol')
% 
% ss1_pbs_sms_tab = readtable("A:\thomasu\raw_data\2024-02-21\ss1_rpmi_sms_h2oPBS\20240225.165446_mass_results\2024-02-21_ss1_rpmi_sms_h2oPBS.csv");
% figure; histogram(ss1_pbs_sms_tab.mass_pg, 150); title('ss1 pbs sms')
% 
% ss1_d2o_man_tab = readtable("A:\thomasu\raw_data\2024-02-21\ss1_rpmi_mannitol_d2oPBS\20240225.164746_mass_results\2024-02-21_ss1_rpmi_mannitol_d2oPBS.csv");
% figure; histogram(ss1_d2o_man_tab.mass_pg, 150); title('ss1 d2o mannitol')
% 
% ss1_d2o_sms_tab = readtable("A:\thomasu\raw_data\2024-02-21\ss1_rpmi_sms_d2oPBS\20240225.165406_mass_results\2024-02-21_ss1_rpmi_sms_d2oPBS.csv");
% figure; histogram(ss1_d2o_sms_tab.mass_pg, 150); title('ss1 d2o sms')
% 
% ss1_opt_sms_tab = readtable("A:\thomasu\raw_data\2024-02-21\ss1_rpmi_sms_optiprep_15pct_op_conc\20240225.165536_mass_results\2024-02-21_ss1_rpmi_sms_optiprep_15pct_op_conc.csv");
% figure; histogram(ss1_opt_sms_tab.mass_pg, 150); title('ss1 optiprep sms')

