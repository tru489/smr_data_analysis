close all;

paths = ["A:\thomasu\raw_data\2023-12-08\wt\20231214.125452_fl_excl_results\2023-12-08_wt.csv",...
    "A:\thomasu\raw_data\2023-12-08\6a_early\20231214.132541_fl_excl_results\2023-12-08_6a_early.csv",...
    "A:\thomasu\raw_data\2023-12-08\6a_late\20231214.133128_fl_excl_results\2023-12-08_6a_late.csv",...
    "A:\thomasu\raw_data\2023-12-08\6d_early\20231214.205218_fl_excl_results\2023-12-08_6d_early.csv",...
    "A:\thomasu\raw_data\2023-12-08\6d_late\20231215.091235_fl_excl_results\2023-12-08_6d_late.csv"];
labels = ["wt", "6a_early", "6a_late", "6d_early", "6d_late"];
fig_labels = ["WT", "6a, early", "6a, late", "6d, early", "6d, late"];
save_path = "C:\thomasu\smr_data_analysis\analysis\2023-12-08_EMT_cells\fig\";

fh_mass = figure;
fh_vol = figure;
fh_dens = figure;
fh_snacs = figure;

for i = 1:length(paths)
    data = readtable(paths(i));
    mass_pg = data.mass_pg;
    vol_fl = data.total_volume_fl;
    node_dev = data.node_dev_mean;
    mass_slice_mask = (mass_pg > 40) & (mass_pg < 300);
    vol_mask = vol_fl < 8000;
    ndev_slice_mask = node_dev > -10;
    mask = mass_slice_mask & vol_mask;
    
    mass_pg = mass_pg(mask);
    vol_fl = vol_fl(mask);
    node_dev = node_dev(mask);
    dens_gcm3 = mass_pg ./ vol_fl;

    figure(fh_mass)
    s = swarmchart(categorical(repmat(fig_labels(i), length(mass_pg), 1)), ...
        mass_pg, 8, 'filled', 'MarkerFaceAlpha', 0.2, ...
        'MarkerEdgeAlpha',0.2, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue');
    hold on;
    b = boxchart(categorical(repmat(fig_labels(i), length(mass_pg), 1)), mass_pg);
    b.BoxFaceColor = 'red';
    b.BoxMedianLineColor = 'red';
    b.MarkerColor = 'red';
    b.WhiskerLineColor = 'red';
    b.MarkerStyle = 'none';    
    ylabel('Mass (pg)')

    figure(fh_vol)
    s = swarmchart(categorical(repmat(fig_labels(i), length(vol_fl), 1)), ...
        vol_fl, 8, 'filled', 'MarkerFaceAlpha', 0.2, ...
        'MarkerEdgeAlpha',0.2, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue');
    hold on;
    b = boxchart(categorical(repmat(fig_labels(i), length(vol_fl), 1)), vol_fl);
    b.BoxFaceColor = 'red';
    b.BoxMedianLineColor = 'red';
    b.MarkerColor = 'red';
    b.WhiskerLineColor = 'red';
    b.MarkerStyle = 'none';    
    ylabel('Volume (fl)')

    figure(fh_dens)
    s = swarmchart(categorical(repmat(fig_labels(i), length(dens_gcm3), 1)), ...
        dens_gcm3, 8, 'filled', 'MarkerFaceAlpha', 0.2, ...
        'MarkerEdgeAlpha',0.2, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue');
    hold on;
    b = boxchart(categorical(repmat(fig_labels(i), length(dens_gcm3), 1)), dens_gcm3);
    b.BoxFaceColor = 'red';
    b.BoxMedianLineColor = 'red';
    b.MarkerColor = 'red';
    b.WhiskerLineColor = 'red';
    b.MarkerStyle = 'none';    
    ylabel('Density (g/cm3)')

    p = polyfit(vol_fl, node_dev ./ vol_fl, 1);
    fh_fit = figure;
    scatter(vol_fl, node_dev ./ vol_fl, 'Marker', '.'); hold on;
    plot(vol_fl, polyval(p, vol_fl), 'LineWidth', 2)
    xlabel('Volume (fl)')
    ylabel('Node deviation / volume (fl^-1)')
    title(fig_labels(i))
    saveas(fh_fit, save_path + labels(i) + "_snacs_fit.jpg")
    
    figure(fh_snacs)
    snacs = polyval(p, vol_fl);
    s = swarmchart(categorical(repmat(fig_labels(i), length(snacs), 1)), ...
        snacs, 8, 'filled', 'MarkerFaceAlpha', 0.2, ...
        'MarkerEdgeAlpha',0.2, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue');
    hold on;
    b = boxchart(categorical(repmat(fig_labels(i), length(snacs), 1)), snacs);
    b.BoxFaceColor = 'red';
    b.BoxMedianLineColor = 'red';
    b.MarkerColor = 'red';
    b.WhiskerLineColor = 'red';
    b.MarkerStyle = 'none';    
    ylabel('SNACS (au)')
    
    slice_data = table();
    slice_data.mass_pg = mass_pg;
    slice_data.volume_fl = vol_fl;
    slice_data.density_gcm3 = dens_gcm3;
    slice_data.snacs = snacs;
    writetable(slice_data, save_path + labels(i) + "_table.csv")

    % fh_mass = figure;
    % histogram(mass_pg(mask), 50);
    % xlabel('Mass (pg)', 'FontSize', 12)
    % ylabel('Count', 'FontSize', 12)
    % saveas(fh_mass, save_path + labels(i) + "_mass.jpg")
    % 
    % fh_vol = figure;
    % histogram(vol_fl(mask), 50);
    % xlabel('Volume (fl)', 'FontSize', 12)
    % ylabel('Count', 'FontSize', 12)
    % saveas(fh_vol, save_path + labels(i) + "_volume.jpg")
    % 
    % fh_ndev = figure;
    % histogram(node_dev(mask), 50);
    % xlabel('Node deviation', 'FontSize', 12)
    % ylabel('Count', 'FontSize', 12)
    % saveas(fh_ndev, save_path + labels(i) + "_ndev.jpg")
end

saveas(fh_mass, save_path + "mass_compared.jpg")
saveas(fh_vol, save_path + "vol_compared.jpg")
saveas(fh_dens, save_path + "dens_compared.jpg")
saveas(fh_snacs, save_path + "snacs_compared.jpg")
disp_dir_link(save_path)

