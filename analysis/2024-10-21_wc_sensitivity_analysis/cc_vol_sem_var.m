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

cf = 0.8; %pg/Hz

%% Run simulations for each parameter variation
figpath_arr = []; title_arr = [];

%  ------------------------ Vary nV (sampling error of V) ------------------------
tot_vol_n = 1e2; % tot volume n
vol_lsp = normrnd(tot_vol, tot_vol_std / sqrt(tot_vol_n), [1,n_dp]);
[~, ~, wc_out_1] = oat_analyze_iter(rho_f1, rho_f2, bm1, bm2, vol_lsp, cf);

tot_vol_n = 5e2; % tot volume n
vol_lsp = normrnd(tot_vol, tot_vol_std / sqrt(tot_vol_n), [1,n_dp]);
[~, ~, wc_out_2] = oat_analyze_iter(rho_f1, rho_f2, bm1, bm2, vol_lsp, cf);

tot_vol_n = 1e3; % tot volume n
vol_lsp = normrnd(tot_vol, tot_vol_std / sqrt(tot_vol_n), [1,n_dp]);
[~, ~, wc_out_3] = oat_analyze_iter(rho_f1, rho_f2, bm1, bm2, vol_lsp, cf);

tot_vol_n = 5e3; % tot volume n
vol_lsp = normrnd(tot_vol, tot_vol_std / sqrt(tot_vol_n), [1,n_dp]);
[~, ~, wc_out_4] = oat_analyze_iter(rho_f1, rho_f2, bm1, bm2, vol_lsp, cf);

tot_vol_n = 1e4; % tot volume n
vol_lsp = normrnd(tot_vol, tot_vol_std / sqrt(tot_vol_n), [1,n_dp]);
[~, ~, wc_out_5] = oat_analyze_iter(rho_f1, rho_f2, bm1, bm2, vol_lsp, cf);



%% Create fig
fh = figure(Position=[2093         194        1018         725]); 
add_swarmchart(fh, 'N=100', wc_out_1);
add_swarmchart(fh, 'N=500', wc_out_2);
add_swarmchart(fh, 'N=1,000', wc_out_3);
add_swarmchart(fh, 'N=5,000', wc_out_4);
add_swarmchart(fh, 'N=10,000', wc_out_5);

ylabel('Water Content (v/v)', FontSize=13, Interpreter='tex')
ax=gca; ax.FontSize=14;

saveas(fh, 'fig\fig2.jpg');
