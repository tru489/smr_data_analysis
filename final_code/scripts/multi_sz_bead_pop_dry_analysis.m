close all;

fprintf('\nGetting paired sample...\n')
[fname, dir, ~] = uigetfile('../*.*','Select paired density trap analysis result...',' ');
% pair_path = "C:\thomasu\smr_data_analysis\analysis\2024-01-10_dry_tcells\data\6_8_10um_bead_trap.csv";
pair_path = fullfile(dir, fname);
% save_path = "C:\thomasu\smr_data_analysis\analysis\2024-01-10_dry_tcells\data\fig";
save_path = dir;
p_summ = readtable(pair_path);

f1 = figure;
s1 = scatter(p_summ.density_gcm3, p_summ.volume_fl, 25, 'blue', 'filled');
s1.MarkerFaceAlpha = 0.5;
hold on;
s2 = scatter([1.05, 1.05, 1.05], 4/3 * pi * ([6.007, 7.979, 10.12] / 2) .^ 3, 70, '+', 'red', LineWidth=3);
s2.MarkerFaceAlpha = 0.6;
xlabel('Dry density (g/cm3)'); ylabel('Dry volume (fl)');
saveas(f1, fullfile(save_path, 'all_bead_scatter.jpg'))

% -----------------------------------------------------------------------
gate_10um = p_summ.volume_fl > 450 & p_summ.volume_fl < 600;
beads_10um = p_summ(gate_10um, :);
f2 = analyze_bead_population(beads_10um, 10.12, 0.9);
saveas(f2, fullfile(save_path, "10um_bead_scatter.jpg"))

% -----------------------------------------------------------------------
gate_8um = p_summ.volume_fl > 220 & p_summ.volume_fl < 300;
beads_8um = p_summ(gate_8um, :);
f3 = analyze_bead_population(beads_8um, 7.979, 1.1);
saveas(f3, fullfile(save_path, "8um_bead_scatter.jpg"))

% -----------------------------------------------------------------------
gate_6um = p_summ.volume_fl > 80 & p_summ.volume_fl < 150;
beads_6um = p_summ(gate_6um, :);
f4 = analyze_bead_population(beads_6um, 6.007, 1.0);
saveas(f4, fullfile(save_path, "6um_bead_scatter.jpg"))

function fh = analyze_bead_population(bead_slice, diameter, pct_cv)
    fprintf('10um bead mean density: %.03f g/cm3\n', mean(bead_slice.density_gcm3))
    fprintf('10um bead cv density: %.03f%%\n', 100 * std(bead_slice.density_gcm3) / mean(bead_slice.density_gcm3))
    fprintf('10um bead mean volume: %.03f fl\n', mean(bead_slice.volume_fl))
    fprintf('10um bead cv volume: %.03f%%\n', 100 * std(bead_slice.volume_fl) / mean(bead_slice.volume_fl))
    fprintf('\n')
    fh = figure;
    s1 = scatter(bead_slice.density_gcm3, bead_slice.volume_fl, 25, 'blue', 'filled', DisplayName='10 um beads'); 
    s1.MarkerFaceAlpha = 0.3;
    hold on;
    gt_volume = 4/3 * pi * (diameter / 2) .^ 3;
    s2 = scatter(1.05, gt_volume, 70, '+', 'red', LineWidth=3, DisplayName='Ground truth mean'); 
    s2.MarkerFaceAlpha = 0.6;

    diam_cv_range = [diameter - diameter * pct_cv/100, diameter + diameter * pct_cv/100];
    vol_cv_range = abs(4/3 * pi * (diam_cv_range / 2).^3 - gt_volume);
    errorbar(1.05, 4/3 * pi * (diameter / 2) .^ 3, abs(vol_cv_range(1)), abs(vol_cv_range(2)), 0, 0, 'LineStyle','none', Color='red', LineWidth=1.5, HandleVisibility='off')
    s3 = scatter(mean(bead_slice.density_gcm3), mean(bead_slice.volume_fl), 70, '+', 'blue', LineWidth=3, DisplayName='Empirical mean'); 
    s3.MarkerFaceAlpha = 0.6;
    errorbar(mean(bead_slice.density_gcm3), mean(bead_slice.volume_fl), ...
        std(bead_slice.volume_fl), "vertical", 'LineStyle','none', Color='blue', LineWidth=2, HandleVisibility='off')
    errorbar(mean(bead_slice.density_gcm3), mean(bead_slice.volume_fl), ...
        std(bead_slice.density_gcm3), "horizontal", 'LineStyle','none', Color='blue', LineWidth=1.5, HandleVisibility='off')

    annotation(fh,'textbox',...
        [0.66 0.82 0.32 0.15],...
        'String',...
        {"Volume emp. CV: " + string(100 * std(bead_slice.volume_fl) / mean(bead_slice.volume_fl)) + "%", ...
        "Volume GT CV: " + string(mean(vol_cv_range) / gt_volume * 100) + "%", ...
        "Density emp. CV: " + string(100 * std(bead_slice.density_gcm3) / mean(bead_slice.density_gcm3)) + "%"},...
        'FitBoxToText','off');
    
    legend('Location', 'northoutside')
    xlabel('Dry density (g/cm3)'); ylabel('Dry volume (fl)');
end