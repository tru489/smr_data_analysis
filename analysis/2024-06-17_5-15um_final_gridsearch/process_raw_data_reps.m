close all;
addpath(genpath("..\..\helpers"));

%% Rep1 compilation
raw_data_lst_rep1 = ls('data_raw\rep1');

% for i = 1:length(raw_data_lst_rep1)
%     seg_tab = readtable(raw_data_lst_rep1{i});
%     figure; histogram(seg_tab.fl1_mass_pg, 150)
% end

rep1_large_szrange = readtable(raw_data_lst_rep1{1});
rep1_mid_szrange = readtable(raw_data_lst_rep1{2});
rep1_small_szrange = readtable(raw_data_lst_rep1{3});

rep1_concat = [rep1_mid_szrange; ...
    rep1_small_szrange(rep1_small_szrange.fl1_mass_pg < 4, :); ...
    rep1_large_szrange(rep1_large_szrange.fl1_mass_pg > 30, :)];
rep1_concat = rep1_concat(rep1_concat.density_gcm3 > 1.046 & ...
    rep1_concat.density_gcm3 < 1.062, :);

writetable(rep1_concat, 'data_processed\rep1_beads_concat.csv')

%% Rep2 compilation
raw_data_lst_rep2 = ls('data_raw\rep2');

% for i = 1:length(raw_data_lst_rep2)
%     seg_tab = readtable(raw_data_lst_rep2{i});
%     figure; histogram(seg_tab.fl1_mass_pg, 150)
% end

rep2_large_szrange = readtable(raw_data_lst_rep2{1});
rep2_mid_szrange = readtable(raw_data_lst_rep2{2});
rep2_small_szrange = readtable(raw_data_lst_rep2{3});

rep2_concat = [rep2_mid_szrange; ...
    rep2_small_szrange(rep2_small_szrange.fl1_mass_pg < 4, :); ...
    rep2_large_szrange(rep2_large_szrange.fl1_mass_pg > 30, :)];
rep2_concat = rep2_concat(rep2_concat.density_gcm3 > 1.046 & ...
    rep2_concat.density_gcm3 < 1.062, :);

writetable(rep2_concat, 'data_processed\rep2_beads_concat.csv')

full_data_concat = [rep1_concat; rep2_concat];
writetable(full_data_concat, 'data_processed\allreps_beads_concat.csv')
%% Plotting
gt_data = readmatrix("data_processed\dv_ground_truth_beads.csv");

fh1 = figure; hold on;
s1 = scatter(full_data_concat.volume_fl, full_data_concat.density_gcm3, 40, 'blue', 'filled', DisplayName='Two-fluid measurements');
s1.MarkerFaceAlpha = 0.35;
s1 = scatter(gt_data(2,:), gt_data(1,:), 190, '+', 'red', LineWidth=4, DisplayName='Ground Truth'); 
ax=gca; ax.FontSize=15;
xlabel('Dry Density (g/cm3)', FontSize=20); ylabel('Dry Volume (fL)', FontSize=20);
saveas(fh1, 'fig\comp_with_gt_nolog.jpg')

fh2 = figure; hold on;
s1 = scatter(full_data_concat.volume_fl, full_data_concat.density_gcm3, 40, 'blue', 'filled', DisplayName='Two-fluid measurements');
s1.MarkerFaceAlpha = 0.35;
s1 = scatter(gt_data(2,:), gt_data(1,:), 190, '+', 'red', LineWidth=4, DisplayName='Ground Truth'); 
ax=gca; ax.FontSize=15;
xlabel('Dry Density (g/cm3)', FontSize=20); ylabel('Dry Volume (fL)', FontSize=20);
set(gca,'Xscale','log')
saveas(fh2, 'fig\comp_with_gt_log.jpg')

fh3 = figure; scatter(rep1_concat.volume_fl, rep1_concat.density_gcm3)
hold on; scatter(rep2_concat.volume_fl, rep2_concat.density_gcm3)
ax=gca; ax.FontSize=15;
xlabel('Dry Density (g/cm3)', FontSize=20); ylabel('Dry Volume (fL)', FontSize=20);
saveas(fh3, 'fig\replicates_comparison_nolog.jpg')

fh4 = figure; scatter(rep1_concat.volume_fl, rep1_concat.density_gcm3)
hold on; scatter(rep2_concat.volume_fl, rep2_concat.density_gcm3)
ax=gca; ax.FontSize=15;
xlabel('Dry Density (g/cm3)', FontSize=20); ylabel('Dry Volume (fL)', FontSize=20);
set(gca,'Xscale','log')
saveas(fh4, 'fig\replicates_comparison_log.jpg')
