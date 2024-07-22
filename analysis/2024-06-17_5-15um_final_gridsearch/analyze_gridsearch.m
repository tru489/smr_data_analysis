close all;
addpath(genpath("..\..\helpers"));

color_arr = [...
    [0 0 0]; ...
    [0 0.4470 0.7410]; ...
    [0.8500 0.3250 0.0980];  ...
    [0.9290 0.6940 0.1250];  ...
    [0.4940 0.1840 0.5560];  ...
    [0.4660 0.6740 0.1880];  ...
    [0.3010 0.7450 0.9330];  ...
    [0.6350 0.0780 0.1840]];

drive_lett = "A";
search_path = drive_lett + ":\thomasu\raw_data\2024-06-28\dens_trap_fitting_gridsearch_5-15um\data_paired.mat";
save_path = drive_lett + ":\thomasu\raw_data\2024-06-28\dens_trap_fitting_gridsearch_5-15um\data_cleaned.mat";
st = load(search_path);

% Order of params: fitting_order, node_weight, bl_fit_length, bl_fit_offset
param_axes = st.value_arr;
dff = st.dff;
searched = st.compiled_data;
axis_lens = cellfun(@(x) length(x), st.value_arr);

% Get ground truth bead data for kmeans initial conditions
dv_gt = readmatrix('data_processed\dv_ground_truth_beads.csv');
d_gt = dv_gt(1,:);
v_gt = dv_gt(2,:);

% Compile search data into 4d array of structs with relevant values
num_particle_sz = 8;
std_thresh_reject_dens = 3; % # stds from mean from which to reject densities (outlier rejection)
std_thresh_reject_vol = 3; % # stds from mean from which to reject volumes (outlier rejection)
compiled_4d = cell(axis_lens);
for i = 1:size(dff, 1)
    fprintf('%i of %i\n', i, size(dff, 1))
    dff_sl = dff(i,:);
    sear_tab = searched{i};
    comp_str.full_tab_uncur = sear_tab;

    dv_arr = [sear_tab.density_gcm3, sear_tab.volume_fl];
    [idx, ctrs] = kmeans(dv_arr, num_particle_sz, Start=[d_gt', v_gt']);
    [sorted_ctrs, sort_idx] = sort(ctrs(:,2));

    % Write function to vizualize clustering
    % figure; hold on;
    % for k = 1:num_particle_sz
    %     s = scatter(dv_arr(idx==k, 2), dv_arr(idx==k, 1), 50, color_arr(k,:), "filled"); 
    %     s.MarkerFaceAlpha = 0.4;
    %     s = scatter(v_gt, d_gt, 50, 'r', '+'); 
    % end

    met_st.raw_table_seg = {};
    met_st.raw_table = [];
    met_st.dens_mean = [];
    met_st.dens_pct_err = []; met_st.dens_pct_err_abs = [];
    met_st.vol_mean = [];
    met_st.vol_pct_err = []; met_st.vol_pct_err_abs = [];
    met_st.dens_cv = [];
    met_st.vol_cv =  [];
    met_st.dens_std = [];
    met_st.vol_std =  [];
    met_st.dv_slope = [];
    met_st.dv_slope_norm_to_vol = [];
    for j = 1:length(sort_idx)
        clust_idx = sort_idx(j);
        dv_sl = dv_arr(idx==clust_idx, :);
        
        % Slice out outliers
        dens_sl = dv_sl(:,1); vol_sl = dv_sl(:,2);
        dens_std = std(dens_sl); vol_std = std(vol_sl);
        dv_arr_out_rej = dv_sl(dens_sl > mean(dens_sl) - std_thresh_reject_dens * dens_std & ...
            dens_sl < mean(dens_sl) + std_thresh_reject_dens * dens_std, :);
        vol_sl = dv_arr_out_rej(:,2);
        dv_arr_out_rej = dv_arr_out_rej(vol_sl > mean(vol_sl) - std_thresh_reject_vol * vol_std & ...
            vol_sl < mean(vol_sl) + std_thresh_reject_vol * vol_std, :);

        % Extract metrics from this population
        dens_rej = dv_arr_out_rej(:,1); vol_rej = dv_arr_out_rej(:,2);
        met_st.raw_table = [met_st.raw_table; dv_arr_out_rej];
        met_st.raw_table_seg{num_particle_sz+1-j} = dv_arr_out_rej;
        met_st.dens_mean = [mean(dens_rej), met_st.dens_mean];
        met_st.dens_pct_err = [(mean(dens_rej) - d_gt(j)) / d_gt(j), met_st.dens_pct_err];
        met_st.dens_pct_err_abs = [abs((mean(dens_rej) - d_gt(j)) / d_gt(j)), met_st.dens_pct_err_abs];
        met_st.vol_mean = [mean(vol_rej), met_st.vol_mean];
        met_st.vol_pct_err = [(mean(vol_rej) - v_gt(j)) / v_gt(j), met_st.vol_pct_err];
        met_st.vol_pct_err_abs = [abs((mean(vol_rej) - v_gt(j)) / v_gt(j)), met_st.vol_pct_err_abs];
        met_st.dens_cv = [std(dens_rej) / mean(dens_rej), met_st.dens_cv];
        met_st.vol_cv =  [std(vol_rej) / mean(vol_rej), met_st.vol_cv];
        met_st.dens_std = [std(dens_rej), met_st.dens_std];
        met_st.vol_std =  [std(vol_rej), met_st.vol_std];
        
        p = polyfit(dens_rej, vol_rej, 1);
        met_st.dv_slope = [p(1), met_st.dv_slope];
        met_st.dv_slope_norm_to_vol = [p(1) / mean(vol_rej), met_st.dv_slope_norm_to_vol];

        err_cond = ~issorted(met_st.vol_mean, 'descend') && any(isnan(met_st.vol_mean));

        if err_cond
            error('Clustering error')
        end
    end
    met_st.mean_dens_pct_err = mean(met_st.dens_pct_err);
    met_st.mean_dens_pct_err_abs = mean(met_st.dens_pct_err_abs);

    met_st.mean_dens_cv = mean(met_st.dens_cv);

    met_st.mean_vol_pct_err = mean(met_st.vol_pct_err);
    met_st.mean_vol_pct_err_abs = mean(met_st.vol_pct_err_abs);

    met_st.mean_vol_cv = mean(met_st.vol_cv);

    met_st.mean_dv_slope = mean(met_st.dv_slope);

    p = polyfit(met_st.vol_mean, met_st.dens_pct_err, 1); 
    met_st.szdep_drift_dens = p(1);

    p = polyfit(met_st.vol_mean, met_st.vol_pct_err, 1);
    met_st.szdep_drift_vol = p(1);
    
    compiled_4d{dff_sl(1), dff_sl(2), dff_sl(3), dff_sl(4)} = met_st;
end

save(save_path, 'compiled_4d')