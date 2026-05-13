close all;
addpath(genpath("..\..\helpers"));

tight_path = "A:\thomasu\raw_data\2025-10-22\400fps_opt_focus\original_params_analysis\400fps_opt_focus 20251022.1348_CELLGROUPED CellInfo.csv";
tight_tab = readtable(tight_path);
tight_cal_vols = tight_tab.Volume;
expm_mask = ~isnan(tight_cal_vols) & tight_cal_vols > 150;
tight_cal_vols = tight_cal_vols(expm_mask);

st = load('data\images_saved.mat');

cell_img_bf = st.cell_img_bf;
cell_img_bf = cell_img_bf(expm_mask, :);

cell_img_fl = st.cell_img_fl;
cell_img_fl = cell_img_fl(expm_mask, :);

cell_img_ref = st.cell_img_ref;
cell_img_ref = cell_img_ref(expm_mask, :);

cell_intensities = cell(size(cell_img_ref));
for i = 1:length(cell_img_ref)
    ref_img_stack = cell_img_ref{i};
    fl_img_stack = cell_img_fl{i};

    intensities = zeros(size(ref_img_stack));
    for j = 1:length(ref_img_stack)
        ref_img = double(ref_img_stack{j});
        fl_img = double(fl_img_stack{j});
        intensities(j) = sum((ref_img - fl_img) ./ ref_img, 'all');
    end
    intensities = intensities(intensities>0);
    cell_intensities{i} = intensities;
end

ranges = zeros(size(cell_intensities));
cvs = zeros(size(cell_intensities));
slopes = zeros(size(cell_intensities));
for i = 1:length(cell_intensities)
    int_stack = cell_intensities{i};
    mu = mean(int_stack); sigma = std(int_stack);
    ranges(i) = abs(max(int_stack) - min(int_stack)) / mu;
    cvs(i) = sigma/mu;
    p = polyfit(1:length(int_stack), int_stack, 1);
    slopes(i) = p(1);
end

fh_ranges = figure; histogram(ranges*100, 50); xlabel('Range of px intensities in transits (% of mean)'); xline(20, 'r', LineWidth=1.5)
saveas(fh_ranges, 'fig_img_sequence\ranges_hist.jpg')
fh_cvs = figure; histogram(cvs, 50); xlabel('CVs of px intensities in transits')
saveas(fh_cvs, 'fig_img_sequence\cvs_hist.jpg')
fh_slopes = figure; histogram(slopes, 50); xlabel('Slopes of px intensities in transits')
saveas(fh_slopes, 'fig_img_sequence\slopes_hist.jpg')

%% Visualize images that have abnormally high ranges
closest_idx_50 = get_closest_from_expm(ranges, .5, 3);
closest_idx_100 = get_closest_from_expm(ranges, 1, 3);
closest_idx_5 = get_closest_from_expm(ranges, 0.05, 3);

for i = 1:length(closest_idx_50)
    bf_imgs = cell_img_bf{closest_idx_50(i)};
    fl_imgs = cell_img_fl{closest_idx_50(i)};
    ref_imgs = cell_img_ref{closest_idx_50(i)};
    
    fh_subtract = figure;
    for j = 1:length(fl_imgs)
        subplot(ceil(length(fl_imgs)/5), 5, j)
        fl_img_tmp = double(fl_imgs{j});
        ref_img_tmp = double(ref_imgs{j});
        imshow((ref_img_tmp - fl_img_tmp) ./ ref_img_tmp)
        title(sprintf('%.3f', sum((ref_img_tmp - fl_img_tmp) ./ ref_img_tmp, 'all')))
    end
    sgtitle('Normalized image')
    saveas(fh_subtract, "fig_img_sequence\" + string(num2str(i)) + "_closest_50pct_norm.jpg")
    
    fh_bf = figure;
    for j = 1:length(fl_imgs)
        subplot(ceil(length(fl_imgs)/5), 5, j)
        bf_img_tmp = double(bf_imgs{j});
        fl_img_tmp = double(fl_imgs{j});
        ref_img_tmp = double(ref_imgs{j});
        imshow(bf_img_tmp/255)
    end
    sgtitle('BF image')
    saveas(fh_bf, "fig_img_sequence\" + string(num2str(i)) + "_closest_50pct_bf.jpg")

    fh_fl = figure;
    for j = 1:length(fl_imgs)
        subplot(ceil(length(fl_imgs)/5), 5, j)
        bf_img_tmp = double(bf_imgs{j});
        fl_img_tmp = double(fl_imgs{j});
        ref_img_tmp = double(ref_imgs{j});
        imshow(fl_img_tmp/65535 * 15)
    end
    sgtitle('FL image')
    saveas(fh_fl, "fig_img_sequence\" + string(num2str(i)) + "_closest_50pct_fl.jpg")
end


for i = 1:length(closest_idx_100)
    bf_imgs = cell_img_bf{closest_idx_100(i)};
    fl_imgs = cell_img_fl{closest_idx_100(i)};
    ref_imgs = cell_img_ref{closest_idx_100(i)};
    
    fh_subtract = figure;
    for j = 1:length(fl_imgs)
        subplot(ceil(length(fl_imgs)/5), 5, j)
        fl_img_tmp = double(fl_imgs{j});
        ref_img_tmp = double(ref_imgs{j});
        imshow((ref_img_tmp - fl_img_tmp) ./ ref_img_tmp)
        title(sprintf('%.3f', sum((ref_img_tmp - fl_img_tmp) ./ ref_img_tmp, 'all')))
    end
    sgtitle('Normalized image')
    saveas(fh_subtract, "fig_img_sequence\" + string(num2str(i)) + "_closest_100pct_norm.jpg")
    
    fh_bf = figure;
    for j = 1:length(fl_imgs)
        subplot(ceil(length(fl_imgs)/5), 5, j)
        bf_img_tmp = double(bf_imgs{j});
        fl_img_tmp = double(fl_imgs{j});
        ref_img_tmp = double(ref_imgs{j});
        imshow(bf_img_tmp/255)
    end
    sgtitle('BF image')
    saveas(fh_bf, "fig_img_sequence\" + string(num2str(i)) + "_closest_100pct_bf.jpg")

    fh_fl = figure;
    for j = 1:length(fl_imgs)
        subplot(ceil(length(fl_imgs)/5), 5, j)
        bf_img_tmp = double(bf_imgs{j});
        fl_img_tmp = double(fl_imgs{j});
        ref_img_tmp = double(ref_imgs{j});
        imshow(fl_img_tmp/65535 * 15)
    end
    sgtitle('FL image')
    saveas(fh_fl, "fig_img_sequence\" + string(num2str(i)) + "_closest_100pct_fl.jpg")
end


for i = 1:length(closest_idx_5)
    bf_imgs = cell_img_bf{closest_idx_5(i)};
    fl_imgs = cell_img_fl{closest_idx_5(i)};
    ref_imgs = cell_img_ref{closest_idx_5(i)};
    
    fh_subtract = figure;
    for j = 1:length(fl_imgs)
        subplot(ceil(length(fl_imgs)/5), 5, j)
        fl_img_tmp = double(fl_imgs{j});
        ref_img_tmp = double(ref_imgs{j});
        imshow((ref_img_tmp - fl_img_tmp) ./ ref_img_tmp)
        title(sprintf('%.3f', sum((ref_img_tmp - fl_img_tmp) ./ ref_img_tmp, 'all')))
    end
    sgtitle('Normalized image')
    saveas(fh_subtract, "fig_img_sequence\" + string(num2str(i)) + "_closest_5pct_norm.jpg")
    
    fh_bf = figure;
    for j = 1:length(fl_imgs)
        subplot(ceil(length(fl_imgs)/5), 5, j)
        bf_img_tmp = double(bf_imgs{j});
        fl_img_tmp = double(fl_imgs{j});
        ref_img_tmp = double(ref_imgs{j});
        imshow(bf_img_tmp/255)
    end
    sgtitle('BF image')
    saveas(fh_bf, "fig_img_sequence\" + string(num2str(i)) + "_closest_5pct_bf.jpg")

    fh_fl = figure;
    for j = 1:length(fl_imgs)
        subplot(ceil(length(fl_imgs)/5), 5, j)
        bf_img_tmp = double(bf_imgs{j});
        fl_img_tmp = double(fl_imgs{j});
        ref_img_tmp = double(ref_imgs{j});
        imshow(fl_img_tmp/65535 * 15)
    end
    sgtitle('FL image')
    saveas(fh_fl, "fig_img_sequence\" + string(num2str(i)) + "_closest_5pct_fl.jpg")
end

%% Compare volume distributions with single-cell outlier exclusion in fxm
coulter_path = "A:\thomasu\raw_data\2025-10-22\coulter\single_cell_volumes.csv";
cc_tab = readtable(coulter_path);
cc_vol_samp = cc_tab.l1210wt_rep1(cc_tab.l1210wt_rep1 > 400 & cc_tab.l1210wt_rep1 < 2500);

tight_cal_vols_sl = tight_cal_vols(ranges < 0.20);

fh_swarms = figure; 
add_swarmchart(fh_swarms, 'coulter', cc_vol_samp)
add_swarmchart(fh_swarms, 'fxm\_nonexcluded', tight_cal_vols)
add_swarmchart(fh_swarms, 'fxm\_excluded', tight_cal_vols_sl)
saveas(fh_swarms, "fig_img_sequence\swarm_comparison.jpg")


%% Functions
function [ith_closest_index] = get_closest_from_expm(vols, target, num_closest)
    % 1. Calculate the absolute differences
    % abs_diffs is an array of the absolute difference between each element in 'arr' and the 'target_value'
    abs_diffs = abs(vols - target);
    
    % 2. Sort the absolute differences
    % sort_diffs contains the sorted difference values
    % sort_indices contains the indices of these sorted values in the original 'arr'
    [~, sort_indices] = sort(abs_diffs); %
    
    % 3. The first index (sort_indices(1)) corresponds to the closest value.
    % The second index (sort_indices(2)) corresponds to the second closest value.
    ith_closest_index = sort_indices(1:num_closest);
    
    % 4. Get the second closest element from the original array
    % ith_closest_elt = vols(ith_closest_index);
end