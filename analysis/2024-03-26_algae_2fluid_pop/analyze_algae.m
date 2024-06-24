close all;
addpath(genpath("..\..\helpers"));

%% Options
slice_h2o = 1;
slice_d2o = 1;
plot_swarms = 1;

%% Data slicing
data_pths = ls('data'); data_pths_short = ls('data', false);

h2o_paths = data_pths(contains(data_pths_short, "h2o"));
h2o_paths_short = data_pths_short(contains(data_pths_short, "h2o"));

d2o_paths = data_pths(contains(data_pths_short, "d2o"));
d2o_paths_short = data_pths_short(contains(data_pths_short, "d2o"));

% Slice h2o files
if slice_h2o
    h2o_slice_min = 5;
    h2o_slice_max = 180;
    for i = 1:length(h2o_paths)
        tab = readtable(h2o_paths{i});
        tab = tab(tab.mass_pg < h2o_slice_max & tab.mass_pg > h2o_slice_min, :);
        % figure; histogram(tab.mass_pg, 150); title(regexprep(h2o_paths_short{i}, '_', '\\_'))
        writetable(tab, regexprep(h2o_paths{i}, 'data', 'data_sliced'))
    end
end

% Slice d2o files
if slice_d2o
    d2o_slice_min = 0;
    d2o_slice_max = 160;
    for i = 1:length(d2o_paths)
        tab = readtable(d2o_paths{i});
        tab = tab(tab.mass_pg < d2o_slice_max & tab.mass_pg > d2o_slice_min, :);
        % figure; histogram(tab.mass_pg, 150); title(regexprep(d2o_paths_short{i}, '_', '\\_'))
        writetable(tab, regexprep(d2o_paths{i}, 'data', 'data_sliced'))
    end
end

%% Load sliced data
data_pths = ls('data_sliced'); data_pths_short = ls('data_sliced', false);

h2o_paths = data_pths(contains(data_pths_short, "h2o"));
h2o_paths_short = data_pths_short(contains(data_pths_short, "h2o"));

d2o_paths = data_pths(contains(data_pths_short, "d2o"));
d2o_paths_short = data_pths_short(contains(data_pths_short, "d2o"));

%% Plot swarms
if plot_swarms
    % Swarmcharts
    fh_swrm_h2o = figure(Visible='off');
    for i = 1:length(h2o_paths)
        tab = readtable(h2o_paths{i});
        if i ~= 4
            label_ = regexp(h2o_paths_short{i}, '222[a-z0-9\-_]*2o', 'match'); 
        else
            label_ = regexp(h2o_paths_short{i}, '222[a-z0-9\-_]*2o_rep', 'match'); 
        end
        label_ = label_{1};
        label_ = regexprep(label_, '_', '\\_');
        add_swarmchart(fh_swrm_h2o, label_, tab.mass_pg)
    end
    ylabel('Buoyant mass (pg)'); title('BMs in H2O')
    saveas(fh_swrm_h2o, 'fig\h2o_bm_swarm.jpg')
    
    fh_swrm_d2o = figure(Visible='off');
    for i = 1:length(d2o_paths)
        tab = readtable(d2o_paths{i});
        if i ~= 4
            label_ = regexp(d2o_paths_short{i}, '222[a-z0-9\-_]*2o', 'match'); 
        else
            label_ = regexp(d2o_paths_short{i}, '222[a-z0-9\-_]*2o_rep', 'match'); 
        end
        label_ = label_{1};
        label_ = regexprep(label_, '_', '\\_');
        add_swarmchart(fh_swrm_d2o, label_, tab.mass_pg)
    end
    ylabel('Buoyant mass (pg)'); title('BMs in D2O')
    saveas(fh_swrm_d2o, 'fig\d2o_bm_swarm.jpg')
end

%% Dry calculations
ref_freq_h2o = 1155670;
ref_freq_d2o = 1137670;

cal_path = "A:\thomasu\raw_data\2024-03-04\nacl_baseline_cal_not_rescaled\rescaled\20240304_density_baseline_calibration.json";

cal_st = get_json_struct('', cal_path);
slp = cal_st.slope; intr = cal_st.intercept;

pair_labels = ["-n", "-p", "high", "high replicate", "low"]';

final_tab = table();
final_tab.row_labels = pair_labels;

avg_bl_dens_h2o = zeros(5,1); avg_bm_h2o = zeros(5,1);
for i = 1:length(h2o_paths)
    tab = readtable(h2o_paths{i}); 
    avg_bl_dens_h2o(i) = (ref_freq_h2o - mean(tab.avg_baseline) - intr) / slp;
    avg_bm_h2o(i) = mean(tab.mass_pg);
    % figure; scatter(1:length(tab.avg_baseline), tab.avg_baseline)
end
final_tab.avg_fluid_density_h2o_gcm3 = avg_bl_dens_h2o;
final_tab.avg_buoy_mass_h2o_pg = avg_bm_h2o;

avg_bl_dens_d2o = zeros(5,1); avg_bm_d2o = zeros(5,1);
for i = 1:length(d2o_paths)
    tab = readtable(d2o_paths{i});
    avg_bl_dens_d2o(i) = (ref_freq_d2o - mean(tab.avg_baseline) - intr) / slp;
    avg_bm_d2o(i) = mean(tab.mass_pg);
    % figure; scatter(1:length(tab.avg_baseline), tab.avg_baseline)
end
final_tab.avg_fluid_density_d2o_gcm3 = avg_bl_dens_d2o;
final_tab.avg_buoy_mass_d2o_pg = avg_bm_d2o;

rho_f1 = avg_bl_dens_h2o; rho_f2 = avg_bl_dens_d2o;
df1 = avg_bm_h2o; df2 = avg_bm_d2o;
final_tab.dry_density_gcm3 = (rho_f2 .* df1 - rho_f1 .* df2) ./ (df1 - df2);
final_tab.dry_vol_fl = (df1 - df2) ./ (rho_f2 - rho_f1);
final_tab.dry_mass_pg = final_tab.dry_density_gcm3 .* final_tab.dry_vol_fl;
writetable(final_tab, 'data_sliced\dry_data.csv')

% t1 = readtable("C:\thomasu\smr_data_analysis\analysis\2024-03-26_algae_2fluid_pop\data_sliced\2024-03-26_222_low_h2o.csv");
% t2 = readtable("C:\thomasu\smr_data_analysis\analysis\2024-03-26_algae_2fluid_pop\data_sliced\2024-03-26_222_low_d2o.csv");
% 
% figure; scatter(1:length(t1.mass_pg),t1.mass_pg)
% figure; scatter(1:length(t2.mass_pg),t2.mass_pg)
