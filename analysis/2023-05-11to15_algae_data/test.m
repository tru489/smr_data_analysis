close all;
data_path = 'A:\thomasu\processed_data\20230511-15_algae_data';

min_cutoff = 28; % Hz; 21.7490 pg
max_cutoff = 250; % Hz; 194.1871 pg

data = dir(data_path);
fnames = {data.name};
fnames = data(~ismember(fnames ,{'.','..'}));
fnames = {fnames.name};

bead_file_mask = strfind(fnames, 'beads');
bead_file_idx = find(~cellfun(@isempty,bead_file_mask));
fnames(bead_file_idx) = [];

day = cell(length(fnames), 1);
sample = cell(length(fnames), 1);
mean_bm = zeros(length(fnames), 1);
cv = zeros(length(fnames), 1);
num_cells = zeros(length(fnames), 1);

for i = 1:length(fnames)
    cal_factor = 1.287418; % Hz/pg

    fn = fnames{i};
    fname_path = [data_path filesep fn];
    data = readmatrix(fname_path);
    writematrix(data(:,1:17), fname_path)
end