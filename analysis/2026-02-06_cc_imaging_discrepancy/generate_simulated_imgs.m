close all;
addpath(genpath("..\..\helpers"));

%% Get coulter summary stats
coulter_path = "A:\thomasu\raw_data\2025-10-22\coulter\single_cell_volumes.csv";
cc_tab = readtable(coulter_path);
cc_vol_samp = cc_tab.l1210wt_rep1(cc_tab.l1210wt_rep1 > 400 & cc_tab.l1210wt_rep1 < 2500);

mu_cc = mean(cc_vol_samp); std_cc = std(cc_vol_samp);
% sampling_vols_cc = [mu_cc, mu_cc + std_cc, mu_cc + std_cc*2, mu_cc - std_cc, mu_cc - std_cc*2];
sampling_vols_cc = [mu_cc, mu_cc + std_cc, mu_cc - std_cc];


%% Get fl img sizes for reference
cellgroup_struct = "A:\thomasu\raw_data\2025-10-22\400fps_opt_focus\original_params_analysis\400fps_opt_focus 20251022.1348_CELLGROUPED Object.mat";
this = load(cellgroup_struct).this;
cell_info = this.CellInfo;

image_dims = zeros(length(cell_info),2);
for i = 1:length(cell_info)
    image_dims(i, :) = mean(cell_info(i).ImageSizeFL, 1);
end
mean_img_dim = floor(mean(image_dims, 1));

%% Load volume data from expm
tight_path = "A:\thomasu\raw_data\2025-10-22\400fps_opt_focus\original_params_analysis\400fps_opt_focus 20251022.1348_CELLGROUPED CellInfo.csv";
tight_tab = readtable(tight_path);
tight_cal_vols = tight_tab.Volume;
expm_mask = ~isnan(tight_cal_vols) & tight_cal_vols > 150;
tight_cal_vols = tight_cal_vols(expm_mask);
mu_expm = mean(tight_cal_vols);
std_expm = std(tight_cal_vols);

target_expm_vols = [mu_expm, mu_expm+1*std_expm mu_expm-1*std_expm];

num_closest = 3;
% [~, mu_idx] = min(abs(tight_cal_vols - mu_expm));
% [~, mu_1std_above_idx] = min(abs(tight_cal_vols - (mu_expm+1*std_expm)));
% % [~, mu_2std_above_idx] = min(abs(tight_cal_vols - (mu_expm+2*std_expm)));
% [~, mu_1std_below_idx] = min(abs(tight_cal_vols - (mu_expm-1*std_expm)));
% [~, mu_2std_below_idx] = min(abs(tight_cal_vols - (mu_expm-2*std_expm)));
% sampling_idxs_expm = [mu_idx, mu_1std_above_idx, mu_2std_above_idx, mu_1std_below_idx, mu_2std_below_idx];

[~, mu_idx] = get_closest_from_expm(tight_cal_vols, mu_expm, num_closest);
[~, mu_1std_above_idx] = get_closest_from_expm(tight_cal_vols, mu_expm+1*std_expm, num_closest);
[~, mu_1std_below_idx] = get_closest_from_expm(tight_cal_vols, mu_expm-1*std_expm, num_closest);
sampling_idxs_expm = [mu_idx, mu_1std_above_idx, mu_1std_below_idx];

%% Parse expm image data for comparison
% addpath('C:\thomasu\ImageFXMAnalysis')
% hdf5FilePath = "A:\thomasu\raw_data\2025-10-22\400fps_opt_focus\original_params_analysis\20251022.1348_CELLGROUPED.hdf5";
% 
% analysis = VolumeExclusionAnalysis();
% cell_img_bf = cell(length(this.CellInfo), 1);
% cell_img_fl = cell(length(this.CellInfo), 1);
% cell_img_ref = cell(length(this.CellInfo), 1);
% for i = 1:length(this.CellInfo)
%     fprintf('  Parsed cell img set %i of %i\n', i, length(this.CellInfo))
%     hdf5PathsBF = this.CellInfo(i).Hdf5PathsBF;
%     hdf5PathsFL = this.CellInfo(i).Hdf5PathsFL;
%     [BrightfieldImageData, FluorescentImageData, ReferenceImageData] = ...
%         analysis.ReadImageDataFromHdf5FileStatic(hdf5FilePath, hdf5PathsBF, hdf5PathsFL);
%     cell_img_bf{i} = BrightfieldImageData;
%     cell_img_fl{i} = FluorescentImageData;
%     cell_img_ref{i} = ReferenceImageData;
% end
% save('data\images_saved.mat', "cell_img_ref", "cell_img_fl", "cell_img_bf")

st = load('data\images_saved.mat');

cell_img_fl = st.cell_img_fl;
cell_img_fl = cell_img_fl(expm_mask, :);

cell_img_ref = st.cell_img_ref;
cell_img_ref = cell_img_ref(expm_mask, :);

num_subdivision_pts = 4;
stack_sampling_pts = (1:num_subdivision_pts) / (num_subdivision_pts + 1);

sampling_imgs_expm = cell(length(sampling_idxs_expm), num_subdivision_pts);
sampling_imgs_intensities = zeros(length(sampling_idxs_expm), num_subdivision_pts);
for j = 1:num_subdivision_pts
    stack_sample = stack_sampling_pts(j);
    for i = 1:length(sampling_idxs_expm)
        fl_img_stack_tmp = cell_img_fl{sampling_idxs_expm(i)};
        fl_img_tmp = fl_img_stack_tmp{floor(length(fl_img_stack_tmp) * stack_sample)};
        fl_img_tmp = double(fl_img_tmp);
    
        ref_img_stack_tmp = cell_img_ref{sampling_idxs_expm(i)};
        ref_img_tmp = ref_img_stack_tmp{floor(length(ref_img_stack_tmp) * stack_sample)};
        ref_img_tmp = double(ref_img_tmp);
    
        sampling_imgs_expm{i, j} = (ref_img_tmp - fl_img_tmp) ./ ref_img_tmp;
        sampling_imgs_intensities(i,j) = sum(sampling_imgs_expm{i, j}, 'all');
    end
end

%% Create corresponding fluorescence images
PixelVolume = 6.4582;
nx = mean_img_dim(1); ny = mean_img_dim(2);
x0 = floor(nx/2); y0 = floor(ny/2);
sigma_x = mean_img_dim(1)/4; sigma_y = mean_img_dim(2)/4;

sampling_imgs_sim = cell(length(sampling_vols_cc), 1);
for i = 1:length(sampling_vols_cc)
    total_intensity = sampling_vols_cc(i) / PixelVolume;
    G = gaussian2d_with_total_intensity(nx, ny, ...
                                        x0, y0, ...
                                        sigma_x, sigma_y, ...
                                        total_intensity);
    sampling_imgs_sim{i} = G;
end

matched_intensities_toexpm = cell(length(sampling_vols_cc), num_subdivision_pts);
for i = 1:length(sampling_vols_cc)
    for j = 1:num_subdivision_pts
        total_intensity = sampling_imgs_intensities(i,j);
        G = gaussian2d_with_total_intensity(nx, ny, ...
                                            x0, y0, ...
                                            sigma_x, sigma_y, ...
                                            total_intensity);
        matched_intensities_toexpm{i,j} = G;
    end
end

expm_tag = string(num2str(num_closest)) + "_closest";
fig_names = ["", "+1", "-1"] + "mu.jpg";
for i = 1:length(sampling_vols_cc)
    fh = figure(Position=[844    38   596   956]);
    for j = 1:num_subdivision_pts
        subplot(num_subdivision_pts,3,3*j-2); imshow(sampling_imgs_expm{i, j}*1.5);
        title_str = sprintf('Expm, %.3f', sum(sampling_imgs_expm{i, j}, 'all'));
        title(title_str); 

        subplot(num_subdivision_pts,3,3*j-1); imshow(sampling_imgs_sim{i}*1.5); 
        title_str = sprintf('Sim, %.3f', sum(sampling_imgs_sim{i}, 'all'));
        title(title_str);

        subplot(num_subdivision_pts,3,3*j); imshow(matched_intensities_toexpm{i,j}*1.5); 
        title_str = sprintf('Sim\\_intns-match, %.3f', sum(matched_intensities_toexpm{i,j}, 'all'));
        title(title_str);
    end
    sgtitle(sprintf('CC volume = %.3f | Fxm volume = %.3f (match = %.3f)', sampling_vols_cc(i), target_expm_vols(i), tight_cal_vols(sampling_idxs_expm(i))))
    saveas(fh, "fig_simulated_imgs\" + expm_tag + "_" + fig_names(i))
end




%% Functions
function G = gaussian2d_with_total_intensity(nx, ny, ...
                                              x0, y0, ...
                                              sigma_x, sigma_y, ...
                                              total_intensity)
% nx, ny           : image width and height (pixels)
% x0, y0           : Gaussian center (in pixel coordinates)
% sigma_x, sigma_y : standard deviations (pixels)
% total_intensity  : desired sum of all pixel values

    % Create coordinate grid
    [X, Y] = meshgrid(1:nx, 1:ny);

    % Unnormalized 2D Gaussian
    G = exp( ...
        -((X - x0).^2 / (2*sigma_x^2) + ...
          (Y - y0).^2 / (2*sigma_y^2)) ...
        );

    % Normalize so sum = 1
    G = G / sum(G(:));

    % Scale to desired total intensity
    G = G * total_intensity;
end

function [ith_closest_elt, ith_closest_index] = get_closest_from_expm(vols, target, num_closest)
    % 1. Calculate the absolute differences
    % abs_diffs is an array of the absolute difference between each element in 'arr' and the 'target_value'
    abs_diffs = abs(vols - target);
    
    % 2. Sort the absolute differences
    % sort_diffs contains the sorted difference values
    % sort_indices contains the indices of these sorted values in the original 'arr'
    [~, sort_indices] = sort(abs_diffs); %
    
    % 3. The first index (sort_indices(1)) corresponds to the closest value.
    % The second index (sort_indices(2)) corresponds to the second closest value.
    ith_closest_index = sort_indices(num_closest);
    
    % 4. Get the second closest element from the original array
    ith_closest_elt = vols(ith_closest_index);
end