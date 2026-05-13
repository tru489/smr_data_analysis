close all;
addpath(genpath("..\..\helpers"));

raw_data_pths = ls('raw_data');

pg_lowerthresh = 40;

name_arr = strings(size(raw_data_pths))';
mean_arr = zeros(size(raw_data_pths))';
median_arr = zeros(size(raw_data_pths))';
std_arr = zeros(size(raw_data_pths))';
cv_arr = zeros(size(raw_data_pths))';
n_arr = zeros(size(raw_data_pths))';
for i = 1:length(raw_data_pths)
    fname = raw_data_pths{i};
    [pre, name, ext] = fileparts(fname);
    tab = readtable(fname);
    fh = figure;
    cal_factor = 0.6; 
    mass_pg = tab.avg_pk_ht_hz*cal_factor;
    mask = mass_pg > pg_lowerthresh;
    mass_pg = mass_pg(mask);
    % mean median std cv n for mass summary table
    histogram(mass_pg, 150)
    xlabel('Mass (pg)')
    ylabel('Count')
    title_ = replace([name(12:end), ' | ', 'cal_factor=0.6pg/hz'], '_', '\_');
    title(title_)
    saveas(fh, ['fig\jpg\' name(12:end) '.jpg'])
    
    new_tab = table();
    new_tab.time_s = tab.peak_time_s(mask);
    new_tab.node_dev_mean = tab.node_dev_mean(mask);
    new_tab.avg_pk_ht_hz = tab.avg_pk_ht_hz(mask);
    new_tab.mass_pg = mass_pg;
    writetable(tab, ['processed_data\', name(12:end), '.csv'])

    name_arr(i) = string(name(12:end));
    mean_arr(i) = mean(mass_pg);
    median_arr(i) = median(mass_pg);
    std_arr(i) = std(mass_pg);
    cv_arr(i) = std(mass_pg) / mean(mass_pg);
    n_arr(i) = length(mass_pg);
end

summary_tab = table();
summary_tab.name_arr = name_arr;
summary_tab.mass_mean = mean_arr;
summary_tab.median_mean = median_arr;
summary_tab.std_mean = std_arr;
summary_tab.cv_mean = cv_arr;
summary_tab.n_mean = n_arr;
writetable(summary_tab, 'processed_data\summary_table.csv')