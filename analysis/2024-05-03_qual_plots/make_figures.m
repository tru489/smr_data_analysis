close all;
addpath(genpath("..\..\helpers"));

%% Density trapping data
bl_tab = readtable("A:\thomasu\raw_data\2024-03-15\6_8_10_dens_trap_reformat\20240315.170945_density_trap_results\peakset_summary_paired.csv");
bl_tab = bl_tab(bl_tab.density_gcm3 > 1.04 & bl_tab.density_gcm3 < 1.056 & bl_tab.volume_fl < 600, :);

bead_gt_dens_emp = [1.0512    1.0496    1.0500    1.0498    1.0493    1.0492    1.0499];
bead_gt_vol_emp = [70.2306  119.4408  177.8726  260.3480  374.1590  526.6167  917.4986];

[~, vol_dict] = get_bead_diams();
bead_vols = vol_dict([6, 8, 10]);

dv_arr_orig = [bl_tab.density_gcm3, bl_tab.volume_fl];

fh = figure(Position=[680   425   607   453]); hold on;
s1 = scatter(dv_arr_orig(:,1), dv_arr_orig(:,2), 40, 'blue', 'filled', DisplayName='Two-fluid measurements');
s1.MarkerFaceAlpha = 0.35;
s1 = scatter([1.0496, 1.0498, 1.0492], [119.4408, 260.3480, 526.6167], 190, '+', 'red', LineWidth=4, DisplayName='Ground Truth'); 
ax=gca; ax.FontSize=15;
xlabel('Dry Mass Density (g/cm3)', FontSize=20); ylabel('Dry Mass Volume (fL)', FontSize=20);
saveas(fh, 'figs\fig1.eps')
legend(Location='eastoutside')
saveas(fh, 'figs\fig1_lgd.eps')

%% Volume data
figure;
Vol_data = load_coulter_data("A:\thomasu\raw_data\2024-04-25\l1210_dmso_1\DMSO_1.#m4");
count = Vol_data.count; vol_bins = Vol_data.volume_fL;
count(vol_bins < 400 | vol_bins > 2500) = 0;

h = histogram('BinEdges',[0;vol_bins]','BinCounts',count / sum(count), ...
    FaceColor='red', EdgeColor='red', DisplayName='SMS');
xlim([400, 2500])
hold on;
t = readtable("A:\thomasu\raw_data\2024-04-25\l1210_dmso_1\20240506.161630_water_content_results\pmt_smr_paired.csv");
histogram(t.volume_fl, 50)
h.FaceAlpha = 0.2; h.EdgeAlpha = 0.2;

%% Example emp peaks
% Select A:\thomasu\raw_data\2024-03-15\6_8_10_dens_trap_reformat
[freqfile, data_dir] = get_raw_file_handle('', "A:\thomasu\raw_data\2024-03-15\6_8_10_dens_trap_reformat\20231217.1121_frequencies");
% [timefile, ~] = get_raw_file_handle('time');

freq = fread(freqfile, 'float64=>double');

sl1 = freq(25084500-140:25085500+30);
fh_emp1 = figure; plot(0:length(sl1)-1, sl1, LineWidth=4);
xlim([0,length(sl1)-1])
set(gca,'YTickLabel',[]); set(gca,'XTickLabel',[]);
set(gca,'XTick',[]); set(gca,'YTick',[]);
box off
xlabel('Time', FontSize=30, FontWeight='bold');
ylabel('Frequency', FontSize=30, FontWeight='bold')
set(gca,'linewidth',6)
saveas(fh_emp1, 'figs\emp1.jpg')

sl2 = freq(6672200+530:6673800-130);
fh_emp2 = figure; plot(0:length(sl2)-1, sl2, LineWidth=4);
xlim([0,length(sl2)-1])
set(gca,'YTickLabel',[]); set(gca,'XTickLabel',[]);
set(gca,'XTick',[]); set(gca,'YTick',[]);
box off
xlabel('Time', FontSize=30, FontWeight='bold');
ylabel('Frequency', FontSize=30, FontWeight='bold')
set(gca,'linewidth',6)
saveas(fh_emp2, 'figs\emp2.jpg')

sl3 = freq(44837000+230:44839000-610);
fh_emp3 = figure; plot(0:length(sl3)-1, sl3, LineWidth=4);
xlim([0,length(sl3)-1])
set(gca,'YTickLabel',[]); set(gca,'XTickLabel',[]);
set(gca,'XTick',[]); set(gca,'YTick',[]);
box off
xlabel('Time', FontSize=30, FontWeight='bold');
ylabel('Frequency', FontSize=30, FontWeight='bold')
set(gca,'linewidth',6)
saveas(fh_emp3, 'figs\emp3.jpg')

sl4 = freq(5.68598e7-150:5.68606e7+80);
fh_emp3 = figure; plot(0:length(sl4)-1, sl4, LineWidth=4);
xlim([0,length(sl4)-1])
set(gca,'YTickLabel',[]); set(gca,'XTickLabel',[]);
set(gca,'XTick',[]); set(gca,'YTick',[]);
box off
xlabel('Time', FontSize=30, FontWeight='bold');
ylabel('Frequency', FontSize=30, FontWeight='bold')
set(gca,'linewidth',6)
saveas(fh_emp3, 'figs\emp4.jpg')

sl5 = freq(5.26976e7+250:5.26992e7+100);
fh_emp3 = figure; plot(0:length(sl5)-1, sl5, LineWidth=4);
xlim([0,length(sl5)-1])
set(gca,'YTickLabel',[]); set(gca,'XTickLabel',[]);
set(gca,'XTick',[]); set(gca,'YTick',[]);
box off
xlabel('Time', FontSize=30, FontWeight='bold');
ylabel('Frequency', FontSize=30, FontWeight='bold')
set(gca,'linewidth',6)
saveas(fh_emp3, 'figs\emp5.jpg')