close all;
addpath(genpath("..\..\helpers"));

% Req's 2 file types: pass structs, paired peakset summary. First, parses
% pass structs to extract data for individual peaks. Then, matches
% individual peaks from paired peaksets with specific paired peaks from
% peakset summary.

%% Load data and extract baselines
fwd_pass_st = load("C:\thomasu\smr_data_analysis\analysis\2024-07-12_bead_2fluid_heatmaps\data\5_10_15um\pass_struct_fluid1.mat");
fwd_pass_st = fwd_pass_st.pass_struct_fluid1;
back_pass_st = load("C:\thomasu\smr_data_analysis\analysis\2024-07-12_bead_2fluid_heatmaps\data\5_10_15um\pass_struct_fluid2.mat");
back_pass_st = back_pass_st.pass_struct_fluid2;
pkset_paired = readtable("C:\thomasu\smr_data_analysis\analysis\2024-07-12_bead_2fluid_heatmaps\data\5_10_15um\peakset_summary_paired.csv");

fwd_parsed_st = parse_pass_structs(fwd_pass_st);
back_parsed_st = parse_pass_structs(back_pass_st);

freq_pair_st = find_freq_data_paired(fwd_parsed_st, back_parsed_st, pkset_paired);

%% Analyze data and extract metrics for baselines
met_tab = extract_metrics(freq_pair_st);



%% Functions
function met_tab = extract_metrics(freq_pair_st)
% Metrics to extract:
%   fwd_lin_slope_r / fwd_lin_slope_l / fwd_lin_slope_avg : lin. slopes of fwd
%       pk baselines
%   bck_lin_slope_r / bck_lin_slope_l / bck_lin_slope_avg : lin. slopes of bck
%       pk baselines
%   bck_pk_a_r / bck_pk_a_l / bck_pk_a_mean / bck_pk_a_absmean : back peak 
%       quadratic a coefficient (ax^2+bx+c)
%   bck_pk_c_r / bck_pk_c_l / bck_pk_c_mean / bck_pk_c_absmean : back peak 
%       quadratic c coefficient (ax^2+bx+c)
%   bck_pk_imbal : vertical distance between end of left and beginning of
%       right baseline
%   bck_maxcurv_r / bck_maxcurv_l / bck_maxcurv_avg : maximum
%       curvature (rad of curvature^-1) of fwd/back/avg baselines
%   bck_vtx_pos_r / bck_vtx_pos_l / bck_vtx_pos_avg : vertex position
%       relative to baseline segment. Rescaled from 0 to 1, 1 being closest
%       to peak and 0 being furthest. Values out of this range indicate
%       vertex positions to the left or right of peak

fwd_bls_full = freq_pair_st.fwd_bls;
bck_bls_full = freq_pair_st.back_bls;

met_tab.fwd_lin_slope_l = zeros(length(fwd_bls),1);
met_tab.fwd_lin_slope_r = zeros(length(fwd_bls),1);
met_tab.fwd_lin_slope_avg = zeros(length(fwd_bls),1);

met_tab.bck_lin_slope_l = zeros(length(fwd_bls),1);
met_tab.bck_lin_slope_r = zeros(length(fwd_bls),1);
met_tab.bck_lin_slope_avg = zeros(length(fwd_bls),1);

met_tab.bck_pk_a_l = zeros(length(fwd_bls),1); met_tab.bck_pk_a_r = zeros(length(fwd_bls),1);
met_tab.bck_pk_a_mean = zeros(length(fwd_bls),1); 
met_tab.bck_pk_a_absmean = zeros(length(fwd_bls),1);

met_tab.bck_pk_c_l = zeros(length(fwd_bls),1); met_tab.bck_pk_c_r = zeros(length(fwd_bls),1);
met_tab.bck_pk_c_mean = zeros(length(fwd_bls),1); 
met_tab.bck_pk_c_absmean = zeros(length(fwd_bls),1);

met_tab.bck_pk_imbal = zeros(length(fwd_bls),1);

met_tab.bck_maxcurv_l = zeros(length(fwd_bls),1);
met_tab.bck_maxcurv_r = zeros(length(fwd_bls),1);
met_tab.bck_maxcurv_avg = zeros(length(fwd_bls),1);

met_tab.bck_vtx_pos_l = zeros(length(fwd_bls),1);
met_tab.bck_vtx_pos_r = zeros(length(fwd_bls),1);
met_tab.bck_vtx_pos_avg = zeros(length(fwd_bls),1);

for i = 1:length(fwd_bls)
    fwd_bl_l = fwd_bls_full{i,1}; fwd_bl_r = fwd_bls_full{i,2};
    bck_bl_l = bck_bls_full{i,1}; bck_bl_r = bck_bls_full{i,2};
    bck_bl_l_len = length(bck_bl_l); bck_bl_r_len = length(bck_bl_r);

    met_tab.fwd_lin_slope_l(i) = get_slope(fwd_bl_l);
    met_tab.fwd_lin_slope_r(i) = get_slope(fwd_bl_r);
    met_tab.fwd_lin_slope_avg(i) = mean([met_tab.fwd_lin_slope_l, met_tab.fwd_lin_slope_r]);

    met_tab.bck_lin_slope_l(i) = get_slope(bck_bl_l);
    met_tab.bck_lin_slope_r(i) = get_slope(bck_bl_r);
    met_tab.bck_lin_slope_avg(i) = mean([met_tab.bck_lin_slope_l, met_tab.bck_lin_slope_r]);

    [bck_a_l, bck_b_l, bck_c_l] = get_quad_coeffs(bck_bl_l);
    [bck_a_r, bck_b_r, bck_c_r] = get_quad_coeffs(bck_bl_r);
    met_tab.bck_pk_a_l(i) = bck_a_l; met_tab.bck_pk_a_r(i) = bck_a_r;
    met_tab.bck_pk_a_mean(i) = mean([bck_a_l, bck_a_r]); 
    met_tab.bck_pk_a_absmean(i) = mean(abs([bck_a_l, bck_a_r]));

    met_tab.bck_pk_c_l(i) = bck_c_l; met_tab.bck_pk_c_r(i) = bck_c_r;
    met_tab.bck_pk_c_mean(i) = mean([bck_c_l, bck_c_r]); 
    met_tab.bck_pk_c_absmean(i) = mean(abs([bck_c_l, bck_c_r]));

    met_tab.bck_pk_imbal(i) = bck_bl_l(end) - bck_bl_r(1);

    met_tab.bck_maxcurv_l(i) = max(calc_curvature(bck_bl_l));
    met_tab.bck_maxcurv_r(i) = max(calc_curvature(bck_bl_r));
    met_tab.bck_maxcurv_avg(i) = mean([met_tab.bck_maxcurv_l, met_tab.bck_maxcurv_r]);

    met_tab.bck_vtx_pos_l(i) = -bck_b_l / (2 * bck_a_l) / length(bck_bl_l_len);
    met_tab.bck_vtx_pos_r(i) = -bck_b_r / (2 * bck_a_r) / length(bck_bl_r_len);
    met_tab.bck_vtx_pos_avg(i) = mean([met_tab.bck_vtx_pos_l, met_tab.bck_vtx_pos_r]);
end

met_tab = struct2table(met_tab);

end

% TODO: full baseline quad fit (a coeff)

function a = full_bl_quad_fit_coef(left_bl, right_bl, full_freq)

end

function curv = calc_curvature(data_vec)
[a, b, ~] = get_quad_coeffs(data_vec);
curv = 2 * a / (1 + (2 * a * (0:length(data_vec)-1) + b) .^ 2).^3/2;
end

function [a, b, c] = get_quad_coeffs(data_vec)
p = polyfit(0:length(data_vec)-1,data_vec,2);
a = p(1); b = p(2); c = p(3);
end

function m = get_slope(data_vec)
p = polyfit(0:length(data_vec)-1,data_vec,1);
m = p(1);
end

function freq_pair_st = find_freq_data_paired(fwd_parsed_st, back_parsed_st, pkset_paired)

freq_pair_st.freq_pair_cell = cell(height(pkset_paired),2);
freq_pair_st.fwd_bls = cell(height(pkset_paired),2);
freq_pair_st.back_bls = cell(height(pkset_paired),2);
for i = 1:height(pkset_paired)
    fl1_time = round(pkset_paired.fl1_real_time_s(i),3);
    fl2_time = round(pkset_paired.fl2_real_time_s(i),3);

    fwd_pk_mask = round(fwd_parsed_st.peak_avg_time,3) == fl1_time;
    freq_pair_st.freq_pair_cell{i,1} = fwd_parsed_st.freq_cells{fwd_pk_mask};
    freq_pair_st.fwd_bls(i,:) = fwd_parsed_st.freq_bl(:, fwd_pk_mask);

    back_pk_mask = round(back_parsed_st.peak_avg_time,3) == fl2_time;
    freq_pair_st.freq_pair_cell{i,2} = back_parsed_st.freq_cells{back_pk_mask};
    freq_pair_st.back_bls(i,:) = back_parsed_st.freq_bl(:, back_pk_mask);
end 
end

function parsed_st = parse_pass_structs(p_str)
parsed_st.left_bl_length = p_str.left_bl_length;
parsed_st.right_bl_length = p_str.right_bl_length;
parsed_st.peak_avg_time = p_str.peak_avg_time;
parsed_st.freq_cells = cell(1,length(p_str.left_bl_length));
parsed_st.freq_bl = cell(2,length(p_str.left_bl_length));

end_idxs = find(isnan(p_str.samplepeak))-1;
start_idxs = [1, end_idxs(1:end-1)+4];

for i = 1:length(p_str.left_bl_length)
    peak_data = p_str.samplepeak(start_idxs(i):end_idxs(i));
    parsed_st.freq_cells{i} = peak_data;
    parsed_st.freq_bl{1, i} = peak_data(1:p_str.left_bl_length(i));
    parsed_st.freq_bl{2, i} = peak_data(end-p_str.right_bl_length(i):end);
end
end