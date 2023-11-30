close all;

bead_data_arr = [...
    "A:\thomasu\raw_data\2023-10-31\8um_bead_trap_1\20231113.110012_mass_results\2023-10-31_8um_bead_trap_1.csv", 
    "A:\thomasu\raw_data\2023-11-29\10-31-rep1_paired_sim\20231129.115218_mass_results\2023-11-29_10-31-rep1_paired_sim.csv",
    "A:\thomasu\raw_data\2023-10-31\8um_bead_trap_2\20231113.110250_mass_results\2023-10-31_8um_bead_trap_2.csv",
    "A:\thomasu\raw_data\2023-11-29\10-31-rep2_paired_sim\20231129.115252_mass_results\2023-11-29_10-31-rep2_paired_sim.csv",
    "A:\thomasu\raw_data\2023-10-31\8um_bead_trap_4\20231113.110650_mass_results\2023-10-31_8um_bead_trap_4.csv",
    "A:\thomasu\raw_data\2023-11-29\10-31-rep4_paired_sim\20231129.115345_mass_results\2023-11-29_10-31-rep4_paired_sim.csv",
    "A:\thomasu\raw_data\2023-10-31\8um_bead_trap_5\20231113.110914_mass_results\2023-10-31_8um_bead_trap_5.csv",
    "A:\thomasu\raw_data\2023-11-29\10-31-rep5_paired_sim\20231129.115428_mass_results\2023-11-29_10-31-rep5_paired_sim.csv"];

labels = ["Exp. 1", "Exp. 1 Paired Sim.", "Exp. 2", "Exp. 2 Paired Sim.", "Exp. 3", "Exp. 3 Paired Sim.", "Exp. 4", "Exp. 4 Paired Sim."];

fig1 = figure;
for i = 1:length(bead_data_arr)
    tab = readtable(bead_data_arr(i));
    
    s = swarmchart(categorical(repmat(labels(i), length(tab.mass_pg), 1)), ...
        tab.mass_pg, 8, 'filled', 'MarkerFaceAlpha', 0.2, ...
        'MarkerEdgeAlpha',0.2, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue');
    hold on;
    b = boxchart(categorical(repmat(labels(i), length(tab.mass_pg), 1)), tab.mass_pg);
    b.BoxFaceColor = 'red';
    b.BoxMedianLineColor = 'red';
    b.MarkerColor = 'red';
    b.WhiskerLineColor = 'red';

    % if i <=4
    %     s = swarmchart(categorical(repmat("Rep " + num2str(i), length(tab.mass_pg), 1)), tab.mass_pg, 15);
    %     s.Marker = '.';
    %     hold on;
    %     boxchart(categorical(repmat("Rep " + num2str(i), length(tab.mass_pg), 1)), tab.mass_pg)
    % else
    %     s = swarmchart(categorical(repmat("Simulated " + num2str(i-4), length(tab.mass_pg), 1)), (tab.mass_pg), 15);
    %     s.Marker = '.';
    %     hold on;
    %     boxchart(categorical(repmat("Simulated " + num2str(i-4), length(tab.mass_pg), 1)), (tab.mass_pg))
    % end
end

for i = 1:4
    emp_tab = readtable(bead_data_arr(2*i-1));
    sim_tab = readtable(bead_data_arr(2*i));
    [h, p_val] = vartest2(emp_tab.mass_pg, sim_tab.mass_pg);
    fprintf('Empirical std: %.3f\n', std(emp_tab.mass_pg))
    fprintf('Simulated std: %.3f\n', std(sim_tab.mass_pg))
    fprintf('F-test p-value for whether 2 samples came from different distributions (sample %d): p = %.2f\n', i, p_val)
    fprintf('\n')
end
ylabel('Buoyant mass (pg)')
