close all;

addpath(genpath('..\..\helpers'));
template_path = 'C:\thomasu\smr_data_analysis\analysis\2024-10-21_wc_sensitivity_analysis\template.potx';

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
tot_vol_n = 1000; % tot volume n

cf = 0.8; %pg/Hz

%% Run simulations for each parameter variation

data_aggr = zeros(6, n_dp);

%  ------------------------ Vary rho_f1 (bl shifts) ------------------------
rho_f1_lsp = normrnd(rho_f1, 6e-4, [1,n_dp]);
[~, ~, wc_shift_rho1] = oat_analyze_iter(rho_f1_lsp, rho_f2, bm1, bm2, tot_vol, cf);
data_aggr(1,:) = wc_shift_rho1;

%  ------------------------ Vary rho_f2 (bl shifts)  ------------------------
rho_f2_lsp = normrnd(rho_f2, 6e-4, [1,n_dp]);
[~, ~, wc_shift_rho2] = oat_analyze_iter(rho_f1, rho_f2_lsp, bm1, bm2, tot_vol, cf);
data_aggr(2,:) = wc_shift_rho2;

%  ------------------------ Vary bm1  ------------------------
bm1_lsp = normrnd(bm1, bm1_std / sqrt(bm1_n), [1,n_dp]);
[~, ~, wc_m1_vary] = oat_analyze_iter(rho_f1, rho_f2, bm1_lsp, bm2, tot_vol, cf);
data_aggr(3,:) = wc_m1_vary;

%  ------------------------ Vary bm2  ------------------------
bm2_lsp = normrnd(bm2, bm2_std / sqrt(bm2_n), [1,n_dp]);
[~, ~, wc_m2_vary] = oat_analyze_iter(rho_f1, rho_f2, bm1, bm2_lsp, tot_vol, cf);
data_aggr(4,:) = wc_m2_vary;

%  ------------------------ Vary vol  ------------------------
vol_lsp = normrnd(tot_vol, tot_vol_std / sqrt(tot_vol_n), [1,n_dp]);
[~, ~, wc_vol] = oat_analyze_iter(rho_f1, rho_f2, bm1, bm2, vol_lsp, cf);
data_aggr(5,:) = wc_vol;

%  ------------------------ Vary cf  ------------------------
cf_lsp = normrnd(cf, 0.009, [1,n_dp]);
[~, ~, wc_cf] = oat_analyze_iter(rho_f1, rho_f2, bm1, bm2, tot_vol, cf_lsp);
data_aggr(6,:) = wc_cf;

means = zeros(size(data_aggr,1),1);
std_aggr = zeros(size(data_aggr,1),1);
errlow = zeros(size(data_aggr,1),1);
 
for i = 1:size(data_aggr,1)
    std_aggr(i) = std(data_aggr(i, :));
end



%% Create figs
labels_orig = {'H2O density', 'D2O density', 'Buoyant mass (H2O)', 'Buoyant mass (D2O)', 'Volume (fL)', 'Calibration factor (pg/Hz)'};

labels_ = categorical(labels_orig);
labels_ = reordercats(labels_,labels_orig);

fh_swarm = figure(Position=[2093         194        1018         725]); 
for i = 1:size(data_aggr,1)
    add_swarmchart(fh_swarm, labels_orig{i}, data_aggr(i,:));
end
ylabel('Water Content (v/v)', FontSize=13, Interpreter='tex')
ax=gca; ax.FontSize=14;
saveas(fh_swarm, 'fig\fig4a_swarm.jpg') 

fh = figure(Position=[2093         194        1018         725]); 
bar(labels_, std_aggr)
fprintf('%s\n', labels_')
fprintf('%.9f\n',std_aggr)
ylabel('STD of Water Content (v/v)', FontSize=13, Interpreter='tex')
ax=gca; ax.FontSize=14;
saveas(fh, 'fig\fig4b_bar.jpg')
