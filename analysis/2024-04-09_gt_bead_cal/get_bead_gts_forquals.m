close all;
addpath(genpath("..\..\helpers"));

% bead_cc_15um = load_coulter_data("C:\thomasu\smr_data_analysis\analysis\2024-04-09_gt_bead_cal\data\coulter\15um_beads_1.#m4");
% bead_cc_mix = load_coulter_data("C:\thomasu\smr_data_analysis\analysis\2024-04-09_gt_bead_cal\data\coulter\5-12um_beads_2.#m4");

% 17 19 21
% cc_dir = ls("A:\thomasu\raw_data\2024-04-17\beads_coulter", true);
% cc_structs = cell(length(cc_dir),1);

% gates = [10 2000; 10 2000; 10 2000; 10 2000; 10 2000; 10 2000; 10 2000];

% gates = [28 92; 66 160; 116 220; 165 325; 225 450; 340 600; 600 1000];
% gates = [28 105; 66 160; 116 220; 165 325; 225 450; 340 600; 600 1000];
% gates = [28 105; 66 160; 116 220; 165 325; 225 450; 340 600; 600 1000];

% labels = ["5um", "6um", "7um", "8um", "9um", "10um", "12um"];
% pop_means = zeros(1, 7);
% for i = 1:length(cc_dir)
%     tab = load_coulter_data(cc_dir{i});
%     gate_min = gates(i, 1); gate_max = gates(i, 2);
%     tab_sl = tab(tab.volume_fL < gate_max & tab.volume_fL > gate_min, :);
%     leading_edge_tab = tab(tab.volume_fL <= gate_min, :);
%     lead_edge_diam = leading_edge_tab.diameter(end);
%     lead_edge_volume = leading_edge_tab.volume_fL(end);
% 
%     st.bin_edges_diam = [lead_edge_diam, tab_sl.diameter'];
%     st.bin_edges_vol = [lead_edge_volume, tab_sl.volume_fL'];
%     st.counts = tab_sl.count;
%     cc_structs{i} = st;
% 
%     figure; 
%     h = histogram('BinEdges',st.bin_edges_vol,'BinCounts', st.counts, ...
%         FaceColor='blue', EdgeColor='blue');
%     title(labels(i))
% 
%     bin_ctrs = diff(st.bin_edges_vol) / 2 + st.bin_edges_vol(1:end-1);
%     pop_means(i) = sum(bin_ctrs .* st.counts') / sum(st.counts);
% end
% disp(pop_means)

%% Get GT bead volumes
gt_vol_1 = [59.2962   97.8527  150.4446  224.3018  320.2922  453.9068  788.9085];
gt_vol_2 = [63.8099  100.2227  147.1580  218.8529  313.3524  445.9606  784.4750];
gt_vol_3 = [54.9126  104.6798  153.2641  216.7682  314.7633  434.9863  752.2667];

mean_gt_vol = (gt_vol_1 + gt_vol_2 + gt_vol_3) / 3;

[diam_dict, vol_dict] = get_bead_diams();
manu_vols = vol_dict([5 6 7 8 9 10 12]);

erf_handle_vol = ...
    @(scl) mean((scl*mean_gt_vol - manu_vols).^2);
scl_value = fminbnd(erf_handle_vol, 0.8, 1.2);

gt_bead_vols = mean_gt_vol * scl_value;

%% Get GT bead masses
gt_bms_3rep = [...
    3.1428 5.2545 8.0715 11.9715 16.8128 23.6209 41.5611; ...
    3.1673 5.2928 8.1376 12.0969 16.9198 23.7986 41.9627; ...
    3.1640 5.2912 8.1183 12.0839 16.9034 23.7031 41.7604];

mean_bead_bms = sum(gt_bms_3rep, 1) / 3;
gt_bead_masses = mean_bead_bms + gt_bead_vols*1.004; % 1.0059
gt_bead_densities = gt_bead_masses ./ gt_bead_vols;

% disp(gt_bead_masses)
% disp(gt_bead_vols*1.04)
disp(gt_bead_densities)

% mean_bead_bms = sum(gt_bms_3rep, 1) / 3;
% gt_bead_masses = mean_bead_bms + manu_vols*0.997;
% gt_bead_densities = gt_bead_masses ./ manu_vols;