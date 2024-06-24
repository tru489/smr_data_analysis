close all;
addpath(genpath("..\..\helpers"));

plot_all = true;
plot_wc_fig = true;

fpaths = ls('data');

labels = ["DMSO1", "DMSO2", "DMSO3", "STS1", "STS2"];
if plot_all
    fh_bm = figure(Visible='off');
    fh_vol = figure(Visible='off');
    fh_dry_dens = figure(Visible='off');
    fh_dry_vol = figure(Visible='off');
    fh_wc = figure(Visible='off');
    fh_dens_total = figure(Visible='off');

    for i = 1:length(fpaths)
        t = readtable(fpaths{i});
    
        figure(fh_bm);
        add_swarmchart(fh_bm, labels(i), t.fl1_mass_pg)
        ax=gca; ax.FontSize=12;
        ylabel('Buoyant Mass (pg)', FontSize=18)
    
        figure(fh_vol);
        add_swarmchart(fh_vol, labels(i), t.total_volume_fl)
        ax=gca; ax.FontSize=12;
        ylabel('Total Volume (fL)', FontSize=18)
    
        if i ~= 3
            figure(fh_dry_dens);
            add_swarmchart(fh_dry_dens, labels(i), t.density_gcm3)
            ax=gca; ax.FontSize=12;
            ylabel('Dry Mass Density (g/cm3)', FontSize=18)
        
            figure(fh_dens_total);
            add_swarmchart(fh_dens_total, labels(i), t.fl1_mass_pg ./ t.total_volume_fl + t.fl1_bl_dens_gcm3)
            ax=gca; ax.FontSize=12;
            ylabel('Total density (g/cm3)', FontSize=18)
        end

        figure(fh_dry_vol);
        add_swarmchart(fh_dry_vol, labels(i), t.volume_fl)
        ax=gca; ax.FontSize=12;
        ylabel('Dry Mass Volume (fL)', FontSize=18)
    
        figure(fh_wc);
        add_swarmchart(fh_wc, labels(i), t.water_content)
        ax=gca; ax.FontSize=12;
        ylabel('Relative Water Content (v/v)', FontSize=18)
    
        figure;
        scatter(1:length(t.fl1_bl_dens_gcm3), t.fl1_bl_dens_gcm3)
        ax=gca; ax.FontSize=12;
        ylabel('Baseline density, H2O', FontSize=18); title(labels(i))
    
        figure(Visible='off');
        scatter(1:length(t.fl2_bl_dens_gcm3), t.fl2_bl_dens_gcm3)
        ax=gca; ax.FontSize=12;
        ylabel('Baseline density, D2O', FontSize=18); title(labels(i))
    
        figure(Visible='off');
        scatter(t.fl1_mass_pg, t.fl2_mass_pg)
        ax=gca; ax.FontSize=12;
        xlabel('BM, H2O', FontSize=18); 
        ylabel('BM, D2O', FontSize=18); title(labels(i))
    
        figure(Visible='off');
        scatter(t.water_content, t.fl2_peak_time_s - t.fl1_peak_time_s)
        ax=gca; ax.FontSize=12;
        xlabel('Water content', FontSize=18); title(labels(i))
        ylabel('Time between measurements', FontSize=18); title(labels(i))
    
        figure(Visible='off');
        scatter(t.density_gcm3, t.fl2_peak_time_s - t.fl1_peak_time_s)
        ax=gca; ax.FontSize=12;
        xlabel('Dry density', FontSize=18); title(labels(i))
        ylabel('Time between measurements', FontSize=18); title(labels(i))
    
        figure(Visible='off');
        scatter(t.volume_fl, t.total_volume_fl)
        ax=gca; ax.FontSize=12;
        xlabel('Dry volume', FontSize=18); title(labels(i))
        ylabel('Total volume', FontSize=18); title(labels(i))
    end
    
    saveas(fh_bm, 'fig\bm_swarm.jpg')
    saveas(fh_vol, 'fig\vol_swarm.jpg')
    saveas(fh_dry_dens, 'fig\ddens_swarm.jpg')
    saveas(fh_dry_vol, 'fig\dvol_swarm.jpg')
    saveas(fh_wc, 'fig\wc_swarm.jpg')
end

if plot_wc_fig
    labels = ["DMSO", "+2μm STS"];

    dmso1 = readtable(fpaths{1}); dmso1 = dmso1(dmso1.fl1_mass_pg < 90 & dmso1.density_gcm3 >1.25 & dmso1.density_gcm3 < 1.37 & dmso1.volume_fl < 260, :);
    dmso1_wc = dmso1.water_content;
    dmso2 = readtable(fpaths{2}); dmso2 = dmso2(dmso2.fl1_mass_pg < 90 & dmso2.density_gcm3 >1.25 & dmso2.density_gcm3 < 1.37 & dmso2.volume_fl < 260, :);
    dmso2_wc = dmso2.water_content;
    dmso_wc_full = [dmso1_wc; dmso2_wc];

    sts1 = readtable(fpaths{4}); sts1 = sts1(sts1.density_gcm3 >1.25 & sts1.density_gcm3 < 1.45 & sts1.fl1_mass_pg < 90 & sts1.volume_fl < 260, :);
    sts1_wc = sts1.water_content;
    sts2 = readtable(fpaths{5}); sts2 = sts2(sts2.density_gcm3 >1.25 & sts2.density_gcm3 < 1.45 & sts2.fl1_mass_pg < 90 & sts2.volume_fl < 260, :);
    sts2_wc = sts2.water_content;
    sts_wc_full = [sts1_wc; sts2_wc];

    fh_wc_fig = figure;
    add_swarmchart(fh_wc_fig, labels(1), dmso_wc_full, 'blue', 'red', 30)
    add_swarmchart(fh_wc_fig, labels(2), sts_wc_full, 'blue', 'red', 30)
    [h,p,ci,stats] = ttest2(dmso_wc_full, sts_wc_full)
    ax=gca; ax.FontSize=15;
    ylabel('Relative Water Content (v/v)', FontSize=20)
    saveas(fh_wc_fig, 'fig\wc_swarm_final.eps')
end