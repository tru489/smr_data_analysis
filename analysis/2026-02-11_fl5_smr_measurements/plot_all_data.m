close all;
addpath(genpath("..\..\helpers"));

%% No drug timeseries: 2/7
act_tseries_nodrug_path = "C:\Users\Blue\MIT Dropbox\Thomas Usherwood\Shared FL5 data-T&T\Processed data\2026-02-05to10_FL5 cell volume perturbation experiments\summary_stats\02-05-2026_FL5-GFP-Gem_70h_starvation_activation_stats.csv";
act_tseries_nodrug_tab = readtable(act_tseries_nodrug_path, 'RowNamesColumn', 1, 'VariableNamingRule', 'preserve');

% With IL3
has_il3_vols = act_tseries_nodrug_tab{"Mean", logical(act_tseries_nodrug_tab{"Has_il3", :})};
has_il3_counts = act_tseries_nodrug_tab{"SampleSize", logical(act_tseries_nodrug_tab{"Has_il3", :})};
has_il3_time = act_tseries_nodrug_tab{"Time_min", logical(act_tseries_nodrug_tab{"Has_il3", :})};

% Without IL3
no_il3_vols = act_tseries_nodrug_tab{"Mean", ~act_tseries_nodrug_tab{"Has_il3", :}};
no_il3_counts = act_tseries_nodrug_tab{"SampleSize", ~act_tseries_nodrug_tab{"Has_il3", :}};
no_il3_time = act_tseries_nodrug_tab{"Time_min", ~act_tseries_nodrug_tab{"Has_il3", :}};

fh_vols_timecourse = figure; hold on;
scatter(has_il3_time/60, has_il3_vols, 'red', DisplayName='With IL3')
scatter(no_il3_time/60, no_il3_vols, 'blue', DisplayName='Without IL3')
xlabel('Time (h)', FontSize=14)
ylabel('Volume (fL)', FontSize=14)
ax=gca; ax.FontSize=13;
legend(Location='northeast')
saveas(fh_vols_timecourse, 'figs_processed\205_timecourse_vols.jpg')

fh_count_timecourse = figure; hold on;
% Normalized to 15min no il3
index_counts = get_index_count(act_tseries_nodrug_tab);

scatter(has_il3_time/60, has_il3_counts/index_counts, 'red', DisplayName='With IL3')
scatter(no_il3_time/60, no_il3_counts/index_counts, 'blue', DisplayName='Without IL3')
xlabel('Time (h)', FontSize=14)
ylabel('Normalized count', FontSize=14)
ax=gca; ax.FontSize=13;
legend(Location='northeast')
saveas(fh_count_timecourse, 'figs_processed\205_timecourse_counts.jpg')

tab_result = table();
tab_result.times_h = [has_il3_time'/60 ; no_il3_time'/60];
tab_result.volumes_fl = [has_il3_vols'; no_il3_vols'];
tab_result.counts = [has_il3_counts'; no_il3_counts'];
tab_result.counts_normalized = [has_il3_counts'; no_il3_counts'] / index_counts;
tab_result.labels = [repmat("with_il3",length(has_il3_vols),1); repmat("without_il3",length(no_il3_vols),1)];
writetable(tab_result, "processed_data\02-05-2026_FL5-GFP-Gem_70h_starvation_activation_processed.csv")

%% 
path_207 = "C:\Users\Blue\MIT Dropbox\Thomas Usherwood\Shared FL5 data-T&T\Processed data\2026-02-05to10_FL5 cell volume perturbation experiments\summary_stats\02-07-2026_FL5-GFP-Gem_70h_IL3_starvation_stats.csv";
path_207_conditions = "C:\Users\Blue\MIT Dropbox\Thomas Usherwood\Shared FL5 data-T&T\Processed data\2026-02-05to10_FL5 cell volume perturbation experiments\summary_stats\02-07-2026_FL5-GFP-Gem_70h_IL3_starvation_conditions.csv";
[fh_vol_timecourse, fh_count_timecourse ] = create_plots_simple_slice(path_207, path_207_conditions, "0207");
saveas(fh_vol_timecourse, 'figs_processed\207_timecourse_vols.jpg')
saveas(fh_count_timecourse, 'figs_processed\207_timecourse_counts.jpg')

path_209 = "C:\Users\Blue\MIT Dropbox\Thomas Usherwood\Shared FL5 data-T&T\Processed data\2026-02-05to10_FL5 cell volume perturbation experiments\summary_stats\02-09-2026_Fl5-GFP-Gem_activation_starvation_dynamics_stats.csv";
path_209_conditions = "C:\Users\Blue\MIT Dropbox\Thomas Usherwood\Shared FL5 data-T&T\Processed data\2026-02-05to10_FL5 cell volume perturbation experiments\summary_stats\02-09-2026_Fl5-GFP-Gem_activation_starvation_dynamics_conditions.csv";
[fh_vol_timecourse, fh_count_timecourse ] = create_plots_simple_slice(path_209, path_209_conditions, "0209_starvation_dynamics");
saveas(fh_vol_timecourse, 'figs_processed\209_timecourse_vols.jpg')
saveas(fh_count_timecourse, 'figs_processed\209_timecourse_counts.jpg')

%% Function
function index_counts = get_index_count(tab)
index_counts = tab{"SampleSize", logical(tab{"IndexCols", :})};
index_counts = mean(index_counts);
end

function [fh_vol_timecourse, fh_count_timecourse ] = create_plots_simple_slice(tab_path, tab_path_conditions, label_fname)
tab = readtable(tab_path, 'RowNamesColumn', 1, 'VariableNamingRule', 'preserve');
tab_conditions = readtable(tab_path_conditions, 'RowNamesColumn', 1, 'VariableNamingRule', 'preserve');
all_conditions = cellfun(@(x) string(x), tab_conditions{'Condition', :});
unique_labels = unique(all_conditions);

index_count = get_index_count(tab);

fh_vol_timecourse = figure(Position=[1017         458         798         420]); hold on;
fh_count_timecourse = figure(Position=[1017         458         798         420]); hold on;

times_aggr = [];
vols_aggr = [];
counts_aggr = [];
counts_nml_aggr = [];
labels_aggr = [];

colors = ["r", "b", "g", "k"];
for i = 1:length(unique_labels)
    label_temp = unique_labels(i);
    mask = all_conditions == label_temp;
    vols = tab{"Mean", mask};
    counts = tab{"SampleSize", mask};
    time = tab{"Time_h", mask};
    
    figure(fh_vol_timecourse)
    scatter(time, vols, colors(i), DisplayName=label_temp)

    figure(fh_count_timecourse)
    scatter(time, counts / index_count, colors(i), DisplayName=label_temp)

    times_aggr = [times_aggr; time'];
    vols_aggr = [vols_aggr; vols'];
    counts_aggr = [counts_aggr; counts'];
    counts_nml_aggr = [counts_nml_aggr; counts' / index_count];
    labels_aggr = [labels_aggr; repmat(label_temp, length(time),1)];
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

tab_result = table();
tab_result.times_h = times_aggr;
tab_result.volumes_fl = vols_aggr;
tab_result.counts = counts_aggr;
tab_result.counts_normalized = counts_nml_aggr;
tab_result.labels = labels_aggr;
writetable(tab_result, "processed_data\" + label_fname + ".csv")

end