close all;
fpath = "A:\thomasu\processed_data\2023-06-26to07_03_monocytes\mean_masses.csv";
fig_path = "A:\thomasu\processed_data\2023-06-26to07_03_monocytes\fig";


data = readmatrix(fpath, 'NumHeaderLines', 1);
no_phago = data(data(:, 2) == 0, :);
post_phago = data(data(:, 2) == 1, :);

fh = figure; hold on;
scatter(no_phago(:, 1), no_phago(:, 3), 'DisplayName', 'No Phagocytosis', 'MarkerEdgeColor', 'r')
scatter(post_phago(:, 1), post_phago(:, 3), 'DisplayName', 'Post-Phagocytosis', 'MarkerEdgeColor', 'b')
plot(no_phago(:, 1), no_phago(:, 3), 'r', 'HandleVisibility', 'off')
plot(post_phago([3,1,2,5], 1), [mean(post_phago(3:4, 3)); post_phago(1:2, 3); post_phago(5, 3)], ...
    'b', 'HandleVisibility', 'off')

xlabel('Time (days)', 'FontSize', 12)
ylabel('Mean Mass (pg)', 'FontSize', 12)
title('10-13-21 Mass vs. Time')

legend('Location', 'northwest', 'FontSize', 10)
saveas(fh, fig_path + "\" + "mass_time.jpg")