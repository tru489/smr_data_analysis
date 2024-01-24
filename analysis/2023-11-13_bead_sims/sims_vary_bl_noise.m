close all;

save_path = "C:\Users\Blue\Documents\images";

bead_data_arr = [...
    "A:\thomasu\raw_data\2023-10-31\8um_bead_trap_5\20231113.110914_mass_results\2023-10-31_8um_bead_trap_5.csv",
    "A:\thomasu\raw_data\2023-11-27\sim_data_100_transit_dp\20231128.121127_mass_results\2023-11-27_sim_data_100_transit_dp.csv",
    "A:\thomasu\raw_data\2023-11-27\sim_data_200_transit_dp\20231128.121105_mass_results\2023-11-27_sim_data_200_transit_dp.csv",
    "A:\thomasu\raw_data\2023-11-27\sim_data_300_transit_dp\20231128.121028_mass_results\2023-11-27_sim_data_300_transit_dp.csv",
    "A:\thomasu\raw_data\2023-11-27\sim_data_400_transit_dp\20231128.121003_mass_results\2023-11-27_sim_data_400_transit_dp.csv",
    "A:\thomasu\raw_data\2023-11-27\sim_data_500_transit_dp\20231128.120818_mass_results\2023-11-27_sim_data_500_transit_dp.csv"];

labels = ["Experiment", "Sim. pk\_wid=100", "Sim. pk\_wid=200", "Sim. pk\_wid=300", "Sim. pk\_wid=400", "Sim. pk\_wid=500"];

fig1 = figure;
for i = 1:length(bead_data_arr)
    tab = readtable(bead_data_arr(i));

    s = swarmchart(categorical(repmat(labels(i), length(tab.mass_pg), 1)), tab.mass_pg, 8, 'filled', 'MarkerFaceAlpha', 0.2, ...
            'MarkerEdgeAlpha',0.2, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue');
    hold on;
    b = boxchart(categorical(repmat(labels(i), length(tab.mass_pg), 1)), tab.mass_pg);
    b.BoxFaceColor = 'red';
    b.BoxMedianLineColor = 'red';
    b.MarkerColor = 'red';
    b.WhiskerLineColor = 'red';
end
ylabel('Buoyant mass (pg)')
saveas(fig1, save_path + filesep + "fig1.jpg")

fig2 = figure;
for i = 1:length(bead_data_arr)
    tab = readtable(bead_data_arr(i));
    
    s = swarmchart(categorical(repmat(labels(i), length(tab.mass_pg), 1)), tab.mass_pg - mean(tab.mass_pg), 8, 'filled', 'MarkerFaceAlpha', 0.2, ...
            'MarkerEdgeAlpha',0.2, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue');
    hold on;
    b = boxchart(categorical(repmat(labels(i), length(tab.mass_pg), 1)), tab.mass_pg - mean(tab.mass_pg));
    b.BoxFaceColor = 'red';
    b.BoxMedianLineColor = 'red';
    b.MarkerColor = 'red';
    b.WhiskerLineColor = 'red';
end
ylabel('Normalized buoyant mass (pg)')
saveas(fig2, save_path + filesep + "fig2.jpg")

fig3 = figure;
std_arr = zeros(size(bead_data_arr));
for i = 1:length(bead_data_arr)
    tab = readtable(bead_data_arr(i));
    
    std_arr(i) = std(rmoutliers(tab.mass_pg));
end
scatter(100:100:500, std_arr(2:end), 'Color', 'blue'); hold on;
plot(100:100:500, std_arr(2:end), 'LineWidth', 3, 'Color', 'blue');
xlabel('Peak Width (datapoints)', 'FontSize', 12)
ylabel('Standard deviation of buoyant mass (pg)', 'FontSize', 12)
saveas(fig3, save_path + filesep + "fig3.jpg")