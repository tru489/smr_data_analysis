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
bead_fname = fnames{bead_file_idx};

fn = [data_path filesep bead_fname];
data = readmatrix(fn);
buoy_mass = data(:,3);

% filtered_mass = buoy_mass((buoy_mass > min_cutoff) & ...
%     (buoy_mass < max_cutoff));
filtered_freq = buoy_mass((buoy_mass < 50));
fprintf('Mean frequency difference: %f Hz\n', mean(filtered_freq))

bead_vol = 4/3 * pi * (8.956 / 2)^3 * 10^-12; % cm^3
density_diff = (1.05 - 0.997) * 10^12; % pg/cm^3
fprintf('Bead ground truth buoyant mass: %f pg\n', bead_vol * density_diff)
cal_factor = mean(filtered_freq) / (bead_vol * density_diff); % Hz/pg
fprintf('Calibration factor: %f Hz/pg\n', cal_factor)

figure; 
histogram(buoy_mass, 100)
title(replace('Calibration beads', '_', '\_'))
xlabel('Frequency (Hz)')
ylabel('Count')