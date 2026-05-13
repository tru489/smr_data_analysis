close all;
addpath(genpath("..\..\helpers"));

% Req's 2 file types: pass structs, paired peakset summary. First, parses
% pass structs to extract data for individual peaks. Then, matches
% individual peaks from paired peaksets with specific paired peaks from
% peakset summary.

%% Editable params
data_dir = 'data\5-15um_beads';
save_path = 'fig_5-15um';
outlier_rej_bounds = [1.046, 1.062];

bead_diams = [5:10, 12, 15];
% bead_diams = [5 10 15];
% bead_diams = [6 8 10];

%% Load data and extract baselines
fwd_pass_st = load(fullfile(data_dir, "pass_struct_fluid1.mat"));
fwd_pass_st = fwd_pass_st.pass_struct_fluid1;
back_pass_st = load(fullfile(data_dir, "pass_struct_fluid2.mat"));
back_pass_st = back_pass_st.pass_struct_fluid2;
pkset_paired = readtable(fullfile(data_dir, "peakset_summary_paired.csv"));

fwd_parsed_st = parse_pass_structs(fwd_pass_st);
back_parsed_st = parse_pass_structs(back_pass_st);

freq_pair_st = find_freq_data_paired(fwd_parsed_st, back_parsed_st, pkset_paired);

%% Analyze data and extract metrics for baselines
met_tab = extract_metrics(freq_pair_st);
writetable(met_tab, fullfile(save_path, 'full_metric_table.csv'))

%% Plot sample peak
fh1 = figure;
freq_data = freq_pair_st.freq_pair_cell{1,1};
plot(0:length(freq_data)-1, freq_data, LineWidth=3)
xlim([0, length(freq_data)-1])
saveas(fh1, fullfile(save_path, 'sample_peak.jpg'))

%% Plot all metrics as colormaps on scatter plots
ppt_path = fullfile(save_path, 'comp_ppt.pptx');
plot_all_scatter(pkset_paired, met_tab, save_path, ppt_path, outlier_rej_bounds, bead_diams)

%% Functions
function create_fig_ppt(ppt_path, path_cell)

import mlreportgen.ppt.*
ppt = Presentation(ppt_path, ...
    "C:\thomasu\smr_data_analysis\final_code\visualization\template.potx");
open(ppt);
title_slide = add(ppt, 'Fig_slides_title');
replace(title_slide, "Title", 'Figure compilation');

for i = 1:length(path_cell)
    slide = add(ppt,"matlab_pic_slide");
    figPicture = Picture(path_cell{i});
    replace(slide,"Pic Placeholder",figPicture);
end
close(ppt);
rptview(ppt);
end



function plot_all_scatter(paired_tab, met_tab, save_path, ppt_path, outlier_rej_bounds, bead_diams)
col_names = met_tab.Properties.VariableNames;
disp('Creating scatter plots...')
path_cell = cell(1,length(col_names));
for i = 1:length(col_names)
    fh = plot_single_scatter(paired_tab, met_tab.(col_names{i}), col_names{i}, outlier_rej_bounds, bead_diams);
    saveas(fh, fullfile(save_path, col_names{i} + ".jpg"))
    path_cell{i} = fullfile(save_path, col_names{i} + ".jpg");
end

disp('Creating powerpoint...')
create_fig_ppt(ppt_path, path_cell)

end

function fh = plot_single_scatter(xy_tab, color_vec, cmap_name, outlier_rej_bounds, bead_diams)
dens_dict = get_bead_density();
vol_dict = get_bead_vols_coulter();

fh = figure(Position=[1921          41        1920         963]); 
axs = tight_subplot(2,2, 0.07, [0.09 0.05], [0.05 0.02]);


axes(axs(1));
scatter(xy_tab.volume_fl,xy_tab.density_gcm3,[],color_vec,'filled'); 
title(strrep(cmap_name, '_', '\_'), FontSize=16); 
xlabel('Dry volume (fL)', FontSize=14); ylabel('Dry density (g/cm3)', FontSize=14);
ax=gca; ax.FontSize=13;
colorbar
colormap jet
hold on; scatter(vol_dict(bead_diams), dens_dict(bead_diams), 80, 'r', '+', LineWidth=3); 

axes(axs(2));
outlier_rej_mask = xy_tab.density_gcm3 > outlier_rej_bounds(1) & xy_tab.density_gcm3 < outlier_rej_bounds(2);
scatter(xy_tab.volume_fl(outlier_rej_mask),xy_tab.density_gcm3(outlier_rej_mask),[],color_vec(outlier_rej_mask),'filled'); 
% title(strrep(cmap_name, '_', '\_'), FontSize=16); 
xlabel('Dry volume (fL)', FontSize=14); ylabel('Dry density (g/cm3)', FontSize=14);
ax=gca; ax.FontSize=13;
colorbar
colormap jet
hold on; scatter(vol_dict(bead_diams), dens_dict(bead_diams), 80, 'r', '+', LineWidth=3); 

axes(axs(3));
outlier_rej_mask = xy_tab.density_gcm3 > outlier_rej_bounds(1) & xy_tab.density_gcm3 < outlier_rej_bounds(2);
[~, metric_out_rej_mask] = rmoutliers(color_vec);
final_mask = outlier_rej_mask & ~metric_out_rej_mask;
scatter(xy_tab.volume_fl(final_mask),xy_tab.density_gcm3(final_mask),[],color_vec(final_mask),'filled'); 
% title(strrep(cmap_name, '_', '\_'), FontSize=16);
xlabel('Dry volume (fL)', FontSize=14); ylabel('Dry density (g/cm3)', FontSize=14);
ax=gca; ax.FontSize=13;
colorbar
colormap jet
hold on; scatter(vol_dict(bead_diams), dens_dict(bead_diams), 80, 'r', '+', LineWidth=3); 

end

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
%   bck_pk_imbal_inner : vertical distance between end of left and beginning of
%       right baseline
%   bck_pk_imbal_outer : vertical distance between start of left and end of
%       right baseline
%   bck_pk_slope_inner : slope between start of left and end of
%       right baseline
%   bck_maxcurv_r / bck_maxcurv_l / bck_maxcurv_avg / bck_maxcurv_whole : maximum
%       curvature (rad of curvature^-1) of fwd/back/avg baselines
%   bck_avgcurv_r / bck_avgcurv_l / bck_avgcurv_avg / bck_maxcurv_whole : maximum
%       curvature (rad of curvature^-1) of fwd/back/avg baselines
%   bck_vtx_pos_r / bck_vtx_pos_l / bck_vtx_pos_avg : vertex position
%       relative to baseline segment. Rescaled from 0 to 1, 1 being closest
%       to peak and 0 being furthest. Values out of this range indicate
%       vertex positions to the left or right of peak
%   bck_pk_a_full : a coefficient of peak fit when both the left and right
%       baseline are used in fitting
%   bck_vtx_pos_full : vertex position relative to baseline segment when
%       the entire baseline (L & R both included) are fit. Rescaled from 0 to
%       1, 1 being the right boundary of the peak segment and 0 being the left
%   mean_bl_val : mean baseline value from all left and right baselines
%       (backward peak)
%   mean_bl_val_fwd : mean baseline value for fwd peak
%   bl_vert_yval_l / bl_vert_yval_r / bl_vert_yval_avg /
%       bl_vert_yval_whole: vertex position of quadratic fits of left/right
%       baselines, their average, or a fit of both the left and right
%       baseline

bck_fullpks = freq_pair_st.freq_pair_cell(:,1);
fwd_bls_full = freq_pair_st.fwd_bls;
bck_bls_full = freq_pair_st.back_bls;

met_tab.fwd_lin_slope_l = zeros(size(freq_pair_st.fwd_bls,1),1);
met_tab.fwd_lin_slope_r = zeros(size(freq_pair_st.fwd_bls,1),1);
met_tab.fwd_lin_slope_avg = zeros(size(freq_pair_st.fwd_bls,1),1);

met_tab.bck_lin_slope_l = zeros(size(freq_pair_st.fwd_bls,1),1);
met_tab.bck_lin_slope_r = zeros(size(freq_pair_st.fwd_bls,1),1);
met_tab.bck_lin_slope_avg = zeros(size(freq_pair_st.fwd_bls,1),1);

met_tab.bck_pk_a_l = zeros(size(freq_pair_st.fwd_bls,1),1); met_tab.bck_pk_a_r = zeros(size(freq_pair_st.fwd_bls,1),1);
met_tab.bck_pk_a_mean = zeros(size(freq_pair_st.fwd_bls,1),1); 
met_tab.bck_pk_a_absmean = zeros(size(freq_pair_st.fwd_bls,1),1);

met_tab.bck_pk_c_l = zeros(size(freq_pair_st.fwd_bls,1),1); met_tab.bck_pk_c_r = zeros(size(freq_pair_st.fwd_bls,1),1);
met_tab.bck_pk_c_mean = zeros(size(freq_pair_st.fwd_bls,1),1); 
met_tab.bck_pk_c_absmean = zeros(size(freq_pair_st.fwd_bls,1),1);

met_tab.bck_pk_imbal_inner = zeros(size(freq_pair_st.fwd_bls,1),1);
met_tab.bck_pk_imbal_outer = zeros(size(freq_pair_st.fwd_bls,1),1);
met_tab.bck_pk_slope_inner = zeros(size(freq_pair_st.fwd_bls,1),1);

met_tab.bck_maxcurv_l = zeros(size(freq_pair_st.fwd_bls,1),1);
met_tab.bck_maxcurv_r = zeros(size(freq_pair_st.fwd_bls,1),1);
met_tab.bck_maxcurv_avg = zeros(size(freq_pair_st.fwd_bls,1),1);
met_tab.bck_maxcurv_whole = zeros(size(freq_pair_st.fwd_bls,1),1);

met_tab.bck_avgcurv_l = zeros(size(freq_pair_st.fwd_bls,1),1);
met_tab.bck_avgcurv_r = zeros(size(freq_pair_st.fwd_bls,1),1);
met_tab.bck_avgcurv_avg = zeros(size(freq_pair_st.fwd_bls,1),1);
met_tab.bck_avgcurv_whole = zeros(size(freq_pair_st.fwd_bls,1),1);

met_tab.bck_vtx_pos_l = zeros(size(freq_pair_st.fwd_bls,1),1);
met_tab.bck_vtx_pos_r = zeros(size(freq_pair_st.fwd_bls,1),1);
met_tab.bck_vtx_pos_avg = zeros(size(freq_pair_st.fwd_bls,1),1);

met_tab.bck_pk_a_full = zeros(size(freq_pair_st.fwd_bls,1),1);
met_tab.bck_vtx_pos_full = zeros(size(freq_pair_st.fwd_bls,1),1);

met_tab.mean_bl_val = zeros(size(freq_pair_st.fwd_bls,1),1);
met_tab.mean_bl_val_fwd = zeros(size(freq_pair_st.fwd_bls,1),1);

met_tab.bl_vert_yval_l = zeros(size(freq_pair_st.fwd_bls,1),1);
met_tab.bl_vert_yval_r = zeros(size(freq_pair_st.fwd_bls,1),1);
met_tab.bl_vert_yval_avg = zeros(size(freq_pair_st.fwd_bls,1),1);
met_tab.bl_vert_yval_whole = zeros(size(freq_pair_st.fwd_bls,1),1);

for i = 1:size(freq_pair_st.fwd_bls,1)
    fwd_bl_l = fwd_bls_full{i,1}; fwd_bl_r = fwd_bls_full{i,2};
    bck_bl_l = bck_bls_full{i,1}; bck_bl_r = bck_bls_full{i,2};
    bck_bl_l_len = length(bck_bl_l); bck_bl_r_len = length(bck_bl_r);

    met_tab.fwd_lin_slope_l(i) = get_slope(fwd_bl_l);
    met_tab.fwd_lin_slope_r(i) = get_slope(fwd_bl_r);
    met_tab.fwd_lin_slope_avg(i) = mean([met_tab.fwd_lin_slope_l(i), met_tab.fwd_lin_slope_r(i)]);

    met_tab.bck_lin_slope_l(i) = get_slope(bck_bl_l);
    met_tab.bck_lin_slope_r(i) = get_slope(bck_bl_r);
    met_tab.bck_lin_slope_avg(i) = mean([met_tab.bck_lin_slope_l(i), met_tab.bck_lin_slope_r(i)]);

    [bck_a_l, bck_b_l, bck_c_l] = get_quad_coeffs(bck_bl_l);
    [bck_a_r, bck_b_r, bck_c_r] = get_quad_coeffs(bck_bl_r);
    met_tab.bck_pk_a_l(i) = bck_a_l; met_tab.bck_pk_a_r(i) = bck_a_r;
    met_tab.bck_pk_a_mean(i) = mean([bck_a_l, bck_a_r]); 
    met_tab.bck_pk_a_absmean(i) = mean(abs([bck_a_l, bck_a_r]));

    met_tab.bck_pk_c_l(i) = bck_c_l; met_tab.bck_pk_c_r(i) = bck_c_r;
    met_tab.bck_pk_c_mean(i) = mean([bck_c_l, bck_c_r]); 
    met_tab.bck_pk_c_absmean(i) = mean(abs([bck_c_l, bck_c_r]));

    met_tab.bck_pk_imbal_inner(i) = bck_bl_l(end) - bck_bl_r(1);
    met_tab.bck_pk_imbal_outer(i) = bck_bl_l(1) - bck_bl_r(end);
    met_tab.bck_pk_slope_inner(i) = (bck_bl_r(1) - bck_bl_l(end)) / (length(bck_fullpks{i}) - bck_bl_l_len - bck_bl_r_len);

    [a, b, c] = full_bl_quad_fit_coef(bck_bl_l, bck_bl_r, bck_fullpks{i});
    met_tab.bck_pk_a_full(i) = a;
    met_tab.bck_vtx_pos_full(i) = -b / (2 * a) / length(bck_fullpks{i});

    met_tab.bck_maxcurv_l(i) = max(calc_curvature(bck_bl_l));
    met_tab.bck_maxcurv_r(i) = max(calc_curvature(bck_bl_r));
    met_tab.bck_maxcurv_avg(i) = mean([met_tab.bck_maxcurv_l(i), met_tab.bck_maxcurv_r(i)]);
    met_tab.bck_maxcurv_whole(i) = max(calc_curv_total(a, b, bck_bl_l, bck_bl_r, bck_fullpks{i}));

    met_tab.bck_avgcurv_l(i) = mean(calc_curvature(bck_bl_l));
    met_tab.bck_avgcurv_r(i) = mean(calc_curvature(bck_bl_r));
    met_tab.bck_avgcurv_avg(i) = mean([met_tab.bck_maxcurv_l(i), met_tab.bck_maxcurv_r(i)]);
    met_tab.bck_avgcurv_whole(i) = mean(calc_curv_total(a, b, bck_bl_l, bck_bl_r, bck_fullpks{i}));

    met_tab.bck_vtx_pos_l(i) = -bck_b_l / (2 * bck_a_l) / bck_bl_l_len;
    met_tab.bck_vtx_pos_r(i) = -bck_b_r / (2 * bck_a_r) / bck_bl_r_len;
    met_tab.bck_vtx_pos_avg(i) = mean([met_tab.bck_vtx_pos_l(i), met_tab.bck_vtx_pos_r(i)]);

    met_tab.mean_bl_val(i) = mean([bck_bl_l,bck_bl_r]);
    met_tab.mean_bl_val_fwd(i) = mean([fwd_bl_l,fwd_bl_r]);

    met_tab.bl_vert_yval_l(i) = -(bck_b_l^2 - 4 * bck_a_l * bck_c_l) / (4 * bck_a_l);
    met_tab.bl_vert_yval_r(i) = -(bck_b_r^2 - 4 * bck_a_r * bck_c_r) / (4 * bck_a_r);
    met_tab.bl_vert_yval_avg(i) = mean([met_tab.bl_vert_yval_l(i), met_tab.bl_vert_yval_r(i)]);
    met_tab.bl_vert_yval_whole(i) = -(b^2 - 4 * a * c) / (4 * a);
end

met_tab = struct2table(met_tab);

end

function curv_arr = calc_curv_total(a, b, left_bl, right_bl, full_freq)
data_vec = [0:length(left_bl)-1, length(full_freq)-length(right_bl):length(full_freq)-1];
curv_arr = 2 * a ./ (1 + (2 * a * (0:length(data_vec)-1) + b) .^ 2).^3/2;
end

function [a, b, c] = full_bl_quad_fit_coef(left_bl, right_bl, full_freq)
p = polyfit([0:length(left_bl)-1, length(full_freq)-length(right_bl):length(full_freq)-1], [left_bl, right_bl], 2);
a = p(1); b = p(2); c = p(3);
end

function curv = calc_curvature(data_vec)
[a, b, ~] = get_quad_coeffs(data_vec);
curv = 2 * a ./ (1 + (2 * a * (0:length(data_vec)-1) + b) .^ 2).^3/2;
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
    fl1_time = round(pkset_paired.fl1_real_time_s(i),2);
    fl2_time = round(pkset_paired.fl2_real_time_s(i),2);

    fwd_pk_mask = round(fwd_parsed_st.peak_avg_time,2) == fl1_time;
    freq_pair_st.freq_pair_cell{i,1} = fwd_parsed_st.freq_cells{fwd_pk_mask};
    freq_pair_st.fwd_bls(i,:) = fwd_parsed_st.freq_bl(:, fwd_pk_mask);

    back_pk_mask = round(back_parsed_st.peak_avg_time,2) == fl2_time;
    freq_pair_st.freq_pair_cell{i,2} = back_parsed_st.freq_cells{back_pk_mask};
    freq_pair_st.back_bls(i,:) = back_parsed_st.freq_bl(:, back_pk_mask);
end 
end

function parsed_st = parse_pass_structs(p_str)
parsed_st.left_bl_length = p_str.left_bl_length;
parsed_st.right_bl_length = p_str.right_bl_length;
parsed_st.peak_avg_time = p_str.peak_avg_time;
parsed_st.freq_cells = cell(1,length(p_str.left_bl_length));
parsed_st.freq_bl = cell(2,length(p_str.left_bl_length));r

end_idxs = find(isnan(p_str.samplepeak))-1;
start_idxs = [1, end_idxs(1:end-1)+4];

for i = 1:length(p_str.left_bl_length)
    peak_data = p_str.samplepeak(start_idxs(i):end_idxs(i));
    parsed_st.freq_cells{i} = peak_data;
    parsed_st.freq_bl{1, i} = peak_data(1:p_str.left_bl_length(i));
    parsed_st.freq_bl{2, i} = peak_data(end-p_str.right_bl_length(i):end);
end
end