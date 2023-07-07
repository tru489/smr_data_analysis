close all;
fig_path = "A:\thomasu\processed_data\2023-06-26to07_03_monocytes\fig";

dir_path = "A:\thomasu\processed_data\2023-06-26to07_03_monocytes" + ...
    "\mass_csv_thomas";
files = dir(dir_path);
fnames = {files(~[files.isdir]).name};
fnames = fnames(~ismember(fnames ,{'.','..'}));
fnames = sort(fnames);

titles = {"05-18-21 No Phagocytosis, Day 0", ...
    "05-18-21 No Phagocytosis, Day 2",...
    "10-13-21 No Phagocytosis, Day 0", ...
    "10-13-21 No Phagocytosis, Day 1", ...
    "10-13-21 No Phagocytosis, Day 2",...
    "10-13-21 Post Phagocytosis, Day 1",...
    "10-13-21 Post Phagocytosis, Day 2"};

max_mass = 150; % pg
min_mass = 15; % pg

for i=1:length(fnames)
    p = dir_path + "\" + fnames{i};
    data = readmatrix(p);
    mass = data(:,18);
    slice_mask = (mass < max_mass) & (mass > min_mass);
    data_slice = mass(slice_mask);
    
    fh = figure;
    h = histogram(data_slice);
    h.BinWidth = 3;
    xlabel('Mass (pg)', 'FontSize', 12)
    ylabel('Count', 'FontSize', 12)
    t = titles{i};
    title(t, 'FontSize', 12)
    xlim([min_mass max_mass])

    [pth, fn, ext] = fileparts(p);
    saveas(fh, fig_path + "\" + fn + ".jpg")
    % fprintf(t + ": %f\n", mean(data_slice));
end