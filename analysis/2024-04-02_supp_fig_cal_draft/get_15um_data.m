close all;
addpath(genpath("..\..\helpers"));

path_h2o = ls('C:\thomasu\smr_data_analysis\analysis\2024-04-02_supp_fig_cal_draft\data\bead_pair_15um\h2o');
path_d2o = ls('C:\thomasu\smr_data_analysis\analysis\2024-04-02_supp_fig_cal_draft\data\bead_pair_15um\d2o');

h2o_rfs = [1158524, 1158944, 1158628, 1158820];
d2o_rfs = [1142244, 1142944, 1142328, 1142820];

h2o_rf_adj = zeros(size(h2o_rfs));
d2o_rf_adj = zeros(size(d2o_rfs));

% 73 88
h2o_avgs_arr = zeros(size(path_h2o));
for i = 1:length(path_h2o)
    h2o_tab = readtable(path_h2o{i});
    h2o_bm = h2o_tab.mass_pg;
    h2o_avgs_arr(i) = mean(h2o_bm(h2o_bm > 73 & h2o_bm < 88));
    tab_sl = h2o_tab(h2o_bm > 73 & h2o_bm < 88, :);

    h2o_rf_adj(i) = h2o_rfs(i) - mean(tab_sl.avg_baseline);
    
    % figure; histogram(h2o_bm(h2o_bm > 73 & h2o_bm < 88), 150)
end

% 82 99
d2o_avgs_arr = zeros(size(path_d2o));
d2o_rf_adj = zeros(size(d2o_rfs));
for j = 1:length(path_d2o)
    d2o_tab = readtable(path_d2o{j});
    d2o_bm = d2o_tab.mass_pg;
    d2o_avgs_arr(j) = -mean(d2o_bm(d2o_bm > 82 & d2o_bm < 99));
    tab_sl = d2o_tab(d2o_bm > 82 & d2o_bm < 99, :);
    
    d2o_rf_adj(j) = d2o_rfs(j) + mean(tab_sl.avg_baseline);

    % figure; histogram(d2o_tab.mass_pg(d2o_tab.mass_pg > 82 & d2o_tab.mass_pg < 99), 150)
end

%% Calculate densities
slp = -173501.99879609281; 
intc = 1.3332725199553773E+6;

dens_h2o = (h2o_rf_adj - intc) / slp;
dens_d2o = (d2o_rf_adj - intc) / slp;

particle_densities = (dens_d2o .* h2o_avgs_arr - dens_h2o .* d2o_avgs_arr) ./ (h2o_avgs_arr - d2o_avgs_arr);
fprintf('Particle densities: \n    ')
disp(particle_densities)
fprintf('Mean density: %f\n', mean(particle_densities))