close all;
addpath(genpath("..\..\helpers"));

num_particle_sz = 8;

drive_lett = "A";

color_arr = [...
    [0 0 0]; ...
    [0 0.4470 0.7410]; ...
    [0.8500 0.3250 0.0980];  ...
    [0.9290 0.6940 0.1250];  ...
    [0.4940 0.1840 0.5560];  ...
    [0.4660 0.6740 0.1880];  ...
    [0.3010 0.7450 0.9330];  ...
    [0.6350 0.0780 0.1840]];

%% Load paired data for dff and parameter array
search_path = drive_lett + ":\thomasu\raw_data\2024-06-28\dens_trap_fitting_gridsearch_5-15um\data_paired.mat";
st = load(search_path);
param_arr = st.value_arr;
dff = st.dff;

%% Load cleaned data
search_path = drive_lett + ":\thomasu\raw_data\2024-06-28\dens_trap_fitting_gridsearch_5-15um\data_cleaned.mat";
st = load(search_path);
data_cell = st.compiled_4d;

%% Load replicate 1 of bead trapping for original parameter data
orig_param_tab = readtable("data_processed\rep1_beads_concat.csv");
orig_dv = [orig_param_tab.density_gcm3, orig_param_tab.volume_fl];
orig_dv_bounds = [55, 75; 90 140; 150 200; 220 300; 325 380; 440 540; 800 920; 1580 1760];

%% Load ground truths
gt_dv = readmatrix("data_processed\dv_ground_truth_beads.csv")';
gt_v_stdev = readmatrix("data_processed\vol_stdev_beads.csv");

%% Rank metrics
% Metrics:
% mean_dens_pct_err_abs
% mean_dens_cv
% mean_vol_pct_err_abs
% mean_vol_cv
% 
% mean_dv_slope
% szdep_drift_dens

collect_fn_cell = {...
    @(st) st.mean_dens_pct_err_abs, ...
    @(st) st.mean_dens_cv, ...
    @(st) st.mean_vol_pct_err_abs, ...
    @(st) st.mean_vol_cv, ...
    @(st) abs(st.mean_dv_slope), ...
    @(st) abs(st.szdep_drift_dens)};

% Order of params: fitting_order, node_weight, bl_fit_length, bl_fit_offset
labels = ["Fitting order", "Node weight", "Baseline fit length", "Baseline fit offset"];
metric_labels = ["Density percent error", "Density CV", "Volume percent error", "Volume CV", "Density-volume slope", "Size-dependend drift"];
metric_file_labels = ["dens_pct_err", "dens_cv", "vol_pct_err", "vol_cv", "dv_slope", "szdep_drift"];


num_to_rank = 6;
param_set_idx_arr = cell(length(collect_fn_cell),1);
metric_rank_arr = zeros(numel(data_cell),length(collect_fn_cell));

calc_indiv_rank = 0;

if calc_indiv_rank
for i = 1:length(collect_fn_cell)
    rank_arr = get_ranking_from_dff(dff, data_cell, collect_fn_cell{i});
    metric_rank_arr(:, i) = rank_arr;
    [~, idx] = mink(rank_arr, num_to_rank);
    dff_rank_sl = dff(idx,:); param_set_idx_arr{i} = dff_rank_sl;

    fprintf("Best param set for %s. Original vs optimized\n", metric_file_labels(i))
    for j = 1:num_to_rank
        param_idx_temp = dff_rank_sl(j, :);
        single_st = data_cell{param_idx_temp(1), param_idx_temp(2), param_idx_temp(3), param_idx_temp(4)};

        if j == 1
            fh = figure('Position', [2362         102        1057         786], Visible='off');
            axs = tight_subplot(3,3, 0.07, 0.07, 0.07);
            for k = 1:length(single_st.raw_table_seg)
                tab_seg_temp = single_st.raw_table_seg{k};
                axes(axs(k)); 
                s1 = scatter(tab_seg_temp(:, 2), tab_seg_temp(:, 1), 50, 'r', "filled"); s1.MarkerFaceAlpha = 0.4;
                part_slice = orig_dv(:,2) > orig_dv_bounds(length(single_st.raw_table_seg)+1-k,1) & orig_dv(:,2) < orig_dv_bounds(length(single_st.raw_table_seg)+1-k,2);
                hold on; 
                s2 = scatter(orig_dv(part_slice, 2), orig_dv(part_slice,1), 50, 'b', "filled"); s2.MarkerFaceAlpha = 0.4;
                sel_ind = length(single_st.raw_table_seg)+1-k;
                s = scatter(gt_dv(sel_ind, 2), gt_dv(sel_ind, 1), 80, 'r', '+', LineWidth=3); 
                errorbar(gt_dv(sel_ind, 2), gt_dv(sel_ind, 1), gt_v_stdev(sel_ind), 'horizontal', 'red', LineWidth=1.5)
                errorbar(gt_dv(sel_ind, 2), gt_dv(sel_ind, 1), gt_v_stdev(sel_ind)*3, 'horizontal', 'red', LineWidth=1.2)

                switch i
                    case 1
                        orig_param = abs(mean(orig_dv(part_slice,1)) - gt_dv(sel_ind, 1)) / gt_dv(sel_ind, 1);
                        opt_param = abs(mean(tab_seg_temp(:, 1)) - gt_dv(sel_ind, 1)) / gt_dv(sel_ind, 1);
                    case 2
                        orig_param = std(orig_dv(part_slice,1)) / mean(orig_dv(part_slice,1));
                        opt_param = std(tab_seg_temp(:, 1)) / mean(tab_seg_temp(:, 1));
                    case 3
                        orig_param = abs(mean(orig_dv(part_slice,2)) - gt_dv(sel_ind, 2)) / gt_dv(sel_ind, 2);
                        opt_param = abs(mean(tab_seg_temp(:, 2)) - gt_dv(sel_ind, 2)) / gt_dv(sel_ind, 2);
                    case 4
                        orig_param = std(orig_dv(part_slice,2)) / mean(orig_dv(part_slice,2));
                        opt_param = std(tab_seg_temp(:, 2)) / mean(tab_seg_temp(:, 2));
                    case 5
                        orig_param = 0; opt_param = 0;
                    case 6
                        orig_param = 0; opt_param = 0;
                end
                fprintf('    %.5f | %.5f\n', orig_param, opt_param)
            end
            han = axes(fh,'visible', 'off');
            han.Title.Visible = 'on';
            title(han, "Best param set for " + strrep(metric_file_labels(i), "_", "\_"))
            xlabel(han, 'Dry Volume (fL)'); ylabel(han, 'Dry Density (g/cm3)')
            saveas(fh, "fig\indiv_particles_best_param_rank\" + metric_file_labels(i) + ".jpg")
        end

        fh = figure(Visible="off"); hold on;
        s1 = scatter(orig_dv(:, 2), orig_dv(:, 1), 50, 'b', "filled"); 
        s1.MarkerFaceAlpha = 0.4;
        s2 = scatter(single_st.raw_table(:, 2), single_st.raw_table(:, 1), 50, 'k', "filled"); 
        s2.MarkerFaceAlpha = 0.4;
        s = scatter(gt_dv(:, 2), gt_dv(:, 1), 50, 'r', '+'); 
        xlabel('Volume (fl)'); ylabel('Density (g/cm3)'); title("Rank " + num2str(j) + " | " + strrep(metric_file_labels(i), "_", "\_"))
        saveas(fh, "fig\indiv_metric_rank\" + metric_file_labels(i) + "_rank" + num2str(j) + ".jpg")
    end
end
end

sq_ranks = sum(metric_rank_arr(:,[1,2,4]) .^ 2, 2);
[~, idx] = mink(sq_ranks, num_to_rank);
dff_rank_sl = dff(idx,:);

met_type = 4;

for j = 1:num_to_rank
    param_idx_temp = dff_rank_sl(j, :);
    single_st = data_cell{param_idx_temp(1), param_idx_temp(2), param_idx_temp(3), param_idx_temp(4)};

    if j == 1 || j == 2
        fh = figure('Position', [2362         102        1057         786], Visible='off');
        axs = tight_subplot(3,3, 0.07, 0.07, 0.07);

        fprintf("Best param set. Original vs optimized\n")
        for k = 1:length(single_st.raw_table_seg)
            tab_seg_temp = single_st.raw_table_seg{k};
            axes(axs(k)); 
            s1 = scatter(tab_seg_temp(:, 2), tab_seg_temp(:, 1), 50, 'r', "filled"); s1.MarkerFaceAlpha = 0.4;
            part_slice = orig_dv(:,2) > orig_dv_bounds(length(single_st.raw_table_seg)+1-k,1) & orig_dv(:,2) < orig_dv_bounds(length(single_st.raw_table_seg)+1-k,2);
            
            % hold on; 
            % s2 = scatter(orig_dv(part_slice, 2), orig_dv(part_slice,1), 50, 'b', "filled"); s2.MarkerFaceAlpha = 0.4;
            % s = scatter(gt_dv(length(single_st.raw_table_seg)+1-k, 2), gt_dv(length(single_st.raw_table_seg)+1-k, 1), 50, 'r', '+'); 

            hold on; 
            s2 = scatter(orig_dv(part_slice, 2), orig_dv(part_slice,1), 50, 'b', "filled"); s2.MarkerFaceAlpha = 0.4;
            sel_ind = length(single_st.raw_table_seg)+1-k;
            s = scatter(gt_dv(sel_ind, 2), gt_dv(sel_ind, 1), 80, 'r', '+', LineWidth=3); 
            errorbar(gt_dv(sel_ind, 2), gt_dv(sel_ind, 1), gt_v_stdev(sel_ind), 'horizontal', 'red', LineWidth=1.5)
            errorbar(gt_dv(sel_ind, 2), gt_dv(sel_ind, 1), gt_v_stdev(sel_ind)*3, 'horizontal', 'red', LineWidth=1.2)

            switch met_type
                case 1
                    orig_param = abs(mean(orig_dv(part_slice,1)) - gt_dv(sel_ind, 1)) / gt_dv(sel_ind, 1);
                    opt_param = abs(mean(tab_seg_temp(:, 1)) - gt_dv(sel_ind, 1)) / gt_dv(sel_ind, 1);
                case 2
                    orig_param = std(orig_dv(part_slice,1)) / mean(orig_dv(part_slice,1));
                    opt_param = std(tab_seg_temp(:, 1)) / mean(tab_seg_temp(:, 1));
                case 3
                    orig_param = abs(mean(orig_dv(part_slice,2)) - gt_dv(sel_ind, 2)) / gt_dv(sel_ind, 2);
                    opt_param = abs(mean(tab_seg_temp(:, 2)) - gt_dv(sel_ind, 2)) / gt_dv(sel_ind, 2);
                case 4
                    orig_param = std(orig_dv(part_slice,2)) / mean(orig_dv(part_slice,2));
                    opt_param = std(tab_seg_temp(:, 2)) / mean(tab_seg_temp(:, 2));
                case 5
                    orig_param = 0; opt_param = 0;
                case 6
                    orig_param = 0; opt_param = 0;
            end
            fprintf('    %.5f | %.5f\n', orig_param, opt_param)
        end
        han = axes(fh,'visible', 'off');
        han.Title.Visible = 'on';
        title(han, "Best param set for composite ranking, rank" + num2str(j))
        xlabel(han, 'Dry Volume (fL)'); ylabel(han, 'Dry Density (g/cm3)')
        saveas(fh, "fig\indiv_particles_best_param_rank\composite_ranking_rank_" + num2str(j) + ".jpg")
    end

    fh = figure(Visible="on"); hold on;
    s1 = scatter(orig_dv(:, 2), orig_dv(:, 1), 50, 'b', "filled"); 
    s1.MarkerFaceAlpha = 0.4;
    s2 = scatter(single_st.raw_table(:, 2), single_st.raw_table(:, 1), 50, 'k', "filled"); 
    s2.MarkerFaceAlpha = 0.4;
    s = scatter(gt_dv(:, 2), gt_dv(:, 1), 50, 'r', '+'); 
    xlabel('Volume (fl)'); ylabel('Density (g/cm3)'); title("Rank " + num2str(j))
    saveas(fh, "fig\composite_sq_rank\rank" + num2str(j) + ".jpg")
end




% Write function to vizualize clustering
% figure; hold on;
% s = scatter(orig_dv(:, 2), orig_dv(:, 1), 50, 'b', "filled"); 
% s.MarkerFaceAlpha = 0.4;
% s = scatter(gt_dv(:, 1), gt_dv(:, 2), 50, 'r', '+'); 

%% Helpers
function rank_arr = get_ranking_from_dff(dff, data_cell, metric_fn_hand)
ext_met_arr = zeros(size(dff,1),1);
for i = 1:size(dff, 1)
    dff_sl = dff(i, :);
    sel_data = data_cell{dff_sl(1), dff_sl(2), dff_sl(3), dff_sl(4)};
    ext_met_arr(i) = metric_fn_hand(sel_data);
end
[~, i1] = sort(ext_met_arr);
[~, i2] = sort(i1);
rank_arr = i2;
end