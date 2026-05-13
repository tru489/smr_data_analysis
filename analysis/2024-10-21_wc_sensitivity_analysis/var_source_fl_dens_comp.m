close all;

addpath(genpath("..\..\helpers"));
template_path = "C:\thomasu\smr_data_analysis\analysis\2024-10-21_wc_sensitivity_analysis\template.potx";

n_dp = 500;

%% OAT analysis
% ------------------ Assumed particle: l1210 ------------------
bm1 = 53; % h2o bm
bm1_std = 14; % h2o bm std
bm1_n = 1000; % bm1 n

rho_f1 = 1.006; % h2o fluid density


bm2 = 41; % d2o bm
bm2_std = 11.2; % h2o bm std
bm2_n = 1000; % bm2 n

rho_f2 = 1.098; % d2o fluid density


tot_vol = 1000; % total volume
tot_vol_std = 240; % total volume std
tot_vol_n = 4000; % tot volume n

cf = 0.8; %pg/Hz

%% Specify parameters for density variation based on calibration variation
intc_range = [1.332224, 1.332435, 1.33243, 1.332642, 1.333174, 1.33303, ...
    1.333583, 1.335275, 1.330698]*1e6;
slp_range = [-172602, -172775, -172689, -172903, -173443, -173301, -173828, ...
    -175577, -171161];
rf_assume_f1 = rho_f1 * slp_range(1) + intc_range(1);
rf_assume_f2 = rho_f2 * slp_range(1) + intc_range(1);

dens_vari_f1 = (rf_assume_f1 - intc_range) ./ slp_range;
dens_vari_f2 = (rf_assume_f2 - intc_range) ./ slp_range;

%% Run simulations for each parameter variation
figpath_arr = []; title_arr = [];

%  ------------------------ Vary rho_f1 (calibration error) ------------------------
rho_f1_lsp = dens_vari_f1;
[~, ~, wc_calf1] = oat_analyze_iter(rho_f1_lsp, rho_f2, bm1, bm2, tot_vol, cf);

%  ------------------------ Vary rho_f2 (calibration error) ------------------------
rho_f2_lsp = dens_vari_f2;
[~, ~, wc_calf2] = oat_analyze_iter(rho_f1, rho_f2_lsp, bm1, bm2, tot_vol, cf);

%  ------------------------ Vary rho_f1 (bl shifts) ------------------------
rho_f1_lsp = normrnd(rho_f1, 6e-4, [1,n_dp]);
[~, ~, wc_sftf1] = oat_analyze_iter(rho_f1_lsp, rho_f2, bm1, bm2, tot_vol, cf);

%  ------------------------ Vary rho_f2 (bl shifts)  ------------------------
rho_f2_lsp = normrnd(rho_f2, 6e-4, [1,n_dp]);
[~, ~, wc_sftf2] = oat_analyze_iter(rho_f1, rho_f2_lsp, bm1, bm2, tot_vol, cf);

%% Create powerpoint
fh = figure(Position=[2093         194        1018         725]); 
add_swarmchart(fh, 'H2O, calibration variation', wc_calf1);
add_swarmchart(fh, 'H2O, baseline shift', wc_sftf1);
add_swarmchart(fh, 'D2O, calibration variation', wc_calf2);
add_swarmchart(fh, 'D2O, baseline shift', wc_sftf2);
ylabel('Water Content (v/v)', FontSize=13, Interpreter='tex')
ax=gca; ax.FontSize=14;

saveas(fh, 'fig\fig1.jpg');
