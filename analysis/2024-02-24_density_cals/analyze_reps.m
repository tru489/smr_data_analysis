close all;
addpath(genpath('..\..\final_code'))

st = load("data\data_preload.mat");
data_dict = st.data_dict;

ss1_man_pbs_orig = data_dict("ss1_mannitol_pbs");
ss1_man_pbs_orig = ss1_man_pbs_orig.mass_pg;

ss2_man_pbs_orig = data_dict("ss2_mannitol_pbs");
ss2_man_pbs_orig = ss2_man_pbs_orig.mass_pg;

ss3_man_pbs_orig = data_dict("ss3_mannitol_pbs");
ss3_man_pbs_orig = ss3_man_pbs_orig.mass_pg;

% ------------------------
pths = ...
    ["A:\thomasu\raw_data\2024-02-21\ss1_rpmi_mannitol_h2oPBS_rep\20240225.165323_mass_results\2024-02-21_ss1_rpmi_mannitol_h2oPBS_rep.csv",...
    "A:\thomasu\raw_data\2024-02-22\ss2_mannitol_pbs_rep\20240225.170556_mass_results\2024-02-22_ss2_mannitol_pbs_rep.csv",...
    "A:\thomasu\raw_data\2024-02-23\ss3_mannitol_pbs_rep\20240226.100155_mass_results\2024-02-23_ss3_mannitol_pbs_rep.csv"];

ss1_man_pbs_rep = extract_and_slice(pths(1));
ss2_man_pbs_rep = extract_and_slice(pths(2));
ss3_man_pbs_rep = extract_and_slice(pths(3));

fh = figure;
add_swarmchart(fh, 'ss1 mannitol', ss1_man_pbs_orig)
add_swarmchart(fh, 'ss1 mannitol replicate', ss1_man_pbs_rep)
add_swarmchart(fh, 'ss2 mannitol', ss2_man_pbs_orig)
add_swarmchart(fh, 'ss2 mannitol replicate', ss2_man_pbs_rep)
add_swarmchart(fh, 'ss3 mannitol', ss3_man_pbs_orig)
add_swarmchart(fh, 'ss3 mannitol replicate', ss3_man_pbs_rep)
ylabel('Buoyant mass (pg)')
xline([2.5, 4.5], LineWidth=1.5)
saveas(fh, "fig\bm_swarms_reps.jpg")


function ret = extract_and_slice(pth)
    temp = readtable(pth);
    bm = temp.mass_pg;
    temp = temp(bm < 14 & bm > 3, :);
    ret = temp.mass_pg;
end


