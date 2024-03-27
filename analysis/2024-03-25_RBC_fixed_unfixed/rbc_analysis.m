close all;
addpath(genpath("..\..\helpers"));

pths = ls('.\data'); pths_short = ls('.\data');

labs = cell(size(pths)); sliced_arrs = cell(size(pths)); sliced_arrs_mtotal = cell(size(pths));
low_cut = 3;
high_cut = 14;
for i = 1:length(pths)
    if i <= 5
        vol = 85.0;
    else
        vol = 82.2;
    end

    reg = regexp(pths_short{i}, "^\.\\data\\\d{4}-\d{2}-\d{2}_[a-z]*_[a-z]*_(?<n>[a-z_]*).csv$", "names");
    if reg.n == 'pbs'
        dens_fl = 1.0056;
    elseif reg.n == 'man'
        dens_fl = 1.0367;
    else
        dens_fl = 1.0116;
    end

    reg = regexp(pths_short{i}, "^\.\\data\\\d{4}-\d{2}-\d{2}_(?<n>[a-z_]*).csv$", "names");
    ret = regexprep(reg.n, '_', ' ');
    labs{i} = ret;
    tab = readtable(pths{i});
    bm = tab.mass_pg;
    tab_sl = tab(bm > low_cut & bm < high_cut, :);
    bm = tab_sl.mass_pg;
    sliced_arrs{i} = bm;
    sliced_arrs_mtotal{i} = bm + vol * dens_fl;
    % figure; histogram(bm, 150)
end
disp(labs)
labs = cellfun(@(x) string(x), labs);
d = dictionary(labs, sliced_arrs); d_total = dictionary(labs, sliced_arrs_mtotal);

fh_sw1 = figure;
colors_ = ["#EDB120", "blue", "red", "#EDB120", "blue", "red"];
key_arr = [...
    "aa unfixed pbs", "aa unfixed man", "aa unfixed sms", ...
    "ss unfixed pbs", "ss unfixed man", "ss unfixed sms"];
make_swarm(fh_sw1, d, key_arr, colors_)
xline(3.5, LineWidth=2); ylabel('Buoyant mass (pg)')
saveas(fh_sw1, 'fig\fig1.jpg')

fh_sw1_tot = figure;
colors_ = ["#EDB120", "blue", "red", "#EDB120", "blue", "red"];
key_arr = [...
    "aa unfixed pbs", "aa unfixed man", "aa unfixed sms", ...
    "ss unfixed pbs", "ss unfixed man", "ss unfixed sms"];
make_swarm(fh_sw1_tot, d_total, key_arr, colors_)
xline(3.5, LineWidth=2); ylabel('Total mass (pg)')
saveas(fh_sw1_tot, 'fig\fig1_total.jpg')

fh_bar1_tot = figure; hold on;
colors_ = ["blue", "red", "blue", "red"];
key_arr = [...
    "aa unfixed man", "aa unfixed sms", ...
    "ss unfixed man", "ss unfixed sms"];
make_bar(fh_bar1_tot, d_total, key_arr, colors_)
xline(2.5, LineWidth=2); ylabel('Percent change from PBS control')
saveas(fh_bar1_tot, 'fig\fig1_bar.jpg')

% -----------------------------------------------------------------

fh_sw2 = figure;
colors_ = ["#EDB120", "blue", "red", "#EDB120", "blue", "red"];
key_arr = [...
    "aa unfixed pbs", "aa fixed man", "aa fixed sms", ...
    "ss unfixed pbs", "ss fixed man", "ss fixed sms"];
make_swarm(fh_sw2, d, key_arr, colors_)
xline(3.5, LineWidth=2); ylabel('Buoyant mass (pg)')
saveas(fh_sw2, 'fig\fig2.jpg')

fh_sw2_total = figure;
colors_ = ["#EDB120", "blue", "red", "#EDB120", "blue", "red"];
key_arr = [...
    "aa unfixed pbs", "aa fixed man", "aa fixed sms", ...
    "ss unfixed pbs", "ss fixed man", "ss fixed sms"];
make_swarm(fh_sw2_total, d_total, key_arr, colors_)
xline(3.5, LineWidth=2); ylabel('Total mass (pg)')
saveas(fh_sw2_total, 'fig\fig2_total.jpg')

fh_bar2_total = figure; hold on;
colors_ = ["blue", "red","blue", "red"];
key_arr = [...
    "aa fixed man", "aa fixed sms", ...
    "ss fixed man", "ss fixed sms"];
make_bar(fh_bar2_total, d_total, key_arr, colors_)
xline(2.5, LineWidth=2); ylabel('Percent change from PBS control')
saveas(fh_bar2_total, 'fig\fig2_bar.jpg')

% -----------------------------------------------------------------

fh_sw3 = figure;
colors_ = ["blue", "blue", "red", "red", "blue", "blue", "red", "red"];
key_arr = [...
    "aa unfixed man", "aa fixed man", "aa unfixed sms", "aa fixed sms",...
    "ss unfixed man", "ss fixed man", "ss unfixed sms", "ss fixed sms"];
make_swarm(fh_sw3, d, key_arr, colors_)
xline([2.5 4.5 6.5], LineWidth=2); ylabel('Buoyant mass (pg)')
saveas(fh_sw3, 'fig\fig3.jpg')

fh_sw3_total = figure;
colors_ = ["blue", "blue", "red", "red", "blue", "blue", "red", "red"];
key_arr = [...
    "aa unfixed man", "aa fixed man", "aa unfixed sms", "aa fixed sms",...
    "ss unfixed man", "ss fixed man", "ss unfixed sms", "ss fixed sms"];
make_swarm(fh_sw3_total, d_total, key_arr, colors_)
xline([2.5 4.5 6.5], LineWidth=2); ylabel('Total mass (pg)')
saveas(fh_sw3_total, 'fig\fig3_total.jpg')

fh_bar3_total = figure; hold on;
colors_ = ["blue", "blue", "red", "red", "blue", "blue", "red", "red"];
key_arr = [...
    "aa unfixed man", "aa fixed man", "aa unfixed sms", "aa fixed sms",...
    "ss unfixed man", "ss fixed man", "ss unfixed sms", "ss fixed sms"];
make_bar(fh_bar3_total, d_total, key_arr, colors_)
xline([2.5 4.5 6.5], LineWidth=2); ylabel('Percent change from PBS control')
saveas(fh_bar3_total, 'fig\fig3_bar.jpg')

function make_swarm(fh, d, keys, sw_color)
    d_cell = d(keys);
    for i = 1:length(d_cell)
        label_ = regexprep(keys(i), 'aa', 'AA');
        label_ = regexprep(label_, 'ss', 'SS');
        label_ = regexprep(label_, 'man', 'mannitol');
        label_ = regexprep(label_, 'sms', 'SMS');
        label_ = regexprep(label_, 'pbs', 'PBS');
        add_swarmchart(fh, label_, d_cell{i}, sw_color(i), 'green')
    end
end

function make_bar(fh, d, keys, color)
    figure(fh)
    d_cell = d(keys);
    for i = 1:length(d_cell)
        label_ = keys(i);
        lab_char = char(label_);
        if lab_char(1:2) == 'ss'
            label_ = regexprep(keys(i), 'aa', 'AA');
            label_ = regexprep(label_, 'ss', 'SS');
            label_ = regexprep(label_, 'man', 'mannitol');
            label_ = regexprep(label_, 'sms', 'SMS');
            label_ = regexprep(label_, 'pbs', 'PBS');

            pbs_ctrl = d('ss unfixed pbs');
            mass_tot = (mean(d_cell{i} - mean(pbs_ctrl{1})) / mean(pbs_ctrl{1})) * 100;
        else
            label_ = regexprep(keys(i), 'aa', 'AA');
            label_ = regexprep(label_, 'ss', 'SS');
            label_ = regexprep(label_, 'man', 'mannitol');
            label_ = regexprep(label_, 'sms', 'SMS');
            label_ = regexprep(label_, 'pbs', 'PBS');

            pbs_ctrl = d('aa unfixed pbs');
            mass_tot = (mean(d_cell{i}) - mean(pbs_ctrl{1})) / mean(pbs_ctrl{1}) * 100;
        end
        s = bar(categorical(label_), mass_tot, FaceColor=color(i));
    end
end