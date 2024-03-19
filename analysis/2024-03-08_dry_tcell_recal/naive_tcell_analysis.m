close all; 

pair_path_day1rep1 = "data_rescaled\tcell_day1_rep1_clean_rescale.csv";
pair_path_day1rep2 = "data_rescaled\tcell_day1_rep2_clean_rescale.csv";
pair_path_day2rep1 = "data_rescaled\tcell_day2_rep1_clean_rescale.csv";
pair_path_day2rep2 = "data_rescaled\tcell_day2_rep2_clean_rescale.csv";
path_list = {pair_path_day1rep1, pair_path_day1rep2, pair_path_day2rep1, pair_path_day2rep2};

save_path = "fig";

cutoff_bms = [10, 7.5];

fnames = {"naive_tcell_human.csv", "naive_tcell_mouse.csv"};

labels = {"day1", "day2"};
for i = 1:2
    tab = [readtable(path_list{2*i-1}); readtable(path_list{2*i})];

    small_cells = tab(tab.fl1_mass_pg < cutoff_bms(i), :);
    large_cells = tab(tab.fl1_mass_pg > cutoff_bms(i), :);
    
    f1 = figure;
    s = scatter(small_cells.density_gcm3, small_cells.volume_fl, 25, 'blue', 'filled', 'DisplayName', 'Small T-Cells');
    s.MarkerFaceAlpha = 0.5;
    hold on;
    s = scatter(large_cells.density_gcm3, large_cells.volume_fl, 25, 'red', 'filled', 'DisplayName', 'Large T-Cells');
    s.MarkerFaceAlpha = 0.5;
    xlabel('Dry density (g/cm3)'); ylabel('Dry volume (fl)'); 
    saveas(f1, fullfile(save_path, "dv_scatter_" + labels{i} + ".jpg"))

    f2 = figure;
    [N, edges] = histcounts(small_cells.density_gcm3, 'BinWidth', 0.01);
    histogram('BinEdges', edges, 'BinCounts', N / sum(N), 'FaceColor', 'blue', 'FaceAlpha', 0.2, 'EdgeAlpha', 0.2)
    hold on;
    [N, edges] = histcounts(large_cells.density_gcm3, 'BinWidth', 0.01);
    histogram('BinEdges', edges, 'BinCounts', N / sum(N), 'FaceColor', 'red', 'FaceAlpha', 0.2, 'EdgeAlpha', 0.2)
    xlabel('Dry density (g/cm3)'); ylabel('Probability Density'); 
    saveas(f2, fullfile(save_path, "dens_hists_" + labels{i} + ".jpg"))

    f3 = figure;
    [N, edges] = histcounts(small_cells.volume_fl, 'BinWidth', 1);
    histogram('BinEdges', edges, 'BinCounts', N / sum(N), 'FaceColor', 'blue', 'FaceAlpha', 0.2, 'EdgeAlpha', 0.2)
    hold on;
    [N, edges] = histcounts(large_cells.volume_fl, 'BinWidth', 1);
    histogram('BinEdges', edges, 'BinCounts', N / sum(N), 'FaceColor', 'red', 'FaceAlpha', 0.2, 'EdgeAlpha', 0.2)
    xlabel('Volume (fl)'); ylabel('Probability Density'); 
    saveas(f3, fullfile(save_path, "vol_hists_" + labels{i} + ".jpg"))

    f4 = figure;
    [N, edges] = histcounts(small_cells.fl1_mass_pg, 'BinWidth', 0.3);
    histogram('BinEdges', edges, 'BinCounts', N, 'FaceColor', 'blue', 'FaceAlpha', 0.2, 'EdgeAlpha', 0.2)
    hold on;
    [N, edges] = histcounts(large_cells.fl1_mass_pg, 'BinWidth', 0.3);
    histogram('BinEdges', edges, 'BinCounts', N, 'FaceColor', 'red', 'FaceAlpha', 0.2, 'EdgeAlpha', 0.2)
    xlabel('Buoyant mass (pg)'); ylabel('Count'); 
    saveas(f4, fullfile(save_path, "bm_hists_" + labels{i} + ".jpg"))

    f5 = figure;
    dry_mass_small = small_cells.density_gcm3 .* small_cells.volume_fl;
    dry_mass_large = large_cells.density_gcm3 .* large_cells.volume_fl;
    [N, edges] = histcounts(dry_mass_small, 'BinWidth', 1);
    histogram('BinEdges', edges, 'BinCounts', N / sum(N), 'FaceColor', 'blue', 'FaceAlpha', 0.2, 'EdgeAlpha', 0.2)
    hold on;
    [N, edges] = histcounts(dry_mass_large, 'BinWidth', 1);
    histogram('BinEdges', edges, 'BinCounts', N / sum(N), 'FaceColor', 'red', 'FaceAlpha', 0.2, 'EdgeAlpha', 0.2)
    xlabel('Dry mass (pg)'); ylabel('Probability Density'); 
    saveas(f5, fullfile(save_path, "dry_mass_hists_" + labels{i} + ".jpg"))
    [~, p_val] = ttest2(dry_mass_small, dry_mass_large);
    fprintf('Two-tailed T-test: p = %e\n', p_val)

    f6 = figure;
    s = scatter(small_cells.fl1_mass_pg, small_cells.density_gcm3, 25, 'blue', 'filled', 'DisplayName', 'Small T-Cells');
    s.MarkerFaceAlpha = 0.5;
    hold on;
    s = scatter(large_cells.fl1_mass_pg, large_cells.density_gcm3, 25, 'red', 'filled', 'DisplayName', 'Large T-Cells');
    s.MarkerFaceAlpha = 0.5;
    xlabel('Buoyant mass (pg)'); ylabel('Dry density (g/cm3)'); 
    saveas(f6, fullfile(save_path, "bmdens_scatter_" + labels{i} + ".jpg"))

    writetable(tab, "data_rescaled" + filesep + fnames{i})
    
    
    % b = boxchart(categorical(repmat(labels(i), length(tab.mass_pg), 1)), tab.mass_pg);
    % b.BoxFaceColor = 'red';
    % b.BoxMedianLineColor = 'red';
    % b.MarkerColor = 'red';
    % b.WhiskerLineColor = 'red';

    % fh = figure;
    % histogram(tab.fl1_mass_pg, 100); xlabel('bm') 

    % vol_slice = tab.volume_fl < 50;
    % dens_slice = tab.density_gcm3 > 1.2 & tab.density_gcm3 < 1.7;
    % tab = tab(vol_slice & dens_slice, :);
    % [filepath,name,ext] = fileparts(path_list{i});
    % writetable(tab, fullfile(filepath, name + "_clean") + ext)


end
    
    
    
    
    
% tab = readtable(curr_path);
% % scatter(tab.density_gcm3, tab.volume_fl)
% figure;
% histogram(tab.density_gcm3, 100); xlabel('density');
% figure;
% histogram(tab.volume_fl, 100); xlabel('volume')
% figure;
% histogram(tab.fl1_mass_pg, 100); xlabel('bm')
% 
% vol_slice = tab.volume_fl < 50;
% dens_slice = tab.volume_fl > 1.2 & tab.volume_fl < 1.7;
% tab = tab(vol_slice & dens_slice, :);
% 
% [filepath,name,ext] = fileparts(curr_path);
% writetable(tab, fullfile(filepath, name + "_clean") + ext)