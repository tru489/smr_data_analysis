close all;

addpath(genpath("..\..\helpers"));
template_path = "C:\thomasu\smr_data_analysis\analysis\2024-10-21_wc_sensitivity_analysis\template.potx";

n_dp = 500;

%% OAT analysis
% ------------------ Assumed particle: l1210 ------------------
bm1 = 53; % h2o bm
bm1_std = 14; % h2o bm std

rho_f1 = 1.006; % h2o fluid density


bm2 = 41; % d2o bm
bm2_std = 11.2; % h2o bm std

rho_f2 = 1.098; % d2o fluid density


tot_vol = 1000; % total volume
tot_vol_std = 240; % total volume std
tot_vol_n = 4000; % tot volume n

cf = 0.8; %pg/Hz

%% Run simulations for each parameter variation
m1_trapcv_wcs = zeros(5,n_dp);
m2_trapcv_wcs = zeros(5,n_dp);
m1_biocv_wcs = zeros(5,n_dp);
m2_biocv_wcs = zeros(5,n_dp);

n_pick = [1e2, 5e2, 1e3, 5e3, 1e4];

for i = 1:length(n_pick)
    bm1_lsp = normrnd(bm1, bm1_std / sqrt(n_pick(i)), [1,n_dp]);
    [~, ~, wc_out] = oat_analyze_iter(rho_f1, rho_f2, bm1_lsp, bm2, tot_vol, cf);
    m1_biocv_wcs(i,:) = wc_out;

    bm2_lsp = normrnd(bm2, bm2_std / sqrt(n_pick(i)), [1,n_dp]);
    [~, ~, wc_out] = oat_analyze_iter(rho_f1, rho_f2, bm1, bm2_lsp, tot_vol, cf);
    m2_biocv_wcs(i,:) = wc_out;

    bm1_lsp = normrnd(bm1, bm1*0.003 / sqrt(n_pick(i)), [1,n_dp]);
    [~, ~, wc_out] = oat_analyze_iter(rho_f1, rho_f2, bm1_lsp, bm2, tot_vol, cf);
    m1_trapcv_wcs(i,:) = wc_out;

    bm2_lsp = normrnd(bm2, bm2*0.003 / sqrt(n_pick(i)), [1,n_dp]);
    [~, ~, wc_out] = oat_analyze_iter(rho_f1, rho_f2, bm1, bm2_lsp, tot_vol, cf);
    m2_trapcv_wcs(i,:) = wc_out;
end


%% Create figs

fh_biocv_m1 = figure(Position=[2093         194        1018         725]); 
fh_biocv_m2 = figure(Position=[2093         194        1018         725]); 
fh_trapcv_m1 = figure(Position=[2093         194        1018         725]); 
fh_trapcv_m2 = figure(Position=[2093         194        1018         725]); 

add_swarmchart(fh_biocv_m1, 'N=100', m1_biocv_wcs(1,:));
add_swarmchart(fh_biocv_m1, 'N=500', m1_biocv_wcs(2,:));
add_swarmchart(fh_biocv_m1, 'N=1,000', m1_biocv_wcs(3,:));
add_swarmchart(fh_biocv_m1, 'N=5,000', m1_biocv_wcs(4,:));
add_swarmchart(fh_biocv_m1, 'N=10,000', m1_biocv_wcs(5,:));

ylabel('Water Content (v/v)', FontSize=13, Interpreter='tex')
ax=gca; ax.FontSize=14;

saveas(fh_biocv_m1, 'fig\fig3a_biocv_m1.jpg');

add_swarmchart(fh_biocv_m2, 'N=100', m2_biocv_wcs(1,:));
add_swarmchart(fh_biocv_m2, 'N=500', m2_biocv_wcs(2,:));
add_swarmchart(fh_biocv_m2, 'N=1,000', m2_biocv_wcs(3,:));
add_swarmchart(fh_biocv_m2, 'N=5,000', m2_biocv_wcs(4,:));
add_swarmchart(fh_biocv_m2, 'N=10,000', m2_biocv_wcs(5,:));

ylabel('Water Content (v/v)', FontSize=13, Interpreter='tex')
ax=gca; ax.FontSize=14;

saveas(fh_biocv_m2, 'fig\fig3b_biocv_m2.jpg');

add_swarmchart(fh_trapcv_m1, 'N=100', m1_trapcv_wcs(1,:));
add_swarmchart(fh_trapcv_m1, 'N=500', m1_trapcv_wcs(2,:));
add_swarmchart(fh_trapcv_m1, 'N=1,000', m1_trapcv_wcs(3,:));
add_swarmchart(fh_trapcv_m1, 'N=5,000', m1_trapcv_wcs(4,:));
add_swarmchart(fh_trapcv_m1, 'N=10,000', m1_trapcv_wcs(5,:));

ylabel('Water Content (v/v)', FontSize=13, Interpreter='tex')
ax=gca; ax.FontSize=14;

saveas(fh_trapcv_m1, 'fig\fig3c_trapcv_m1.jpg');

add_swarmchart(fh_trapcv_m2, 'N=100', m2_trapcv_wcs(1,:));
add_swarmchart(fh_trapcv_m2, 'N=500', m2_trapcv_wcs(2,:));
add_swarmchart(fh_trapcv_m2, 'N=1,000', m2_trapcv_wcs(3,:));
add_swarmchart(fh_trapcv_m2, 'N=5,000', m2_trapcv_wcs(4,:));
add_swarmchart(fh_trapcv_m2, 'N=10,000', m2_trapcv_wcs(5,:));

ylabel('Water Content (v/v)', FontSize=13, Interpreter='tex')
ax=gca; ax.FontSize=14;

saveas(fh_trapcv_m2, 'fig\fig3d_trapcv_m2.jpg');





