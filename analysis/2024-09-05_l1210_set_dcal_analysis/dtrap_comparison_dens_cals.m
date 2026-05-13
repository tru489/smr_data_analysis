close all;
addpath(genpath("..\..\helpers"));

color_arr = [...
    [0 0 244]; ...
    [225 49 39];  ...
    [86 185 55];  ...
    [159 34 208];  ...
    [239 134 51];  ...
    [ 0 0 0];  ...
    [137 103 45]];
color_arr = color_arr / 255;

%% Baseline plot
baseline_pth = "C:\thomasu\smr_data_analysis\analysis\2024-09-05_l1210_set_dcal_analysis\data\temps\21c_dens_unscale.csv";
tab_bl = readtable(baseline_pth);

mask = tab_bl.density_gcm3 > 1.2 & tab_bl.density_gcm3 < 1.55 & tab_bl.volume_fl > 0 & tab_bl.volume_fl < 250;
fh1 = figure;
s = scatter(tab_bl.volume_fl(mask), tab_bl.density_gcm3(mask), [], 'r', 'filled');
s.MarkerFaceAlpha=0.3;
ax=gca; ax.FontSize=13;
xlabel('Dry Volume (fL)', FontSize=14); ylabel('Dry Density (g/cm^3)', FontSize=14); 
saveas(fh1, 'fig\baseline.jpg')

%% Compare longitudinal results
tab_pth = ls('data\long');

labels = ["2023-12-11", "2024-01-29", "2024-02-16", "2024-02-20", "2024-02-24", "2024-03-03", "2024-03-04"];

fh2 = figure(Position=[2488         291         678         419]); hold on;
for i = 1:length(tab_pth)
    tab_temp = readtable(tab_pth{i});
    s = scatter(tab_temp.volume_fl(mask), tab_temp.density_gcm3(mask), [], color_arr(i,:), 'filled', DisplayName=labels(i));
    s.MarkerFaceAlpha=0.3;
end
ax=gca; ax.FontSize=13;
xlabel('Dry Volume (fL)', FontSize=14); ylabel('Dry Density (g/cm^3)', FontSize=14); 

legend(Location='eastoutside')
saveas(fh2, 'fig\longitudinal.jpg')

%% Compare multifluid results
tab_pth = ls('data\multifluids');

labels = ["D2O dilutions", "D-glucose", "NaCl"];

fh3 = figure(Position=[2488         291         678         419]); hold on;
for i = 1:length(tab_pth)
    tab_temp = readtable(tab_pth{i});
    s = scatter(tab_temp.volume_fl(mask), tab_temp.density_gcm3(mask), [], color_arr(i,:), 'filled', DisplayName=labels(i));
    s.MarkerFaceAlpha=0.3;
end
ax=gca; ax.FontSize=13;
xlabel('Dry Volume (fL)', FontSize=14); ylabel('Dry Density (g/cm^3)', FontSize=14); 

legend(Location='eastoutside')
saveas(fh3, 'fig\multifluid.jpg')

%% Compare temp results
tab_pth = ls('data\temps');

labels = ["4C; rescaled density", "4C; density unscaled", "21C", "26C; density rescaled", "26C; density unscaled"];

fh4 = figure(Position=[2488         291         678         419]); hold on;
for i = 1:length(tab_pth)
    tab_temp = readtable(tab_pth{i});
    s = scatter(tab_temp.volume_fl(mask), tab_temp.density_gcm3(mask), [], color_arr(i,:), 'filled', DisplayName=labels(i));
    s.MarkerFaceAlpha=0.3;
end
ax=gca; ax.FontSize=13;
xlabel('Dry Volume (fL)', FontSize=14); ylabel('Dry Density (g/cm^3)', FontSize=14); 

legend(Location='eastoutside')
saveas(fh4, 'fig\temp.jpg')