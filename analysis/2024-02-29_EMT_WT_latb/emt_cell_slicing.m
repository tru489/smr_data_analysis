close all;
addpath(genpath("..\..\helpers"))

paths = ["A:\thomasu\raw_data\2024-02-29\wt_dmso_1\20240305.133656_fl_excl_results\2024-02-29_wt_dmso_1.csv",...
    "A:\thomasu\raw_data\2024-02-29\wt_dmso_2\20240305.135001_fl_excl_results\2024-02-29_wt_dmso_2.csv",...
    "A:\thomasu\raw_data\2024-02-29\wt_latb_1\20240305.144636_fl_excl_results\2024-02-29_wt_latb_1.csv",...
    "A:\thomasu\raw_data\2024-02-29\wt_latb_2\20240307.102510_fl_excl_results\2024-02-29_wt_latb_2.csv"];
labels = ["wt_dmso_1", "wt_dmso_2", "wt_latb_1", "wt_latb_2"];
fig_labels = [...
    "WT, DMSO Rep 1", "WT, DMSO Rep 2", "WT, LatB Rep 1", "WT, LatB Rep 2"];

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
    vol_mask = vol_fl < 8000 & vol_fl > 1000;
    % ndev_slice_mask = node_dev > -0.5;
    mask = mass_slice_mask & vol_mask;
    
    mass_pg = mass_pg(mask);
    vol_fl = vol_fl(mask);
    node_dev = node_dev(mask);
    bl_sol_density = 1.005;
    dens_gcm3 = bl_sol_density + mass_pg ./ vol_fl;

    nv = node_dev ./ vol_fl;
    p = polyfit(vol_fl, nv, 1);
    fh_fit = figure(Visible='off');
    scatter(vol_fl, nv, 'Marker', '.'); hold on;
    plot(vol_fl, polyval(p, vol_fl), 'LineWidth', 2)
    xlabel('Volume (fl)')
    ylabel('Node deviation / volume (fl^-1)')
    title(fig_labels(i))
    saveas(fh_fit, "fig\" + labels(i) + "_snacs_fit.jpg")
    
    figure(fh_snacs)
    m = p(1);
    v_ref = median(vol_fl);
    snacs = nv - m * (v_ref - vol_fl);
    
    snacs_gate = snacs > -0.001 & snacs < 0.002;
    mass_pg = mass_pg(snacs_gate);
    vol_fl = vol_fl(snacs_gate);
    dens_gcm3 = dens_gcm3(snacs_gate);
    node_dev = node_dev(snacs_gate);
    snacs = snacs(snacs_gate);

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
    
    % figure; scatter(vol_fl, snacs); ylabel('snacs'); xlabel('volume (fl)')

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
    ylabel('Buoyant mass (pg)')

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

    slice_data = table();
    slice_data.mass_pg = mass_pg;
    slice_data.volume_fl = vol_fl;
    slice_data.density_gcm3 = dens_gcm3;
    slice_data.node_dev_hz = node_dev;
    slice_data.snacs = snacs;
    writetable(slice_data, fullfile('data\', labels(i) + "_table.csv"))
end

figure(fh_mass); xline(2.5);
figure(fh_vol); xline(2.5);
figure(fh_dens); xline(2.5);
figure(fh_snacs); xline(2.5);

saveas(fh_mass, "fig\mass_compared.jpg")
saveas(fh_vol, "fig\vol_compared.jpg")
saveas(fh_dens, "fig\dens_compared.jpg")
saveas(fh_snacs, "fig\snacs_compared.jpg")
disp_dir_link(save_path)