close all;
addpath(genpath("..\..\helpers"));

drive_lett = "A";
search_path = drive_lett + ":\thomasu\raw_data\2024-03-19\dens_trap_fitting_gridsearch\data_paired.mat";
save_path = drive_lett + ":\thomasu\raw_data\2024-03-19\dens_trap_fitting_gridsearch\data_cleaned.mat";
st = load(search_path);

% Order of params: fitting_order, node_weight, bl_fit_length, bl_fit_offset
param_axes = st.value_arr;
dff = st.dff;
searched = st.compiled_data;
axis_lens = cellfun(@(x) length(x), st.value_arr);

% Struct elements at each parameter set:
% 

% Compile search data into 4d array of structs with relevant values
num_particle_sz = 3;
std_thresh_reject_dens = 3;
std_thresh_reject_vol = 3;
compiled_4d = cell(axis_lens);
for i = 1:size(dff, 1)
    fprintf('%i of %i\n', i, size(dff, 1))
    dff_sl = dff(i,:);
    sear_tab = searched{i};
    comp_str.full_tab_uncur = sear_tab;


    [~, vol_dict] = get_bead_diams();
    bead_vols = vol_dict([6, 8, 10]);

    dv_arr = [sear_tab.density_gcm3, sear_tab.volume_fl];
    [idx, ctrs] = kmeans(dv_arr, num_particle_sz, Start=[[1.05, 1.05, 1.05]', bead_vols']);
    [sorted_ctrs, sort_idx] = sort(ctrs(:,2));

    met_st.raw_table_seg = {};
    met_st.raw_table = [];
    met_st.dens_mean = [];
    met_st.dens_pct_err = [];
    met_st.vol_mean = [];
    met_st.vol_pct_err = [];
    met_st.dens_cv = [];
    met_st.vol_cv =  [];
    met_st.dens_std = [];
    met_st.vol_std =  [];
    for j = 1:length(sort_idx)
        clust_idx = sort_idx(j);
        dv_sl = dv_arr(idx==clust_idx, :);
        
        % Slice out outliers
        dens_sl = dv_sl(:,1);
        dens_std = std(dens_sl); vol_std = std(vol_sl);
        dv_arr_out_rej = dv_sl(dens_sl > mean(dens_sl) - std_thresh_reject_dens * dens_std & ...
            dens_sl < mean(dens_sl) + std_thresh_reject_dens * dens_std, :);
        vol_sl = dv_arr_out_rej(:,2);
        dv_arr_out_rej = dv_arr_out_rej(vol_sl > mean(vol_sl) - std_thresh_reject_vol * vol_std & ...
            vol_sl < mean(vol_sl) + std_thresh_reject_vol * vol_std, :);

        % Extract metrics from this population
        dens_rej = dv_arr_out_rej(:,1); vol_rej = dv_arr_out_rej(:,2);
        met_st.raw_table = [met_st.raw_table; dv_sl];
        met_st.raw_table_seg{4-j} = dv_sl;
        met_st.dens_mean = [mean(dens_rej), met_st.dens_mean];
        met_st.dens_pct_err = [(mean(dens_rej) - 1.05) / 1.05, met_st.dens_pct_err];
        met_st.vol_mean = [mean(vol_rej), met_st.vol_mean];
        met_st.vol_pct_err = [(mean(vol_rej) - bead_vols(j)) / bead_vols(j), met_st.vol_pct_err];
        met_st.dens_cv = [std(dens_rej) / mean(dens_rej), met_st.dens_cv];
        met_st.vol_cv =  [std(vol_rej) / mean(vol_rej), met_st.vol_cv];
        met_st.dens_std = [std(dens_rej), met_st.dens_std];
        met_st.vol_std =  [std(vol_rej), met_st.vol_std];

        err_cond = ~issorted(met_st.vol_mean, 'descend') && any(isnan(met_st.vol_mean)) && ...
            met_st.vol_mean(1) > 500 && met_st.vol_mean(2) > 200 && met_st.vol_mean(2) < 300 && met_st.vol_mean(3) < 200;
        if err_cond
            error('Clustering error')
        end
    end
    compiled_4d{dff_sl(1), dff_sl(2), dff_sl(3), dff_sl(4)} = met_st;
end

% compiled_4d{1,1,1,1}
% compiled_4d{5,6,8,4}

save(save_path, 'compiled_4d')