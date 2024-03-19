close all;
addpath(genpath('..\..\final_code'))
paths = ...
    ["A:\thomasu\raw_data\2024-02-26\908_high1\20240304.230918_mass_results\2024-02-26_908_high1.csv",...
    "A:\thomasu\raw_data\2024-02-26\908_high2\20240304.231350_mass_results\2024-02-26_908_high2.csv",...
    "A:\thomasu\raw_data\2024-02-26\908_low1\20240304.231434_mass_results\2024-02-26_908_low1.csv",...
    "A:\thomasu\raw_data\2024-02-26\908_low2\20240304.231531_mass_results\2024-02-26_908_low2.csv"];
labels_ = {'908 High 1', '908 High 2', '908 Low 1', '908 Low 2'};

fh = figure;
for i = 1:length(paths)
    tab = readtable(paths(i));
    tab_sl = tab(tab.mass_pg < 150 & tab.mass_pg > 35, :);
    [~, name, ext] = fileparts(paths(i));
    writetable(tab_sl, strcat('data\', name, ext))
    add_swarmchart(fh, labels_{i}, tab_sl.mass_pg); ylabel('Buoyant mass (pg)')
end
saveas(fh, 'fig\swarm_algae.jpg')