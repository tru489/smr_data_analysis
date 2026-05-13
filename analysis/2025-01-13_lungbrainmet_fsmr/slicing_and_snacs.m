close all;
addpath(genpath("..\..\helpers"));

paths = ls('data_raw');

% for i = 1:length(paths)
%     tab = readtable(paths{i});
%     figure; histogram(tab.mass_pg, 150); title('mass')
%     figure; histogram(tab.total_volume_au, 150); title('vol')
%     figure; histogram(tab.node_dev_mean, 150); title('ndev')
%     disp(paths{i})
%     input('');
% end

slope = -174731.71074873616;
intc = 1.3341472962939898E+6;
rf = 1158724;
fl_dens = (rf - intc) / slope;

mass_cutoffs = [32 700;40 700;50 700]; % for voltage vals

fnames = ["B.csv", "L.csv", "P.csv"];

for i = 1:length(paths)
    cut_low = mass_cutoffs(i,1); cut_hi = mass_cutoffs(i,2);
    tab = readtable(paths{i}); tab = tab(tab.mass_pg > cut_low & tab.mass_pg < cut_hi, :);
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