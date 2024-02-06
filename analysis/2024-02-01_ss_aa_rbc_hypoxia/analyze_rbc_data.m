close all;

data_paths = [...
    "C:\thomasu\smr_data_analysis\analysis\2024-02-01_ss_aa_rbc_hypoxia\data\2024-01-30_aa_mannitol.csv", ...
    "C:\thomasu\smr_data_analysis\analysis\2024-02-01_ss_aa_rbc_hypoxia\data\2024-01-30_aa_scavenger.csv",...
    "C:\thomasu\smr_data_analysis\analysis\2024-02-01_ss_aa_rbc_hypoxia\data\2024-01-30_ss_mannitol.csv",...
    "C:\thomasu\smr_data_analysis\analysis\2024-02-01_ss_aa_rbc_hypoxia\data\2024-01-30_ss_scavenger_1pct.csv",...
    "C:\thomasu\smr_data_analysis\analysis\2024-02-01_ss_aa_rbc_hypoxia\data\2024-01-30_ss_scavenger_2pct.csv"];
labels_arr = ["AA + mannitol", "AA + 1% SMS", "SS + mannitol", "SS + 1% SMS", "SS + 2% SMS"];
file_label_arr = ["aa_mannitol", "aa_scavenger", "ss_mannitol", "ss_scavenger_1pct", "ss_scavenger_2pct"];

data_saved_mass = cell(length(data_paths), 1);
data_saved_nd = cell(length(data_paths), 1);
fh_mass = figure;
fh_nd = figure;
for i = 1:length(data_paths)
    data = readtable(data_paths(i));
    slice_logi = data.mass_pg < 13 & data.mass_pg > 4;
    data_sl = data(slice_logi, :);
    data_saved_mass{i} = data_sl.mass_pg;
    
    ndev_gate = data_sl.node_dev_mean > -0.6 & data_sl.node_dev_mean < 0.6;
    ndev_sl = data_sl.node_dev_mean(ndev_gate);
    data_saved_nd{i} = ndev_sl;

    add_swarmchart(fh_mass, labels_arr(i), data_sl.mass_pg)
    add_swarmchart(fh_nd, labels_arr(i), ndev_sl)

    fh_temp = figure;
    s = scatter(data_sl.mass_pg(ndev_gate), ndev_sl, 25, 'b', 'filled', 'o');
    xlabel('Buoyant mass (pg)'); ylabel('Node deviation (Hz)');
    title(labels_arr(i))
    s.MarkerFaceAlpha = 0.3;
    saveas(fh_temp, "C:\thomasu\smr_data_analysis\analysis\2024-02-01_ss_aa_rbc_hypoxia\fig\bm_nd_scatter_" + file_label_arr(i) + ".jpg")
end

figure(fh_mass)
ylabel('Buoyant mass (pg)'); xline(2.5, LineWidth=1.5, Color='k');
saveas(fh_mass, "C:\thomasu\smr_data_analysis\analysis\2024-02-01_ss_aa_rbc_hypoxia\fig\swarm_comp_mass.jpg")

figure(fh_nd)
ylabel('Node deviation (Hz)'); xline(2.5, LineWidth=1.5, Color='k');
saveas(fh_nd, "C:\thomasu\smr_data_analysis\analysis\2024-02-01_ss_aa_rbc_hypoxia\fig\swarm_comp_ndev.jpg")


disp('------Mass statistical tests------')
[~, p_val] = ttest2(data_saved_mass{1}, data_saved_mass{2});
fprintf('    Between %s and %s: p = %.07f\n', labels_arr(1), labels_arr(2), p_val)

[~, p_val] = ttest2(data_saved_mass{3}, data_saved_mass{4});
fprintf('    Between %s and %s: p = %e\n', labels_arr(3), labels_arr(4), p_val)

[~, p_val] = ttest2(data_saved_mass{4}, data_saved_mass{5});
fprintf('    Between %s and %s: p = %e\n', labels_arr(4), labels_arr(5), p_val)

[~, p_val] = ttest2(data_saved_mass{3}, data_saved_mass{5});
fprintf('    Between %s and %s: p = %e\n', labels_arr(3), labels_arr(5), p_val)

%% Ndev stat tests
disp('------Ndev statistical tests------')
[~, p_val] = ttest2(data_saved_nd{1}, data_saved_nd{2});
fprintf('    Between %s and %s: p = %.07f\n', labels_arr(1), labels_arr(2), p_val)

[~, p_val] = ttest2(data_saved_nd{3}, data_saved_nd{4});
fprintf('    Between %s and %s: p = %e\n', labels_arr(3), labels_arr(4), p_val)

[~, p_val] = ttest2(data_saved_nd{4}, data_saved_nd{5});
fprintf('    Between %s and %s: p = %e\n', labels_arr(4), labels_arr(5), p_val)

[~, p_val] = ttest2(data_saved_nd{3}, data_saved_nd{5});
fprintf('    Between %s and %s: p = %e\n', labels_arr(3), labels_arr(5), p_val)


%% Helpers
function add_swarmchart(fh, label_, data_vec)
    figure(fh)
    s = swarmchart(categorical(repmat(label_, length(data_vec), 1)), ...
        data_vec, 8, 'filled', 'MarkerFaceAlpha', 0.2, ...
        'MarkerEdgeAlpha',0.2, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue');
    hold on;
    b = boxchart(categorical(repmat(label_, length(data_vec), 1)), data_vec);
    b.BoxFaceColor = 'red';
    b.BoxMedianLineColor = 'red';
    b.MarkerColor = 'red';
    b.WhiskerLineColor = 'red';
    b.MarkerStyle = 'none';
end