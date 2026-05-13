close all;
addpath(genpath("..\..\helpers"));

means_table = table();
labels_ = [];
means_ = [];

data_path_209 = "A:\thomasu\raw_data\2026-02-09 - FL5 +-quiescence timepoints\fl5_samples\bm_csv_aggr";
ls_path_209 = ls(data_path_209);
ls_path_209 = ls_path_209(12:22);
fh_209 = figure(Position=[1921          41        1920         963]);
t=tiledlayout(3,4);
for i = 1:length(ls_path_209)
    % subplot(3,4,i);
    nexttile;
    title(ls_path_209{i})
    tab = readtable(ls_path_209{i});
    histogram(tab.mass_pg, 150)
    [~,name,~] = fileparts(ls_path_209{i});
    name = name(14:end);
    labels_ = [labels_; string(name)];
    name = replace(name, '_', '\_');
    title(name)
    mask = tab.mass_pg < 90 & tab.mass_pg > 12;
    means_ = [means_; mean(tab.mass_pg(mask))];
end
title(t, '2026-02-09 samples')
xlabel(t, 'Buoyant mass (pg)')
ylabel(t, 'Count')
t.Title.FontSize = 14; 
t.XLabel.FontSize = 12;
t.YLabel.FontSize = 12;
saveas(fh_209, 'fig\209_samples.jpg')

data_path_210 = "A:\thomasu\raw_data\2026-02-10 - FL5 +-quiescence timepoints contd\bm_csv_aggr";
ls_path_210 = ls(data_path_210);
ls_path_210 = ls_path_210(7:12);
fh_210 = figure(Position=[1921          41        1920         963]);
t=tiledlayout(2,3);
for i = 1:length(ls_path_210)
    % subplot(3,4,i);
    nexttile;
    tab = readtable(ls_path_210{i});
    histogram(tab.mass_pg, 150)
    [~,name,~] = fileparts(ls_path_210{i});
    name = name(14:end);
    labels_ = [labels_; string(name)];

    mask = tab.mass_pg < 90 & tab.mass_pg > 12;
    % means_table.(name) = mean(tab.mass_pg(mask));
    means_ = [means_; mean(tab.mass_pg(mask))];
end
title(t, '2026-02-10 samples')
xlabel(t, 'Buoyant mass (pg)')
ylabel(t, 'Count')
t.Title.FontSize = 14; 
t.XLabel.FontSize = 12;
t.YLabel.FontSize = 12;
saveas(fh_210, 'fig\210_samples.jpg')

means_table.labels = labels_;
means_table.means = means_;

writetable(means_table, 'means_tab.csv')