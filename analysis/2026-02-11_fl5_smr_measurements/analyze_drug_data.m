close all;
addpath(genpath("..\..\helpers"));

%% Concat wnki arrays
% wnki_prolif = "C:\Users\Blue\MIT Dropbox\Thomas Usherwood\Shared FL5 data-T&T\Raw Coulter data\summary_stats\02-05-2026_FL5-GFP-Gem_WNKi_tests_proliferating_stats.csv";
% wnki_quiesc = "C:\Users\Blue\MIT Dropbox\Thomas Usherwood\Shared FL5 data-T&T\Raw Coulter data\summary_stats\02-05-2026_FL5-GFP-Gem_WNKi_tests_quiescent_72h_starved_stats.csv";
% 
% tab_prolif = readtable(wnki_prolif, 'RowNamesColumn', 1, 'VariableNamingRule', 'preserve');
% tab_quiesc = readtable(wnki_quiesc, 'RowNamesColumn', 1, 'VariableNamingRule', 'preserve');
% 
% tab_comb = [tab_prolif, tab_quiesc];
% writetable(tab_comb, 'data\wnki_prolif_nonprolif_comb.csv', 'WriteRowNames', true)

%% Edit labels arr
% tab_labels = readtable('data\wnki_prolif_nonprolif_labels.csv', 'RowNamesColumn', 1, 'VariableNamingRule', 'preserve');
% tab_labels{:,1:67} = num2cell(cellfun(@(x) upper(x) + "_prolif", tab_labels{:,1:67}));
% tab_labels{:,68:end} = num2cell(cellfun(@(x) upper(x) + "_quiesc", tab_labels{:,68:end}));
% writetable(tab_labels, 'data\wnki_prolif_nonprolif_labels_mod.csv', 'WriteRowNames', true)

% tab_labels = readtable('data\wnki_prolif_nonprolif_labels.csv', 'RowNamesColumn', 1, 'VariableNamingRule', 'preserve', 'Delimiter', ',');
% tab_labels{:,1:67} = num2cell(cellfun(@(x) remove_substr(x, '_WITH'), tab_labels{:,1:67}));
% tab_labels{:,68:end} = num2cell(cellfun(@(x) remove_substr(x, '_NO'), tab_labels{:,68:end}));
% writetable(tab_labels, 'data\wnki_prolif_nonprolif_labels.csv', 'WriteRowNames', true, 'Delimiter', ',')

%% Read wnki arrays and create plots
comb_tab = readtable('data\wnki_prolif_nonprolif_comb.csv', 'RowNamesColumn', 1, 'VariableNamingRule', 'preserve');
labels_tab = readtable('data\wnki_prolif_nonprolif_labels_mod.csv', 'RowNamesColumn', 1, 'VariableNamingRule', 'preserve');

preserve_labels = ["DMSO_prolif", "DMSO_quiesc"];
[~, ~] = create_plots_simple_slice(comb_tab, labels_tab, preserve_labels, "drug_timepoints");

stats_path = "C:\Users\Blue\MIT Dropbox\Thomas Usherwood\Shared FL5 data-T&T\Processed data\2026-02-05to10_FL5 cell volume perturbation experiments\summary_stats\2026-02-09_FL5_timecourse_stats.csv";
labels_path = "C:\Users\Blue\MIT Dropbox\Thomas Usherwood\Shared FL5 data-T&T\Processed data\2026-02-05to10_FL5 cell volume perturbation experiments\summary_stats\2026-02-09_FL5_timecourse_labels.csv";

comb_tab = readtable(stats_path, 'RowNamesColumn', 1, 'VariableNamingRule', 'preserve');
labels_tab = readtable(labels_path, 'RowNamesColumn', 1, 'VariableNamingRule', 'preserve');

preserve_labels = ["NoIL371h", "DMSO", "Quiescent", "Proliferating"];
[~, ~] = create_plots_simple_slice(comb_tab, labels_tab, preserve_labels, "activation_timepts");

%% Functions
function index_counts = get_index_count(tab)
index_counts = tab{"SampleSize", logical(tab{"IndexCols", :})};
index_counts = mean(index_counts);
end

function [fh_vol_timecourse, fh_count_timecourse] = create_plots_simple_slice(tab, tab_conditions, preserve_labels, expm_label)
% tab = readtable(tab_path, 'RowNamesColumn', 1, 'VariableNamingRule', 'preserve');
% tab_conditions = readtable(tab_path_conditions, 'RowNamesColumn', 1, 'VariableNamingRule', 'preserve');
all_conditions = cellfun(@(x) string(x), tab_conditions{'Condition', :});
all_concentrations = cellfun(@(x) string(x), tab_conditions{'Concentration', :});

unique_labels = unique(all_conditions);

non_preserve_labels = unique_labels(~ismember(unique_labels, preserve_labels));

index_count = get_index_count(tab);

fig_pos = [1017         458         798         420];

% colors = ["D81B60", "1E88E5", "FFC107", "004D40", "70CF07", "8658AC", "C2A080"];
colors = [...
    216, 27, 96;...
    30, 136, 229; ...
    255, 193, 7;...
    0, 77, 64;...
    112, 207, 7;...
    134, 88, 172;...
    194, 160, 128] / 255;

for i = 1:length(non_preserve_labels)
    label_temp = non_preserve_labels(i);
    mask = all_conditions == label_temp;

    fh_vol_timecourse = figure(Position=fig_pos); hold on;
    fh_count_timecourse = figure(Position=fig_pos); hold on;
    
    times_aggr = [];
    vols_aggr = [];
    counts_aggr = [];
    counts_nml_aggr = [];
    labels_aggr = [];

    for k = 1:length(preserve_labels)
        current_label = preserve_labels(k);
        mask_conc = all_conditions == current_label;
        vols = tab{"Mean", mask_conc};
        counts = tab{"SampleSize", mask_conc};
        time = tab{"Time_h", mask_conc};

        label_display = replace(current_label, '_', '\_');

        figure(fh_vol_timecourse)
        scatter(time, vols, [], colors(k, :), DisplayName=label_display)

        figure(fh_count_timecourse)
        scatter(time, counts / index_count, [], colors(k, :), DisplayName=label_display)

        times_aggr = [time'; times_aggr];
        vols_aggr = [vols'; vols_aggr];
        counts_aggr = [counts'; counts_aggr];
        counts_nml_aggr = [counts' / index_count; counts_nml_aggr];
        labels_aggr = [repmat(label_display, length(time), 1); labels_aggr];
    end
    
    unique_conc = unique(tab_conditions{"Concentration", mask});
    for j = 1:length(unique_conc)
        current_unique_conc = unique_conc(j);
        mask_conc = all_concentrations == current_unique_conc;
        vols = tab{"Mean", mask_conc};
        counts = tab{"SampleSize", mask_conc};
        time = tab{"Time_h", mask_conc};

        label_display = replace(current_unique_conc{1}, '_', '\_');

        figure(fh_vol_timecourse)
        scatter(time, vols, [], colors(j+length(preserve_labels), :), DisplayName=label_display)
    
        figure(fh_count_timecourse)
        scatter(time, counts / index_count, [], colors(j+length(preserve_labels), :), DisplayName=label_display)

        times_aggr = [time'; times_aggr];
        vols_aggr = [vols'; vols_aggr];
        counts_aggr = [counts'; counts_aggr];
        counts_nml_aggr = [counts' / index_count; counts_nml_aggr];
        labels_aggr = [repmat(label_display, length(time), 1); labels_aggr];
    end
    figure(fh_vol_timecourse)
    xlabel('Time (h)', FontSize=14)
    ylabel('Volume (fL)', FontSize=14)
    ax=gca; ax.FontSize=13;
    legend(Location='eastoutside')
    
    figure(fh_count_timecourse)
    xlabel('Time (h)', FontSize=14)
    ylabel('Normalized count', FontSize=14)
    ax=gca; ax.FontSize=13;
    legend(Location='eastoutside')

    saveas(fh_vol_timecourse, "figs_processed\" + expm_label + "_" + label_temp + "_vols.jpg")
    saveas(fh_count_timecourse, "figs_processed\" + expm_label + "_" + label_temp + "_count.jpg")

    tab_result = table();
    tab_result.times_h = times_aggr;
    tab_result.volumes_fl = vols_aggr;
    tab_result.counts = counts_aggr;
    tab_result.counts_normalized = counts_nml_aggr;
    tab_result.labels = labels_aggr;
    writetable(tab_result, "processed_data\" + label_temp + ".csv")
end

end

function retr = remove_substr(x, substr)
    inds = strfind(x, substr);
    first_idx = inds(1);
    char_x = char(x);
    retr = string(char_x(1:first_idx-1));
end