close all;

save_path = "C:\Users\Blue\Documents\images";

bead_data_arr = [...
    "A:\thomasu\raw_data\2023-10-31\8um_bead_trap_5\20231113.110914_mass_results\2023-10-31_8um_bead_trap_5.csv",
    "A:\thomasu\raw_data\2023-11-27\sim_data_00_std_noise\20231128.110603_mass_results\2023-11-27_sim_data_00_std_noise.csv",
    "A:\thomasu\raw_data\2023-11-27\sim_data_02_std_noise\20231128.110638_mass_results\2023-11-27_sim_data_02_std_noise.csv",
    "A:\thomasu\raw_data\2023-11-27\sim_data_04_std_noise\20231128.110718_mass_results\2023-11-27_sim_data_04_std_noise.csv",
    "A:\thomasu\raw_data\2023-11-27\sim_data_06_std_noise\20231128.110740_mass_results\2023-11-27_sim_data_06_std_noise.csv",
    "A:\thomasu\raw_data\2023-11-27\sim_data_08_std_noise\20231128.110804_mass_results\2023-11-27_sim_data_08_std_noise.csv",
    "A:\thomasu\raw_data\2023-11-27\sim_data_10_std_noise\20231128.110837_mass_results\2023-11-27_sim_data_10_std_noise.csv"];

labels = ["Experiment", "Sim. std=0.0", "Sim. std=0.2", "Sim. std=0.4", "Sim. std=0.6", "Sim. std=0.8", "Sim. std=1.0"];

fig1 = figure;
for i = 1:length(bead_data_arr)
    tab = readtable(bead_data_arr(i));
    
    s = swarmchart(categorical(repmat(labels(i), length(tab.mass_pg), 1)), tab.mass_pg, 15);
    s.Marker = '.';
    hold on;
    boxchart(categorical(repmat(labels(i), length(tab.mass_pg), 1)), tab.mass_pg)
end
ylabel('Buoyant mass (pg)')
saveas(fig1, save_path + filesep + "fig1.jpg")

fig2 = figure;
for i = 1:length(bead_data_arr)
    tab = readtable(bead_data_arr(i));
    
    s = swarmchart(categorical(repmat(labels(i), length(tab.mass_pg), 1)), tab.mass_pg - mean(tab.mass_pg), 15);
    s.Marker = '.';
    hold on;
    boxchart(categorical(repmat(labels(i), length(tab.mass_pg), 1)), tab.mass_pg - mean(tab.mass_pg))
end
ylabel('Normalized buoyant mass (pg)')
saveas(fig2, save_path + filesep + "fig2.jpg")

fig3 = figure;
std_arr = zeros(size(bead_data_arr));
for i = 1:length(bead_data_arr)
    tab = readtable(bead_data_arr(i));
    
    std_arr(i) = std(rmoutliers(tab.mass_pg));
end
scatter(0:0.2:1, std_arr(2:end))
xlabel('Standard deviation of baseline noise', 'FontSize', 12)
ylabel('Standard deviation of buoyant mass (pg)', 'FontSize', 12)
saveas(fig3, save_path + filesep + "fig3.jpg")