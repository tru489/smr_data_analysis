close all;
addpath(genpath("..\..\helpers"));

%% Load data
subdirs = ls("data_11_21_2024", true, true);
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
4	25;
4	25;
4	25;
4	25;
4	25;
4	25;
4	35;
4	35;
4	100;
4	30;
4	30;
];

rfs = [repmat(1158424,1,12), repmat(1158524,1,4)];

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
    mean_bm = get_mean_bms_and_save(subdir_contents, thresholds(i,:), ['results_11_21_2024\' b]);
    mean_bm_full = [mean_bm_full mean_bm];
end

%% calculate density and volume

dry_tab = table();
dry_tab.labels = labels_';
dry_tab.avg_buoyant_mass_h2o = mean_bm_full';
dry_tab.avg_density_h2o_gcm3 = dens_arr_full';
dry_tab.total_volume_fl = [146.301	144.004	164.967	161.258	168.339	167.206	166.958	165.633	129.98	131.967	137.665	136.245,...
    207.213	205.522	215.614	211.279	246.147	235.176	151.38	152.73	161.473	161.976]';
dry_tab.total_density_gcm3 = dry_tab.avg_buoyant_mass_h2o ./ dry_tab.total_volume_fl + dry_tab.avg_density_h2o_gcm3;

writetable(dry_tab, 'results_11_21_2024\tdens.csv')

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
