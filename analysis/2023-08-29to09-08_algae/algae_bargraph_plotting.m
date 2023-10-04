close all;
data_path = 'A:\thomasu\processed_data\2023-08-29to09-08_algae';
save_path_data = "C:\Users\Blue\Desktop\gated\data";
save_path_fig = "C:\Users\Blue\Desktop\gated\fig";

min_cutoff = 25;
max_cutoff = 225;

data = dir(data_path);
fnames = {data.name};
fnames = data(~ismember(fnames ,{'.','..'}));
fnames = {fnames.name};

for i = 1:length(fnames)
    fprintf('File %d of %d...\n', i, length(fnames));
    fn = fnames{i};
    fname_path = [data_path filesep fn];
    
    data_tab = readtable(fname_path);
    mass_pg = data_tab.mass_pg;

    gate_mask = (mass_pg > min_cutoff) & (mass_pg < max_cutoff);
    masses_gated = mass_pg(gate_mask);

    writetable(data_tab(gate_mask, :), ...
        fullfile(save_path_data, fn(1:end-4) + ".csv"));

    fh = figure; 
    histogram(masses_gated, 80)
    title_ = strrep(fn, '_', '\_');
    title(title_(1:end-4), 'FontSize', 14)
    xlabel('Buoyant Mass (pg)', 'FontSize', 14)
    ylabel('Count', 'FontSize', 14)
    saveas(fh, fullfile(save_path_fig, fn(1:end-4) + ".jpg"))
end
