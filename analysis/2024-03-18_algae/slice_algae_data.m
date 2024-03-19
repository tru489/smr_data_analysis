close all;
addpath(genpath("..\..\helpers"));

data_list = ls('data', true);

data_list_part = ls('data', false);

labs = cellfun(@(x) reg_pars(x), data_list,'UniformOutput',false);


disp('--------------------------')
f1 = figure;
low_mt = 24;
high_mt = 220;
for i = 1:length(data_list)
    disp(data_list{i})
    tab = readtable(data_list{i});
    tab = tab(tab.mass_pg < high_mt & tab.mass_pg > low_mt, :);
    % figure; histogram(tab.mass_pg, 150)
    add_swarmchart(f1, labs(i), tab.mass_pg)
    writetable(tab, fullfile('data_clean', data_list_part{i}))
end
title('908 03/18/24'); ylabel('Buoyant mass (pg)')
saveas(f1, 'fig\908_bm_swarms.jpg')


function ret = reg_pars(str_)
    st = regexp(str_, '\d{3}_(?<cap>[A-Za-z0-9_-\s]*).csv$', 'names');
    ret = regexprep(st.cap, '_', ' ');
end