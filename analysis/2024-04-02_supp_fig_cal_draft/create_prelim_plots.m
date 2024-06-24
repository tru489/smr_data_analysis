close all;
addpath(genpath("..\..\helpers"));

color_arr = [...
    [0 0.4470 0.7410]; ...
    [0.8500 0.3250 0.0980];  ...
    [0.9290 0.6940 0.1250];  ...
    [0.4940 0.1840 0.5560];  ...
    [0.4660 0.6740 0.1880];  ...
    [0.3010 0.7450 0.9330];  ...
    [0.6350 0.0780 0.1840]];

%% Options
plot_panel_ab = 1;
plot_panel_cd = 1;

%% Panel A
if plot_panel_ab
    fh_b = figure(Position=[680   184   560   694]);
    % fh_b = figure;
    
    pths_arr = ls("C:\thomasu\smr_data_analysis\analysis\2024-04-02_supp_fig_cal_draft\data\fluid_comp_time");

    slopes = zeros(size(pths_arr)); intcs = zeros(size(pths_arr));
    date_arr = NaT(length(pths_arr), 1);
    for i = 1:length(pths_arr)
        path = pths_arr{i};

        out_st = extract_bl_dens_info(path, true);
        date_reg_st = regexp(path, '_(?<date_>\d{4}-\d{2}-\d{2}).csv$', 'names');
        date_arr(i) = datetime(date_reg_st.date_);
        plot_bl_cal_fit_single(fh_b, out_st, color_arr(i, :), date_reg_st.date_);
        slopes(i) = out_st.slope; intcs(i) = out_st.intercept;
    end
    
    legend(Location='northoutside', FontSize=12)
    saveas(fh_b, 'fig\panel_a.pdf')

    fh_long_mass_cal = figure;
    mass_cal_long = readtable("C:\thomasu\smr_data_analysis\analysis\2024-04-02_supp_fig_cal_draft\data\cal_factor_long.xlsx");
    s = scatter(mass_cal_long.date, mass_cal_long.cal_factor, 50, color_arr(1,:), "filled"); 
    s.MarkerFaceAlpha = 0.4; xtickformat("yyyy-MM-dd")
    xlabel('Date', FontSize=14); ylabel('Mass calibration factor (pg/Hz)', FontSize=14)
    s.MarkerFaceAlpha = 0.4; 

    saveas(fh_long_mass_cal, 'fig\long_mass_cal_scatter.pdf')
end

%% Panel B
if plot_panel_ab
    fh_b = figure(Position=[680   352   560   526]);
    
    pth_nacl = "C:\thomasu\smr_data_analysis\analysis\2024-04-02_supp_fig_cal_draft\data\fluid_comp_solutes\nacl_density_baseline_cal_rescaled.csv";
    out_st_nacl = extract_bl_dens_info(pth_nacl);
    plot_bl_cal_fit_single(fh_b, out_st_nacl, "blue", 'NaCl solutions');
    
    pth_gluc = "C:\thomasu\smr_data_analysis\analysis\2024-04-02_supp_fig_cal_draft\data\fluid_comp_solutes\d-glucose_density_baseline_cal_rescaled.csv";
    out_st_glu = extract_bl_dens_info(pth_gluc);
    plot_bl_cal_fit_single(fh_b, out_st_glu, "red", 'D-Glucose solutions');
    
    pth_d2o = "C:\thomasu\smr_data_analysis\analysis\2024-04-02_supp_fig_cal_draft\data\fluid_comp_solutes\d2o_density_baseline_cal_rescaled.csv";
    out_st_d2o = extract_bl_dens_info(pth_d2o);
    plot_bl_cal_fit_single(fh_b, out_st_d2o, "magenta", 'D2O dilutions');
    legend(Location='northoutside', FontSize=12)
    saveas(fh_b, 'fig\panel_b.pdf')
    

    date_arr_new_solns = datetime(["2024-03-01"; "2024-03-09"]);
    slopes_new_solns = [out_st_glu.slope, out_st_d2o.slope];
    intcs_new_solns = [out_st_glu.intercept, out_st_d2o.intercept];

    % ---------- Slope and intercept over time ----------
    fh_long_slope = figure; hold on;
    date_arr_append = [date_arr; datetime("2024-03-01")];
    slopes_append = [slopes, out_st_nacl.slope];
    intr_append = [intcs, out_st_nacl.intercept];
    
    s = scatter(date_arr, slopes, 50, color_arr(1,:), "filled", DisplayName='NaCl solutions'); 
    s.MarkerFaceAlpha = 0.4; 
    xtickformat("yyyy-MM-dd")
    xlabel('Date', FontSize=14); ylabel('Slope (MHz*cm^3/g)', FontSize=14)

    s = scatter(date_arr_new_solns(1), slopes_new_solns(1), 50, color_arr(2,:), "filled", DisplayName='Glucose solution'); 
    s.MarkerFaceAlpha = 0.4; 
    s = scatter(date_arr_new_solns(2), slopes_new_solns(2), 50, color_arr(3,:), "filled", DisplayName='D2O dilutions'); 
    s.MarkerFaceAlpha = 0.4; 

    % legend(Location='eastoutside')
    saveas(fh_long_slope, 'fig\long_slope_scatter.pdf')


    fh_long_intr = figure; hold on;
    s = scatter(date_arr, intcs, 50, color_arr(1,:), "filled", DisplayName='NaCl solutions'); 
    s.MarkerFaceAlpha = 0.4; xtickformat("yyyy-MM-dd")
    xlabel('Date', FontSize=14); ylabel('Intercept (MHz)', FontSize=14)

    s = scatter(date_arr_new_solns(1), intcs_new_solns(1), 50, color_arr(2,:), "filled", DisplayName='Glucose solution'); 
    s.MarkerFaceAlpha = 0.4; 
    s = scatter(date_arr_new_solns(2), intcs_new_solns(2), 50, color_arr(3,:), "filled", DisplayName='D2O dilutions'); 
    s.MarkerFaceAlpha = 0.4; 

    % legend(Location='eastoutside')
    saveas(fh_long_intr, 'fig\long_intr_scatter.pdf')

    % fh_b_sub1 = figure;
    % add_swarmchart(fh_b_sub1, 'Slope', [out_st_nacl.slope, out_st_glu.slope, out_st_d2o.slope] / 1e6)
    % ylabel('Slope (MHz*cm^3/g)', FontSize=14)
    % saveas(fh_b_sub1, 'fig\panel_b_sub1.pdf')
    % 
    % fh_b_sub2 = figure;
    % add_swarmchart(fh_b_sub2, 'Intercept', [out_st_nacl.intercept, out_st_glu.intercept, out_st_d2o.intercept] / 1e6)
    % ylabel('Intercept (MHz)', FontSize=14)
    % saveas(fh_b_sub2, 'fig\panel_b_sub2.pdf')
end

%% Panel C
if plot_panel_cd
    dry_dens_arr = zeros(3,7); dry_vol_arr = zeros(3,7);

    fh_c = figure(Position=[680   458   656   420]); hold on;
    % figure(fh_c);
    % bm_midpts_h2o = [2.5 3.5 4.8 5.8 7.4 8.4 11 12.5 15.7 17.2 21.8 24.2 38.5 43];
    % bm_midpts_d2o = -[2.8 3.7 5 6.8 8 10 12.4 14.2 17.5 20 24.5 29 42.5 47];
    % ref_freqs = [1158725, 1142951];
    % out_st = bead_data_from_fpath("C:\thomasu\smr_data_analysis\analysis\2024-04-02_supp_fig_cal_draft\data\bead_comp\2024-02-20",...
    %     bm_midpts_h2o, bm_midpts_d2o, ref_freqs);
    % dry_dens_arr(1,:) = out_st.dry_dens; dry_vol_arr(1,:) = out_st.dry_vol; 
    % s = scatter(out_st.h2o_means, out_st.d2o_means, 50, color_arr(1,:), "filled", DisplayName='2024-02-20'); 
    % s.MarkerFaceAlpha = 0.5;
    % errorbar(out_st.h2o_means, out_st.d2o_means, ...
    %     out_st.d2o_stds, out_st.d2o_stds, out_st.h2o_stds, out_st.h2o_stds, ...
    %     'LineStyle', 'none', LineWidth=2, HandleVisibility='off', Color=color_arr(1,:),...
    %     CapSize=5)
    % fprintf('H2O/D2O calibrated density: %.4f / %.4f\n', out_st.h2o_dens, out_st.d2o_dens)
    
    figure(fh_c);
    bm_midpts_h2o = [2.6 3.8 4.8 5.9 7.7 8.6 11 13.4 15.8 17.6 22 25.5 40 43.5];
    bm_midpts_d2o = -[2.5 4.5 5.4 6.6 8.5 10 13 14.5 18.4 21 25.4 29.5 43.5 51];
    ref_freqs = [1158799, 1142599];
    out_st = bead_data_from_fpath("C:\thomasu\smr_data_analysis\analysis\2024-04-02_supp_fig_cal_draft\data\bead_comp\2024-03-02",...
        bm_midpts_h2o,bm_midpts_d2o, ref_freqs);
    dry_dens_arr(1,:) = out_st.dry_dens; dry_vol_arr(1,:) = out_st.dry_vol; 
    s = scatter(out_st.h2o_means / out_st.cal_fact, out_st.d2o_means / out_st.cal_fact, 50, color_arr(2,:), "filled", DisplayName='2024-03-02'); 
    s.MarkerFaceAlpha = 0.5;
    errorbar(out_st.h2o_means / out_st.cal_fact, out_st.d2o_means / out_st.cal_fact, ...
        out_st.d2o_stds / out_st.cal_fact, out_st.d2o_stds / out_st.cal_fact, out_st.h2o_stds / out_st.cal_fact, out_st.h2o_stds / out_st.cal_fact, ...
        'LineStyle', 'none', LineWidth=2, HandleVisibility='off', Color=color_arr(2,:),...
        CapSize=5)
    fprintf('H2O/D2O calibrated density: %.4f / %.4f\n', out_st.h2o_dens, out_st.d2o_dens)
    
    % figure(fh_c);
    % bm_midpts_h2o = [2.4 3.8 4.8 5.9 7.7 8.7 11.4 12.6 16 17.8 22.4 25 39.5 44.6];
    % bm_midpts_d2o = -[2 4.5 5.4 6.6 8.4 9.8 12.6 14.4 19.3 21.5 26 30 44.5 52];
    % ref_freqs = [1159299, 1142699]; % 1159299
    % out_st = bead_data_from_fpath("C:\thomasu\smr_data_analysis\analysis\2024-04-02_supp_fig_cal_draft\data\bead_comp\2024-03-03", ...
    %     bm_midpts_h2o,bm_midpts_d2o, ref_freqs);
    % dry_dens_arr(1,:) = out_st.dry_dens; dry_vol_arr(1,:) = out_st.dry_vol; 
    % s = scatter(out_st.h2o_means / out_st.cal_fact, out_st.d2o_means / out_st.cal_fact, 50, color_arr(3,:), "filled", DisplayName='2024-03-03'); 
    % s.MarkerFaceAlpha = 0.5;
    % errorbar(out_st.h2o_means / out_st.cal_fact, out_st.d2o_means / out_st.cal_fact, ...
    %     out_st.d2o_stds / out_st.cal_fact, out_st.d2o_stds / out_st.cal_fact, out_st.h2o_stds / out_st.cal_fact, out_st.h2o_stds / out_st.cal_fact, ...
    %     'LineStyle', 'none', LineWidth=2, HandleVisibility='off', Color=color_arr(3,:),...
    %     CapSize=5)
    % fprintf('H2O/D2O calibrated density: %.4f / %.4f\n', out_st.h2o_dens, out_st.d2o_dens)
    
    figure(fh_c);
    bm_midpts_h2o = [2.4 3.8 4.8 6 7.6 8.6 11.4 12.9 15.5 17.7 21.5 25.1 39 45];
    bm_midpts_d2o = -[2.4 3.8 5.4 6.6 8.5 9.6 12.5 14.7 17.9 21 26.2 29 43 49];
    ref_freqs = [1158801, 1142801];
    out_st = bead_data_from_fpath("C:\thomasu\smr_data_analysis\analysis\2024-04-02_supp_fig_cal_draft\data\bead_comp\2024-03-04",...
        bm_midpts_h2o,bm_midpts_d2o, ref_freqs);
    dry_dens_arr(2,:) = out_st.dry_dens; dry_vol_arr(2,:) = out_st.dry_vol; 
    s = scatter(out_st.h2o_means / out_st.cal_fact, out_st.d2o_means / out_st.cal_fact, 50, color_arr(4,:), "filled", DisplayName='2024-03-04'); 
    s.MarkerFaceAlpha = 0.5;
    errorbar(out_st.h2o_means / out_st.cal_fact, out_st.d2o_means / out_st.cal_fact, ...
        out_st.d2o_stds / out_st.cal_fact, out_st.d2o_stds / out_st.cal_fact, out_st.h2o_stds / out_st.cal_fact, out_st.h2o_stds / out_st.cal_fact, ...
        'LineStyle', 'none', LineWidth=2, HandleVisibility='off', Color=color_arr(4,:),...
        CapSize=5)
    fprintf('H2O/D2O calibrated density: %.4f / %.4f\n', out_st.h2o_dens, out_st.d2o_dens)

    figure(fh_c);
    bm_midpts_h2o = [2.4 3.8 4.8 5.8 7.5 8.4 10.6 12.8 15.5 17.5 21.8 24.8 38.5 43.5];
    bm_midpts_d2o = -[2.5 4.5 5.2 6.6 8.5 9.5 12.6 14.4 18.2 20.2 25.5 28.7 44 49.5];
    ref_freqs = [1158544, 1142244];
    out_st = bead_data_from_fpath("C:\thomasu\smr_data_analysis\analysis\2024-04-02_supp_fig_cal_draft\data\bead_comp\2024-05-02",...
        bm_midpts_h2o,bm_midpts_d2o, ref_freqs);
    dry_dens_arr(3,:) = out_st.dry_dens; dry_vol_arr(3,:) = out_st.dry_vol; 
    s = scatter(out_st.h2o_means / out_st.cal_fact, out_st.d2o_means / out_st.cal_fact, 50, color_arr(5,:), "filled", DisplayName='2024-05-02'); 
    s.MarkerFaceAlpha = 0.5;
    errorbar(out_st.h2o_means / out_st.cal_fact, out_st.d2o_means / out_st.cal_fact, ...
        out_st.d2o_stds / out_st.cal_fact, out_st.d2o_stds / out_st.cal_fact, out_st.h2o_stds / out_st.cal_fact, out_st.h2o_stds / out_st.cal_fact, ...
        'LineStyle', 'none', LineWidth=2, HandleVisibility='off', Color=color_arr(5,:),...
        CapSize=5)
    fprintf('H2O/D2O calibrated density: %.4f / %.4f\n', out_st.h2o_dens, out_st.d2o_dens)





    figure(fh_c);
    bm_midpts_h2o = [2.6 3.6 4.5 6 7.2 9.4 11 12.7 15.5 17.7 22 25 36 48];
    bm_midpts_d2o = -[2 4.5 5.5 7 8 10 12 14.5 18 21 25 28.5 44 49];
    ref_freqs = [1158544, 1142244];
    out_st = bead_data_from_fpath("C:\thomasu\smr_data_analysis\analysis\2024-04-02_supp_fig_cal_draft\data\bead_comp\2024-05-03",...
        bm_midpts_h2o,bm_midpts_d2o, ref_freqs);
    dry_dens_arr(4,:) = out_st.dry_dens; dry_vol_arr(4,:) = out_st.dry_vol; 
    s = scatter(out_st.h2o_means / out_st.cal_fact, out_st.d2o_means / out_st.cal_fact, 50, color_arr(6,:), "filled", DisplayName='2024-05-03'); 
    s.MarkerFaceAlpha = 0.5;
    errorbar(out_st.h2o_means / out_st.cal_fact, out_st.d2o_means / out_st.cal_fact, ...
        out_st.d2o_stds / out_st.cal_fact, out_st.d2o_stds / out_st.cal_fact, out_st.h2o_stds / out_st.cal_fact, out_st.h2o_stds / out_st.cal_fact, ...
        'LineStyle', 'none', LineWidth=2, HandleVisibility='off', Color=color_arr(6,:),...
        CapSize=5)
    fprintf('H2O/D2O calibrated density: %.4f / %.4f\n', out_st.h2o_dens, out_st.d2o_dens)







    bead_gt_dens = [1.0490    1.0482    1.0496    1.0503    1.0491    1.0490    1.0495];
    gt_bead_vols = [70.2306  119.4408  177.8726  260.3480  374.1590  526.6167  917.4986];
    h2o_bead_gt_calc = gt_bead_vols .* (bead_gt_dens - mean([1.0059, 1.0001, 1.0059]));
    d2o_bead_gt_calc = gt_bead_vols .* (bead_gt_dens - mean([1.0982, 1.0975, 1.0969]));
    % s = scatter(h2o_bead_gt_calc, d2o_bead_gt_calc, 50, color_arr(5,:), '+', DisplayName='Ground truth values'); 
    
    legend(Location='eastoutside')
    xlabel('Buoyant mass in H2O-PBS (pg)')
    ylabel('Buoyant mass in D2O-PBS (pg)')
    saveas(fh_c,'fig\panel_c.pdf')
end

%% Panel D
if plot_panel_cd
    [diam_dict, vol_dict] = get_bead_diams();
    % gt_vols = vol_dict([5:10, 12]); gt_dens = 1.05 * ones(size(gt_vols));
    
    fh_d = figure(Position=[680   458   656   420]); hold on;
    % s = scatter(gt_vols, gt_dens, 50, color_arr(1,:), '+', DisplayName='Ground truth'); 
    % s.LineWidth = 2;

    % dry_dens_arr = zeros(4,7); dry_vol_arr = zeros(4,7);
    legend_labs = ["2024-03-02", "2024-03-04", "2024-05-02", "2024-05-03"];
    for i = 1:size(dry_dens_arr)
        s = scatter(dry_vol_arr(i,:), dry_dens_arr(i,:), 50, color_arr(i+1,:), "filled", DisplayName=legend_labs(i));
        s.MarkerFaceAlpha = 0.5;
    end
    xlabel('Dry volume (fL)', FontSize=14); ylabel('Dry Density (g/cm3)', FontSize=14)
    legend(Location='eastoutside')
    saveas(fh_d,'fig\panel_d.pdf')

    mean_dens = sum(dry_dens_arr,1)/size(dry_dens_arr,1);
    disp('Density means:')
    disp(mean_dens)
end

%% HELPERS
function out_st = extract_bl_dens_info(path, rescale_nacl)
    arguments
        path
        rescale_nacl = false
    end

    data_table = readtable(path);
    density = data_table.density;
    freq = data_table.feedback_freq;

    if rescale_nacl
        pct_soln = [0.5, 1:10, 12:2:18];
        dens = [1.0018, 1.0053, 1.0125, 1.0196, 1.0268, 1.034, 1.0413, 1.0486, ...
            1.0559, 1.0633, 1.0707, 1.0857, 1.1008, 1.1162, 1.1319];
        intr_vals = 100 * 0.1 * [1 3 5 7 9 12 14 16] ./ [10.1, 10.3, 10.5, 10.7, 10.9, 11.2, 11.4, 11.6];
        
        density = interp1(pct_soln, dens, intr_vals, 'linear', 'extrap')';
        density = [0.997; density];
    end

    [b, ~, ~, ~, stats] = regress(freq / 1e6, [ones(size(density)), density]);
    regress_rng = linspace(density(1), density(end), 10);
    lin_reg = b(1) + b(2) * regress_rng;
    rsq = stats(1);

    out_st.raw_dens = density; out_st.raw_freq = freq;
    out_st.rsq = rsq;
    out_st.slope = b(2) * 1e6;
    out_st.intercept = b(1) * 1e6;
    out_st.fit_dens = regress_rng;
    out_st.fit_freq = lin_reg  * 1e6;
end

function plot_bl_cal_fit_single(fh, out_st, color_, leg_name)
    raw_dens = out_st.raw_dens;
    raw_freq = out_st.raw_freq;
    rsq = out_st.rsq;
    slope = out_st.slope;
    intercept = out_st.intercept;
    fit_dens = out_st.fit_dens;
    fit_freq = out_st.fit_freq;

    figure(fh); hold on;
    plot(fit_dens, fit_freq / 1e6, LineWidth=2, Color=color_, DisplayName=leg_name + " | R^2 = " + string(rsq))
    s = scatter(raw_dens, raw_freq / 1e6, 50, color_, "filled", ...
        HandleVisibility='off'); 
    s.MarkerFaceAlpha = 0.3;
    xlabel('Fluid density (g/cm3)', FontSize=14); ylabel('Baseline frequency (MHz)', FontSize=14)
end

function out_st = bead_data_from_fpath(dirpath, bm_midpts_h2o, bm_midpts_d2o, ref_freqs)
    mass_cal_st = get_json_struct('', fullfile(dirpath, 'mass_cal.json'));
    dens_cal_st = get_json_struct('', fullfile(dirpath, 'dens_base_cal.json'));
    % dens_cal_st = get_json_struct('', "C:\thomasu\smr_data_analysis\analysis\2024-04-02_supp_fig_cal_draft\data\bead_comp\2024-03-04\dens_base_cal.json");
    slope = dens_cal_st.slope; intc = dens_cal_st.intercept;

    h2o_data = readtable(fullfile(dirpath, 'h2o_tab.csv'));
    h2o_data = h2o_data(~isnan(h2o_data.real_time_s),:);
    h2o_bm = h2o_data.avg_pk_ht_hz * mass_cal_st.cal_factor_pg_per_hz;
    h2o_hz = h2o_data.avg_pk_ht_hz;
    d2o_data = readtable(fullfile(dirpath, 'd2o_tab.csv'));
    d2o_data = d2o_data(~isnan(d2o_data.real_time_s),:);
    d2o_bm = -d2o_data.avg_pk_ht_hz * mass_cal_st.cal_factor_pg_per_hz;
    d2o_hz = -d2o_data.avg_pk_ht_hz;

    bead_dens = 1.05;
    [diam_dict, vol_dict] = get_bead_diams();
    diams = diam_dict([5:10, 12]); vols = vol_dict([5:10, 12]);

    
    gt_bm_h2o = vols * (bead_dens - mean([1.0057 1.0059 1.0001 1.0059]));
    gt_bm_d2o = vols * (bead_dens - mean([1.0954 1.0982 1.0975 1.0969]));

    h2o_rf = ref_freqs(1); d2o_rf = ref_freqs(2); 
    h2o_dens = (h2o_rf - intc - mean(h2o_data.avg_baseline)) / slope;
    d2o_dens = (d2o_rf - intc + mean(d2o_data.avg_baseline)) / slope;

    h2o_bm_seg = cell(size(gt_bm_h2o));
    d2o_bm_seg = cell(size(gt_bm_h2o));
    h2o_means = zeros(size(gt_bm_h2o)); d2o_means = zeros(size(gt_bm_h2o)); 
    h2o_stds = zeros(size(gt_bm_h2o)); d2o_stds = zeros(size(gt_bm_h2o)); 
    dry_dens = zeros(size(gt_bm_h2o)); dry_vol = zeros(size(gt_bm_h2o)); 
    for i = 1:length(gt_bm_h2o)
        h2o_bm_seg{i} = h2o_bm(h2o_bm > bm_midpts_h2o(1+(i-1)*2) & h2o_bm < bm_midpts_h2o(2+(i-1)*2));
        h2o_means(i) = mean(h2o_bm_seg{i});
        h2o_stds(i) = std(h2o_bm_seg{i});
        d2o_bm_seg{i} = d2o_bm(d2o_bm < bm_midpts_d2o(1+(i-1)*2) & d2o_bm > bm_midpts_d2o(2+(i-1)*2));
        d2o_means(i) = mean(d2o_bm_seg{i});
        d2o_stds(i) = std(d2o_bm_seg{i});

        dry_dens(i) = (d2o_dens * h2o_means(i) - h2o_dens * d2o_means(i)) / (h2o_means(i) - d2o_means(i));
        dry_vol(i) = (h2o_means(i) - d2o_means(i)) / (d2o_dens - h2o_dens);
    end
    
    out_st.h2o_bm = h2o_bm; out_st.d2o_bm = d2o_bm;
    out_st.h2o_means = h2o_means; out_st.d2o_means = d2o_means;
    out_st.h2o_stds = h2o_stds; out_st.d2o_stds = d2o_stds;
    out_st.gt_bm_h2o = gt_bm_h2o; out_st.gt_bm_d2o = gt_bm_d2o;
    out_st.h2o_dens = h2o_dens; out_st.d2o_dens = d2o_dens; 
    out_st.dry_dens = dry_dens; out_st.dry_vol = dry_vol;
    out_st.cal_fact = mass_cal_st.cal_factor_pg_per_hz;
end