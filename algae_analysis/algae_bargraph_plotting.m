close all;
data_path = 'A:\thomasu\processed_data\20230511-15_algae_data';

min_cutoff = 28;
max_cutoff = 250;

data = dir(data_path);
fnames = {data.name};
fnames = data(~ismember(fnames ,{'.','..'}));
fnames = {fnames.name};

bead_file_mask = strfind(fnames, 'beads');
bead_file_idx = find(~cellfun(@isempty,f));
fnames(bead_file_idx) = [];

day = cell(length(fnames), 1);
sample = cell(length(fnames), 1);
mean_bm = zeros(length(fnames), 1);
cv = zeros(length(fnames), 1);
num_cells = zeros(length(fnames), 1);

for i = 1:length(fnames)
    fn = fnames{i};
    fname_path = [data_path filesep fn];
    data = readmatrix(fname_path);
    mean_freqs = data(:,3);
    mean_freqs = mean_freqs((mean_freqs > min_cutoff) & ...
        (mean_freqs < max_cutoff));

    fh = figure; 
    cal_factor = 1.287418; % Hz/pg
    buoy_mass = mean_freqs / cal_factor;
    histogram(buoy_mass, 60)
    title(['Day ' fn(17) ', Sample ' fn(11:12)])
    xlabel('Buoyant Mass (pg)')
    ylabel('Count')
    xlim([20,180])
    saveas(fh, ['results\fig\' fn(1:17) '.jpg'])

    day{i} = fn(17);
    sample{i} = fn(11:12);
    mean_bm(i) = mean(buoy_mass);
    cv(i) = std(buoy_mass) / mean(buoy_mass);
    num_cells(i) = length(buoy_mass);
end

% Write summary file
summary_tab = table(day, sample, mean_bm, cv, num_cells);
writetable(summary_tab, 'results\summary_file\summary.csv')
