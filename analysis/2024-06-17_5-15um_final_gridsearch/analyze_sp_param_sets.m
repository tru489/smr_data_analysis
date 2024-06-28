close all;
addpath(genpath("..\..\helpers"));

drive_lett = "A";
search_path = drive_lett + ":\thomasu\raw_data\2024-03-19\dens_trap_fitting_gridsearch\data_cleaned.mat";
st = load(search_path);
data_cell = st.compiled_4d;

% Parameter values
fitting_orders = 2:1:6; % order of polynomial fit of baseline
node_weights = 0:0.2:1; % weight of node points as a fraction of total peakset width
bl_fit_length = 0.25 * (0.5:1:7.5); % Length of baseline to fit as a fraction of 1/4 of the total peakset width
bl_fit_offset = 0:10:30; % Offset in datapoints between peak and baseline fitted area

%% Baseline params
bl_tab = readtable("A:\thomasu\raw_data\2024-03-15\6_8_10_dens_trap_reformat\20240315.170945_density_trap_results\peakset_summary_paired.csv");
bl_tab = bl_tab(bl_tab.density_gcm3 > 1.04 & bl_tab.density_gcm3 < 1.056 & bl_tab.volume_fl < 600, :);

[~, vol_dict] = get_bead_diams();
bead_vols = vol_dict([6, 8, 10]);

dv_arr_orig = [bl_tab.density_gcm3, bl_tab.volume_fl];
[idx, ctrs] = kmeans(dv_arr_orig, 3, Start=[[1.05, 1.05, 1.05]', bead_vols']);
bead_orig_set = {dv_arr_orig(idx==3, :), dv_arr_orig(idx==2, :), dv_arr_orig(idx==1, :)};

%% Balanced param set
param_idxs = [4-1, 3-1, 4+1, 3];
data_st = data_cell{param_idxs(1), param_idxs(2), param_idxs(3), param_idxs(4)};
dv_arr_opt = data_st.raw_table; dv_arr_opt_set = data_st.raw_table_seg;

% Whole scatter
fh1 = figure(Visible='off', Position=[2547 361 811 420]); hold on;
s1 = scatter(dv_arr_orig(:,1), dv_arr_orig(:,2), 25, 'blue', 'filled', DisplayName='Original parameter set');
s1.MarkerFaceAlpha = 0.5;
s2 = scatter(dv_arr_opt(:,1), dv_arr_opt(:,2), 25, 'red', 'filled', DisplayName='Optimized parameter set');
s2.MarkerFaceAlpha = 0.5;
legend(Location='eastoutside')
ax=gca; ax.FontSize = 15;
xlabel('Dry Mass Density (g/cm3)', FontSize=20); ylabel('Dry Mass Volume (fL)', FontSize=20)
saveas(fh1, 'fig\selected_sets\balanced\full.eps')

fnames = ["10um", "8um", "6um"];
orig_cv_dens = zeros(1, length(bead_orig_set)); orig_cv_vol = zeros(1, length(bead_orig_set)); 
new_cv_dens = zeros(1, length(bead_orig_set)); new_cv_vol = zeros(1, length(bead_orig_set));
for i = 1:length(bead_orig_set)
    fh_t = figure(Visible='off'); hold on;
    orig_seg_t = bead_orig_set{i};
    s1 = scatter(orig_seg_t(:,1), orig_seg_t(:,2), 25, 'blue', 'filled', DisplayName='Original parameters');
    fprintf('%s | orig CV density = %f / orig cv volume = %f\n', fnames(i), std(orig_seg_t(:,1)) / mean(orig_seg_t(:,1)), std(orig_seg_t(:,2)) / mean(orig_seg_t(:,2)))
    orig_cv_dens(i) = std(orig_seg_t(:,1)) / mean(orig_seg_t(:,1));
    orig_cv_vol(i) = std(orig_seg_t(:,2)) / mean(orig_seg_t(:,2));
    
    s1.MarkerFaceAlpha = 0.5;


    opt_seg_t = dv_arr_opt_set{i};
    s2 = scatter(opt_seg_t(:,1), opt_seg_t(:,2), 25, 'red', 'filled', DisplayName='Balanced parameter set');
    fprintf('%s | new CV density = %f / new cv volume = %f\n', fnames(i), std(opt_seg_t(:,1)) / mean(opt_seg_t(:,1)), std(opt_seg_t(:,2)) / mean(opt_seg_t(:,2)))
    s2.MarkerFaceAlpha = 0.5;
    % legend(Location='eastoutside')
    xlabel('Dry Mass Density (g/cm3)', FontSize=20); ylabel('Dry Mass Volume (fL)', FontSize=20); title(fnames(i) + " beads")
    saveas(fh_t, "fig\selected_sets\balanced\" + fnames(i) + ".jpg")
    new_cv_dens(i) = std(opt_seg_t(:,1)) / mean(opt_seg_t(:,1));
    new_cv_vol(i) = std(opt_seg_t(:,2)) / mean(opt_seg_t(:,2));
end
fprintf('Mean orig CV density = %f | Mean orig CV vol = %f\n', mean(orig_cv_dens), mean(orig_cv_vol))
fprintf('Mean new CV density = %f | Mean new CV vol = %f\n', mean(new_cv_dens), mean(new_cv_vol))


%% Accuracy optimized
param_idxs = [1, 1, 7, 3];
data_st = data_cell{param_idxs(1), param_idxs(2), param_idxs(3), param_idxs(4)};
dv_arr_opt = data_st.raw_table; dv_arr_opt_set = data_st.raw_table_seg;

% Whole scatter
fh1 = figure(Visible='off', Position=[2547 361 811 420]); hold on;
s1 = scatter(dv_arr_orig(:,1), dv_arr_orig(:,2), 25, 'blue', 'filled', DisplayName='Original parameters');
s1.MarkerFaceAlpha = 0.5;
s2 = scatter(dv_arr_opt(:,1), dv_arr_opt(:,2), 25, 'red', 'filled', DisplayName='Accuracy-optimized parameter set');
s2.MarkerFaceAlpha = 0.5;
ax=gca; ax.FontSize = 14;
legend(Location='eastoutside')
xlabel('Dry Mass Density (g/cm3)', FontSize=20); ylabel('Dry Mass Volume (fL)', FontSize=20)
saveas(fh1, 'fig\selected_sets\accuracy\full.jpg')

fnames = ["10um", "8um", "6um"];
for i = 1:length(bead_orig_set)
    fh_t = figure(Visible='off'); hold on;
    orig_seg_t = bead_orig_set{i};
    s1 = scatter(orig_seg_t(:,1), orig_seg_t(:,2), 25, 'blue', 'filled', DisplayName='Original parameters');
    s1.MarkerFaceAlpha = 0.5;

    opt_seg_t = dv_arr_opt_set{i};
    s2 = scatter(opt_seg_t(:,1), opt_seg_t(:,2), 25, 'red', 'filled', DisplayName='Accuracy-optimized parameter set');
    s2.MarkerFaceAlpha = 0.5;
    % legend(Location='eastoutside')
    xlabel('Dry Mass Density (g/cm3)', FontSize=20); ylabel('Dry Mass Volume (fL)', FontSize=20); title(fnames(i) + " beads")
    saveas(fh_t, "fig\selected_sets\accuracy\" + fnames(i) + ".jpg")
end

%% Precision optimized
% param_idxs = [5, 6, 1, 3];
param_idxs = [5,1,6,1];
data_st = data_cell{param_idxs(1), param_idxs(2), param_idxs(3), param_idxs(4)};
dv_arr_opt = data_st.raw_table; dv_arr_opt_set = data_st.raw_table_seg;

% Whole scatter
fh1 = figure(Visible='off', Position=[2547 361 811 420]); hold on;
s1 = scatter(dv_arr_orig(:,1), dv_arr_orig(:,2), 25, 'blue', 'filled', DisplayName='Original parameters');
s1.MarkerFaceAlpha = 0.5;
s2 = scatter(dv_arr_opt(:,1), dv_arr_opt(:,2), 25, 'red', 'filled', DisplayName='Optimized parameter set');
s2.MarkerFaceAlpha = 0.5;
legend(Location='eastoutside')
ax=gca; ax.FontSize = 14;
xlabel('Dry Mass Density (g/cm3)', FontSize=20); ylabel('Dry Mass Volume (fL)', FontSize=20)
saveas(fh1, 'fig\selected_sets\precision\full.jpg')

fnames = ["10um", "8um", "6um"];
for i = 1:length(bead_orig_set)
    fh_t = figure(Visible='off'); hold on;
    orig_seg_t = bead_orig_set{i};
    s1 = scatter(orig_seg_t(:,1), orig_seg_t(:,2), 25, 'blue', 'filled', DisplayName='Original parameters');
    s1.MarkerFaceAlpha = 0.5;

    opt_seg_t = dv_arr_opt_set{i};
    s2 = scatter(opt_seg_t(:,1), opt_seg_t(:,2), 25, 'red', 'filled', DisplayName='Precision-optimized parameter set');
    s2.MarkerFaceAlpha = 0.5;
    % legend(Location='eastoutside')
    xlabel('Dry Mass Density (g/cm3)', FontSize=20); ylabel('Dry Mass Volume (fL)', FontSize=20); title(fnames(i) + " beads")
    saveas(fh_t, "fig\selected_sets\precision\" + fnames(i) + ".jpg")
end

fh_orig = figure; hold on;
[diam_dict, vol_dict] = get_bead_diams();

s1 = scatter(dv_arr_orig(:,1), dv_arr_orig(:,2), 25, 'blue', 'filled');
s1.MarkerFaceAlpha = 0.5;
s1 = scatter([1.05,1.05,1.05], vol_dict([6 8 10]), 70, '+', 'red', LineWidth=3); 
xlabel('Dry Mass Density (g/cm3)', FontSize=14); ylabel('Dry Mass Volume (fL)', FontSize=14);
ax=gca; ax.FontSize=13;

