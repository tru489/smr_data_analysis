close all;

pair_path = "C:\thomasu\smr_data_analysis\analysis\2024-01-10_dry_tcells\data\6_8_10um_bead_trap.csv";
save_path = "C:\thomasu\smr_data_analysis\analysis\2024-01-10_dry_tcells\data\fig";
p_summ = readtable(pair_path);

% density_gate = p_summ.density_gcm3 > 1.0 & p_summ.density_gcm3 < 1.62;
% volume_gate = p_summ.density_gcm3 > 1.0 & p_summ.density_gcm3 < 1.5;
p_summ = p_summ(density_gate, :);

f1 = figure;
s = scatter(p_summ.density_gcm3, p_summ.volume_fl, 25, 'blue', 'filled');
s.MarkerFaceAlpha = 0.5;
xlabel('Dry density (g/cm3)'); ylabel('Dry volume (fl)');
saveas(f1, fullfile(save_path, 'bead_scatter.jpg'))

f2 = figure;
histogram(p_summ.fl1_mass_pg, 50)
xlabel('Buoyant mass (pg)')
ylabel('Count')
saveas(f2, fullfile(save_path, 'bead_hist.jpg'))

gate_10um = p_summ.volume_fl > 450 & p_summ.volume_fl < 600;
beads_10um = p_summ(gate_10um, :);
fprintf('10um bead mean density: %.03f g/cm3\n', mean(beads_10um.density_gcm3))
fprintf('10um bead cv density: %.03f%%\n', 100 * std(beads_10um.density_gcm3) / mean(beads_10um.density_gcm3))
fprintf('10um bead mean volume: %.03f fl\n', mean(beads_10um.volume_fl))
fprintf('10um bead cv volume: %.03f%%\n', 100 * std(beads_10um.volume_fl) / mean(beads_10um.volume_fl))
fprintf('\n')

gate_8um = p_summ.volume_fl > 220 & p_summ.volume_fl < 300;
beads_8um = p_summ(gate_8um, :);
fprintf('8um bead mean density: %.03f g/cm3\n', mean(beads_8um.density_gcm3))
fprintf('8um bead cv density: %.03f%%\n', 100 * std(beads_8um.density_gcm3) / mean(beads_8um.density_gcm3))
fprintf('8um bead mean volume: %.03f fl\n', mean(beads_8um.volume_fl))
fprintf('8um bead cv volume: %.03f%%\n', 100 * std(beads_8um.volume_fl) / mean(beads_8um.volume_fl))
fprintf('\n')

gate_6um = p_summ.volume_fl > 80 & p_summ.volume_fl < 150;
beads_6um = p_summ(gate_6um, :);
fprintf('6um bead mean density: %.03f g/cm3\n', mean(beads_6um.density_gcm3))
fprintf('6um bead cv density: %.03f%%\n', 100 * std(beads_6um.density_gcm3) / mean(beads_6um.density_gcm3))
fprintf('6um bead mean volume: %.03f fl\n', mean(beads_6um.volume_fl))
fprintf('6um bead cv volume: %.03f%%\n', 100 * std(beads_6um.volume_fl) / mean(beads_6um.volume_fl))
fprintf('\n')

% writetable(p_summ, "A:\thomasu\raw_data\2023-12-17\6_8_10_um_denstrap\20240110.112428_density_trap_results\peakset_summary_clean.csv")
