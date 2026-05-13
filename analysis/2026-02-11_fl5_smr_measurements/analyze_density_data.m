close all;
addpath(genpath("..\..\helpers"));

%% Get fluid density
sample_dataset_1 = readtable("A:\thomasu\raw_data\2026-02-10 - FL5 +-quiescence timepoints contd\fl5_starved_71+25h_rep1\20260211.120602_mass_results\2026-02-10 - FL5 +-quiescence timepoints contd_fl5_starved_71+25h_rep1.csv");
sample_dataset_2 = readtable("A:\thomasu\raw_data\2026-02-10 - FL5 +-quiescence timepoints contd\fl5_starved_71+25h_rep2\20260211.120624_mass_results\2026-02-10 - FL5 +-quiescence timepoints contd_fl5_starved_71+25h_rep2.csv");

avg_baseline = mean([sample_dataset_1.avg_baseline;sample_dataset_2.avg_baseline]);

fluid_density = 1;
slope = -184141.88441731408;
intc = 1.2382707462637972E+6;
ref_freq = 1052905;
fl_density = (ref_freq - avg_baseline - intc) / slope;

%% Edit pairing spreadsheet
% pairing_path = 'data\density_pairing.xlsx';
% pair_tab = readtable(pairing_path);
% pair_tab.bm_path = cellfun(@exit_bm_path, pair_tab.bm_path, UniformOutput=false);
% writetable(pair_tab, 'data\density_pairing_mod.csv')

%% Create plots
bm_means_tab = readtable('data\means_tab.csv', 'RowNamesColumn', 1, 'VariableNamingRule', 'preserve', 'Delimiter', ',');
pairing_tab = readtable('data\density_pairing_mod.csv', Delimiter=',');
timecourse_cc_tab = readtable("C:\Users\Blue\MIT Dropbox\Thomas Usherwood\Shared FL5 data-T&T\Processed data\2026-02-05to10_FL5 cell volume perturbation experiments\summary_stats\2026-02-09_FL5_timecourse_stats.csv", 'RowNamesColumn', 1, 'VariableNamingRule', 'preserve');

volumes = zeros(height(pairing_tab), 1);
bms = zeros(height(pairing_tab), 1);
densities = zeros(height(pairing_tab), 1);
coulter_names = [];

times = pairing_tab.time_min;
labels = string(pairing_tab.label);
for i = 1:height(pairing_tab)
    bm_id = pairing_tab{i,'bm_path'};
    coulter_id = pairing_tab{i,'coulter_id'};
    bm_mean = bm_means_tab{bm_id, 'means'};
    bms(i) = bm_mean;
    vol_mean = timecourse_cc_tab{'Mean', coulter_id};
    volumes(i) = vol_mean;
    densities(i) = bm_mean / vol_mean + fl_density;
    coulter_names = [coulter_names; coulter_id];
end

colors = [...
    216, 27, 96;...
    30, 136, 229; ...
    255, 193, 7;...
    0, 77, 64;...
    112, 207, 7;...
    134, 88, 172;...
    194, 160, 128] / 255;

fig_pos = [1017         458         798         420]; 
fh_density_timecourse = figure(Position=fig_pos); hold on;
fh_bm_timecourse = figure(Position=fig_pos); hold on;
fh_vol_timecourse = figure(Position=fig_pos); hold on;
unique_labels = unique(labels);
for i = 1:length(unique_labels)
    curr_label = unique_labels(i);
    mask = labels == curr_label;
    curr_densities = densities(mask);
    curr_bms = bms(mask);
    curr_vols = volumes(mask);
    curr_times = times(mask);

    disp_label = replace(curr_label, '_', '\_');

    figure(fh_density_timecourse)
    scatter(curr_times/60, curr_densities, [], colors(i, :), DisplayName=disp_label)

    figure(fh_bm_timecourse)
    scatter(curr_times/60, curr_bms, [], colors(i, :), DisplayName=disp_label)

    figure(fh_vol_timecourse)
    scatter(curr_times/60, curr_vols, [], colors(i, :), DisplayName=disp_label)
end
figure(fh_density_timecourse)
xlabel('Time (h)', FontSize=14)
ylabel('Density (g/cm^3)', FontSize=14)
ax=gca; ax.FontSize=13;
legend(Location='eastoutside')
saveas(fh_density_timecourse, 'figs_processed\density_timecourse.jpg')

figure(fh_bm_timecourse)
xlabel('Time (h)', FontSize=14)
ylabel('Buoyant mass (pg)', FontSize=14)
ax=gca; ax.FontSize=13;
legend(Location='eastoutside')
saveas(fh_bm_timecourse, 'figs_processed\bm_timecourse.jpg')

figure(fh_vol_timecourse)
xlabel('Time (h)', FontSize=14)
ylabel('Volume (fL)', FontSize=14)
ax=gca; ax.FontSize=13;
legend(Location='eastoutside')
saveas(fh_vol_timecourse, 'figs_processed\vol_timecourse.jpg')

res_table = table();
res_table.time_h = times/60;
res_table.buoy_mass_pg = bms;
res_table.volumes_fl = volumes;
res_table.density_gcm3 = densities;
res_table.labels_for_plotting = labels;
res_table.coulter_names = coulter_names;
writetable(res_table, 'processed_data\thomas_0209_density_timecourse.csv')

%% Functions
function name = exit_bm_path(path_str)
    path_str = path_str(2:end-1);
    [~, name, ~] = fileparts(path_str);
    name = name(14:end);
end
