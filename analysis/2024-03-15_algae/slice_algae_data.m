close all;
addpath(genpath("..\..\helpers"));

data_list = ls('data', true);

data_list_part = ls('data', false);

labs = cellfun(@(x) reg_pars(x), data_list,'UniformOutput',false);


disp('--------------------------')
f1 = figure;
low_mt = 8;
high_mt = 150;
for i = 1:2
    disp(data_list{i})
    tab = readtable(data_list{i});
    tab = tab(tab.mass_pg < high_mt & tab.mass_pg > low_mt, :);
    add_swarmchart(f1, labs(i), tab.mass_pg)
    writetable(tab, fullfile('data_clean', data_list_part{i}))
end
title('CCMP222 03/15/24'); ylabel('Buoyant mass (pg)')
saveas(f1, 'fig\ccmp222_bm_swarms.jpg')

disp('--------------------------')
f2 = figure;
low_mt = 6;
high_mt = 50;
for i = 3:6
    disp(data_list{i})
    tab = readtable(data_list{i});
    tab = tab(tab.mass_pg < high_mt & tab.mass_pg > low_mt, :);
    % figure; histogram(tab.mass_pg, 150)
    add_swarmchart(f2, labs(i), tab.mass_pg)
    writetable(tab, fullfile('data_clean', data_list_part{i}))
end
title('CCMP362 03/15/24'); ylabel('Buoyant mass (pg)')
saveas(f2, 'fig\ccmp362_bm_swarms.jpg')

disp('--------------------------')
f3 = figure;
low_mt = 30;
high_mt = 200;
for i = 7:10
    disp(data_list{i})
    tab = readtable(data_list{i});
    tab = tab(tab.mass_pg < high_mt & tab.mass_pg > low_mt, :);
    % figure; histogram(tab.mass_pg, 150)
    add_swarmchart(f3, labs(i), tab.mass_pg)
    writetable(tab, fullfile('data_clean', data_list_part{i}))
end
title('CCMP908 03/15/24'); ylabel('Buoyant mass (pg)')
saveas(f3, 'fig\ccmp908_bm_swarms.jpg')


function ret = reg_pars(str_)
    st = regexp(str_, '\d{3}_(?<cap>[A-Za-z0-9_-\s]*).csv$', 'names');
    ret = regexprep(st.cap, '_', ' ');
end