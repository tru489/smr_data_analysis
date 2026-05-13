close all;
full_path = 'A:\thomasu\processed_data\2023-06-08to09_l1210_trapping\';
fname = 'l1210_trap_2_datasmr_processed.csv';

[~, f_ident, ~] = fileparts(fname);
analyzed_path = [full_path fname];
fig_dir = ['C:\thomasu\smr_data_analysis\analysis\' ...
    '2023-06-08_l1210_trapping\fig'];
txt_dir = ['C:\thomasu\smr_data_analysis\analysis\' ...
    '2023-06-08_l1210_trapping\txt'];

data = readmatrix(analyzed_path);
time = data(:, 1); % s
mean_freq = data(:, 3); % s
cal_factor = 1.3024; % Hz/pg
mass = mean_freq / cal_factor;
scatter(1:length(data(:, 3)), data(:, 3))

% segments = [...
%     18, 97;
%     98, 122;
%     123, 132;
%     146, 189;
%     248, 305;
%     314, 477;
%     479, 505
%     ];

segments = [...
    13, 120;
    218, 232;
    253, 265;
    268, 358;
    ];

[r, c] = size(segments);
rsq = zeros(1, r);
cvs = zeros(1, r);
for i = 1:r
    time_slice = time(segments(i, 1):segments(i, 2));
    mass_slice = mass(segments(i, 1):segments(i, 2));
    mean_mass = mean(mass_slice);
    [mass_slice_cleaned, mask] = rmoutliers(mass_slice);
    time_slice_cleaned = time_slice(~mask);

    fig = figure; hold on;
    scatter(time_slice_cleaned, mass_slice_cleaned, 20)
    xlabel('Time (s)')
    ylabel('Mass (pg)')
    title(['Trap # ' num2str(i)])
    c = polyfit(time_slice_cleaned, mass_slice_cleaned, 1);
    mass_fit = polyval(c, time_slice_cleaned);
    plot(time_slice_cleaned, mass_fit)
    saveas(fig, [fig_dir filesep f_ident '_trap_' num2str(i) '.jpg'])
    
    resid = mass_slice_cleaned - mass_fit;
    ss_resid = sum(resid.^2);
    ss_total = (length(mass_slice_cleaned) - 1) * var(mass_slice_cleaned);
    rsq(i) = 1 - ss_resid / ss_total;
    cvs(i) = std(resid) / mean_mass;
end

fileID = fopen([txt_dir filesep f_ident '_info.txt'], 'w');
fprintf(fileID, 'Average r-squared: %f\n', mean(rsq));
fprintf(fileID, 'Average percent CV: %.3f%%\n', 100 * mean(cvs));
