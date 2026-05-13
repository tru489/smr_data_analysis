close all;
addpath(genpath("..\..\helpers"));

tight_path = "A:\thomasu\raw_data\2025-10-22\400fps_opt_focus\original_params_analysis\400fps_opt_focus 20251022.1348_CELLGROUPED CellInfo.csv";
tight_tab = readtable(tight_path);
tight_times = tight_tab.MedianFrameTimes - tight_tab.MedianFrameTimes(1);
tight_cal_vols = tight_tab.Volume * 1.2;
tight_cal_vols = tight_cal_vols(~isnan(tight_cal_vols));
tight_times = tight_times(~isnan(tight_cal_vols));

wide_path = "A:\thomasu\raw_data\2025-10-22\400fps_opt_focus\added_img_padding\400fps_opt_focus 20251022.1348_CELLGROUPED CellInfo.csv";
wide_tab = readtable(wide_path);
wide_times = wide_tab.MedianFrameTimes - wide_tab.MedianFrameTimes(1);
wide_cal_vols = wide_tab.Volume * 1.2;
wide_cal_vols = wide_cal_vols(~isnan(wide_cal_vols));
wide_times = wide_times(~isnan(wide_cal_vols));

bf_vol_path = "A:\thomasu\raw_data\2025-10-22\400fps_opt_focus\original_params_analysis\bf_volumes.csv";
bf_vol_tab = readtable(bf_vol_path); 
bf_est_vols = bf_vol_tab.bf_volumes;

coulter_path = "A:\thomasu\raw_data\2025-10-22\coulter\single_cell_volumes.csv";
cc_tab = readtable(coulter_path);
cc_vol_samp = cc_tab.l1210wt_rep1(cc_tab.l1210wt_rep1 > 400 & cc_tab.l1210wt_rep1 < 3500);

fh_swarm = figure;
add_swarmchart(fh_swarm, 'coulter', cc_vol_samp)
add_swarmchart(fh_swarm, 'tight\_bbox', tight_cal_vols)
add_swarmchart(fh_swarm, 'wide\_bbox', wide_cal_vols)
add_swarmchart(fh_swarm, 'bf\_estimate', bf_est_vols)
ylim([0,5000])
ylabel('Volume (fL)', FontSize=13)
saveas(fh_swarm, 'fig\modality_compare.jpg')

tight_bbox_cropped = tight_cal_vols(tight_cal_vols<4000);
wide_bbox_cropped = wide_cal_vols(wide_cal_vols<4000);
fprintf('Coulter to tight_bbox ratio: %.3f\n', mean(cc_vol_samp)/mean(tight_bbox_cropped))
fprintf('Coulter to tight_bbox ratio: %.3f\n', mean(cc_vol_samp)/mean(wide_bbox_cropped))

fh_swarm_vswide = figure;
add_swarmchart(fh_swarm_vswide, 'coulter', cc_vol_samp)
add_swarmchart(fh_swarm_vswide, 'wide\_bbox', wide_cal_vols)
ylim([0,5000])
ylabel('Volume (fL)', FontSize=13)
saveas(fh_swarm_vswide, 'fig\modality_compare_vswide.jpg')

%----------------
% Calculate adjusted px depth to make coulter and fxm match
coulter_mean = mean(cc_vol_samp);
fxm_mean = mean(tight_cal_vols); % mean of tight data
original_px_depth = 24; % um
adjusted_px_depth = original_px_depth * coulter_mean / fxm_mean;

fprintf('Assumed px depth for fxm analysis: %.3f\n', original_px_depth)
fprintf('Adjusted px depth to match coulter pop mean: %.3f\n', adjusted_px_depth)
%----------------

fh_swarm_bboxes_only = figure;
add_swarmchart(fh_swarm_bboxes_only, 'tight\_bbox', tight_cal_vols)
add_swarmchart(fh_swarm_bboxes_only, 'wide\_bbox', wide_cal_vols)
ylabel('Volume (fL)', FontSize=13)
saveas(fh_swarm_bboxes_only, 'fig\bbox_compare.jpg')

fh_timecourse = figure;
subplot(1,2,1); hold on;
scatter(tight_times, tight_cal_vols)
p = polyfit(tight_times, tight_cal_vols, 1);
plot(tight_times, polyval(p, tight_times), 'r', LineWidth=2)
title('Tight bbox', FontSize=13)
xlabel('Time (s)', FontSize=13)
ylabel('Volume (fL)', FontSize=13)
ax=gca; ax.FontSize=12;
subplot(1,2,2); hold on;
scatter(wide_times, wide_cal_vols)
p = polyfit(wide_times, wide_cal_vols, 1);
plot(wide_times, polyval(p, wide_times), 'r', LineWidth=2)
title('Wide bbox', FontSize=13)
xlabel('Time (s)', FontSize=13)
ylabel('Volume (fL)', FontSize=13)
ax=gca; ax.FontSize=12;
saveas(fh_timecourse, 'fig\timecourse_bboxes.jpg')

%% Fluorescence dilution curve
sheet_path = "A:\thomasu\raw_data\2026-02-07 - Dye dlution intensity curves\dilution_curves.xlsx";
na_fluor_tab = readtable(sheet_path,'Sheet','na fluorescein');
fitc_dex_tab = readtable(sheet_path,'Sheet','fitc dextran');

fh_dilutions = figure(Position=[2289         329        1399         553]);
subplot(1,2,1);
scatter(na_fluor_tab.concentration_mg_ml_, na_fluor_tab.dyeIntensity)
title('NaFluorescein (camera exposure=50us)', FontSize=13)
xlabel('Concentration (mg/mL)', FontSize=13)
ylabel('Channel total px intensity', FontSize=13)
yline(4095, LineWidth=1.5, Color='k')

subplot(1,2,2); hold on;
scatter(fitc_dex_tab.concentration_mg_ml_, fitc_dex_tab.dyeIntensity)
title('FITC-dextran (2MDa; camera exposure=150us)', FontSize=13)
xlabel('Concentration (mg/mL)', FontSize=13)
ylabel('Channel total px intensity', FontSize=13)
p = polyfit(fitc_dex_tab.concentration_mg_ml_, fitc_dex_tab.dyeIntensity, 1);
plot(fitc_dex_tab.concentration_mg_ml_, polyval(p, fitc_dex_tab.concentration_mg_ml_), 'r', LineWidth=2)
saveas(fh_dilutions, 'fig\dilutions_both.jpg')

fh_nafluor_zoom = figure; hold on;
mask = na_fluor_tab.concentration_mg_ml_ < 0.5;
scatter(na_fluor_tab.concentration_mg_ml_(mask), na_fluor_tab.dyeIntensity(mask))
title('FITC-dextran (2MDa)', FontSize=13)
xlabel('Concentration (mg/mL)', FontSize=13)
ylabel('Channel total px intensity', FontSize=13)
p = polyfit(na_fluor_tab.concentration_mg_ml_(mask), na_fluor_tab.dyeIntensity(mask), 1);
plot(na_fluor_tab.concentration_mg_ml_(mask), polyval(p, na_fluor_tab.concentration_mg_ml_(mask)), 'r', LineWidth=2)
saveas(fh_nafluor_zoom, 'fig\dilutions_cropped.jpg')