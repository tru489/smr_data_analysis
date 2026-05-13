close all;
addpath(genpath("..\..\helpers"));

paths = ls('data_raw');

%% Get volume cal factor
tab = readtable('data_raw\2025-02-12_lepto_nontreatment.csv');
tab = tab(tab.mass_pg < 700 & tab.mass_pg > 65, :);
cal_factor = 3045 / mean(tab.total_volume_au);

%% Process data
% for i = 1:length(paths)
%     tab = readtable(paths{i});
%     figure; histogram(tab.mass_pg, 150); title('mass')
%     figure; histogram(tab.total_volume_au, 150); title('vol')
%     figure; histogram(tab.node_dev_mean, 150); title('ndev')
%     disp(paths{i})
%     input('');
% end

slope = -174578.76457731231;
intc = 1.3341445766588263E+6;

rf = 1157424;

mass_cutoffs = [65 700;45 700;65 700;65 700]; 

fnames = ["B_treat.csv", "B_notreat.csv", "L_treat.csv", "L_notreat.csv"];

for i = 1:length(paths)
    cut_low = mass_cutoffs(i,1); cut_hi = mass_cutoffs(i,2);
    tab = readtable(paths{i}); tab = tab(tab.mass_pg > cut_low & tab.mass_pg < cut_hi, :);
    fl_dens = (rf - mean(tab.avg_baseline) - intc) / slope;
    tab.total_volume_fl = tab.total_volume_au * cal_factor;
    tab.total_density_gcm3 = tab.mass_pg ./ tab.total_volume_fl + fl_dens;

    vol_fl = tab.total_volume_fl; node_dev = tab.node_dev_mean;

    nv = node_dev ./ vol_fl;
    p = polyfit(vol_fl, nv, 1);

    fh_fit = figure;
    scatter(vol_fl, nv, 'Marker', '.'); hold on;
    plot(vol_fl, polyval(p, vol_fl), 'LineWidth', 2)
    xlabel('Volume (fl)')
    ylabel('Node deviation / volume (fl^-1)')

    m = p(1);
    v_ref = median(vol_fl);
    tab.snacs = nv - m * (v_ref - vol_fl);

    writetable(tab, "data_processed\" + fnames(i))
end