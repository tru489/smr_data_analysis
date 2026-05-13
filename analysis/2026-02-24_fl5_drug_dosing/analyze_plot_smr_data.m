close all;
addpath(genpath("..\..\helpers"));

slope = -184141.88441731408;
intc = 1.2382707462637972E+6;
ref_freq = 1052270;

%% Set gates for SMR data
bm_files_path = "A:\thomasu\raw_data\2026-02-23_fl5_drugs\bm_csv_aggr";
bm_files_list = ls(bm_files_path);

mean_bms = zeros(length(bm_files_list), 1); % verteporfin 500nM, ZT-1a 5um, dmso (all rep2, dmso is separate sample)
fl_density_arr = zeros(length(bm_files_list), 1);
for i = 1:length(bm_files_list)
    bm_tab = readtable(bm_files_list{i});
    % figure; histogram(bm_tab.mass_pg, 150); title(bm_files_list{i})
    if i == 1
        bm_tab = bm_tab(bm_tab.mass_pg < 40 & bm_tab.mass_pg > 5,:);
        mean_bms(i) = mean(bm_tab.mass_pg);
    else
        bm_tab = bm_tab(bm_tab.mass_pg < 90 & bm_tab.mass_pg > 16,:);
        mean_bms(i) = mean(bm_tab.mass_pg);
    end
    fl_density(i) = (ref_freq - mean(bm_tab.avg_baseline) - intc) / slope;
end
fl_density_mean = mean(fl_density);
mean_volumes = [325.756, 606.325, 754.7];

densities = fl_density_mean + mean_bms' ./ mean_volumes;


%% Plot
plot_labels = ["Verteporfin\_500nM\_rep2", "ZT-1a\_5uM\_rep2", "Proliferating\_DMSO"];

fh = figure;
bar(categorical(plot_labels), densities)
ylim([1.05,1.08])
ylabel('Density (g/cm^3)', FontSize=13)
ax=gca; ax.FontSize=12;
saveas(fh, 'fig\density_bars.jpg')