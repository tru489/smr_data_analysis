close all;
addpath(genpath("..\..\helpers"));

%% Load data
subdirs = ls("data_11_18_2024", true, true);
% for i = 1:length(subdirs)
%     dir_i = ls(subdirs{i});
%     plot_pths_for_thresholding(dir_i, 'dir_i')
%     input('continue?')
% end

labels_ = [];
for i = 1:length(subdirs)
    dir_i = ls(subdirs{i});
    labels_ = [labels_ string(dir_i)];
end

thresholds = [...
4	20;
4	20;
4	20;
4	20;
4	20;
4	20;
4	20];

rfs = [repmat(1158224,1,8), repmat(1158324,1,6)];

slope = -174731.71074873616;
intc = 1.3341472962939898E+6;

%% Density baseline calculation
dens_arr_full = [];
mean_bm_full = [];
for i = 1:length(subdirs)
    subdir_contents = ls(subdirs{i});
    dens_arr = get_avg_density(subdir_contents, thresholds(i,:), slope, intc, rfs(i));
    dens_arr_full = [dens_arr_full dens_arr];

    [~, b] = fileparts(subdirs{i});
    mean_bm = get_mean_bms_and_save(subdir_contents, thresholds(i,:), ['results_11_18_2024\' b]);
    mean_bm_full = [mean_bm_full mean_bm];
end

%% calculate density and volume

dry_tab = table();
dry_tab.labels = labels_';
dry_tab.avg_buoyant_mass_h2o = mean_bm_full';
dry_tab.avg_density_h2o_gcm3 = dens_arr_full';
dry_tab.total_volume_fl = [148.307	142.326	150.776	146.274	131.577	131.31	133.106	134.503,...
    203.158	200.908	218.119	213.095	201.273	205.18]';
dry_tab.total_density_gcm3 = dry_tab.avg_buoyant_mass_h2o ./ dry_tab.total_volume_fl + dry_tab.avg_density_h2o_gcm3;

writetable(dry_tab, 'results_11_18_2024\tdens.csv')

%%
function plot_pths_for_thresholding(pths, title_)

for i = 1:length(pths)
    tab_t = readtable(pths{i});
    figure; histogram(tab_t.mass_pg, 150)
    title(title_)
end

end

function dens_arr = get_avg_density(pths, thresh, slope, intc, rf)

ref_freqs = zeros(size(pths));
for i = 1:length(pths)
    tab_t = readtable(pths{i});
    tab_t = tab_t(tab_t.mass_pg > thresh(1) & tab_t.mass_pg < thresh(2), :);
    ref_freqs(i) = rf - mean(tab_t.avg_baseline);
end

dens_arr = (ref_freqs - intc) / slope;

end

function bms = get_mean_bms_and_save(pths, thresh, save_dir)

bms = zeros(size(pths));
for i = 1:length(pths)
    tab_t = readtable(pths{i});
    tab_t = tab_t(tab_t.mass_pg > thresh(1) & tab_t.mass_pg < thresh(2), :);
    bms(i) = mean(tab_t.mass_pg);
    
    [~, fname, ext] = fileparts(pths{i});
    writetable(tab_t, fullfile(save_dir, [fname, ext]))
end

end
