close all;
addpath(genpath("..\..\helpers"));

bm_data = readtable('data\2025-02-06_CCMP222_day3_2pm_1-to-20-split_biphasic_rep1.csv');
fsmr_data = readtable('data\2025-02-06_CCMP222_day3_2pm_1-to-20-split_biphasic_rep1_fsmr.csv');

slope = -174578.76457731231;
intercept = 1.3341445766588263E+6;
bl_dens_bm = (1154924 - mean(bm_data.avg_baseline) - intercept) / slope;
bl_dens_fsmr = (1154424 - mean(fsmr_data.avg_baseline) - intercept) / slope;

%% Bm data
small_cc_v = 108.6;
large_cc_v = 265.3;

bm_data = bm_data(bm_data.mass_pg > 7,:);
small_pop_bm = mean(bm_data.mass_pg(bm_data.mass_pg<22));
large_pop_bm = mean(bm_data.mass_pg(bm_data.mass_pg>22));
fprintf('                 Buoyant mass of small population: %.2f pg | of large: %.2f pg\n', small_pop_bm, large_pop_bm)
fprintf('Population-level density of small population: %.5f g/cm3 | of large : %.5f g/cm3\n', small_pop_bm / small_cc_v + bl_dens_bm, large_pop_bm / large_cc_v + bl_dens_bm)
fh1 = figure;
histogram(bm_data.mass_pg, 150)
xlabel('Mass (pg)')
ylabel('Count')
saveas(fh1, 'fig\rep1_mass_hist.jpg')

%% fsmr data
fsmr_data = fsmr_data(fsmr_data.mass_pg > 7,:);
small_vol_smr = mean(fsmr_data.total_volume_au(fsmr_data.total_volume_au<37));
large_vol_smr = mean(fsmr_data.total_volume_au(fsmr_data.total_volume_au>37));

cal_factor = mean([small_cc_v / small_vol_smr, large_cc_v / large_vol_smr]);
fsmr_data.total_volume_fl = fsmr_data.total_volume_au*cal_factor;

fsmr_data.total_density_gcm3 = fsmr_data.mass_pg ./ fsmr_data.total_volume_fl + bl_dens_fsmr;
fsmr_data = fsmr_data(fsmr_data.total_density_gcm3 < 1.25, :);

fh2 = figure; histogram(fsmr_data.mass_pg,150)
xlabel('Mass (pg)')
ylabel('Count')
saveas(fh2, 'fig\rep2_mass_hist.jpg')

fh3 = figure; histogram(fsmr_data.total_volume_fl,150)
xlabel('Volume (fl)')
ylabel('Count')
saveas(fh3, 'fig\rep2_vol_hist.jpg')

fh4 = figure; histogram(fsmr_data.total_density_gcm3, 150)
xlabel('Density (g/cm3)')
ylabel('Count')
saveas(fh4, 'fig\rep2_dens_hist.jpg')

fh5 = figure; histogram(fsmr_data.mass_pg(fsmr_data.mass_pg < 22),150)
xlabel('Mass (pg)')
ylabel('Count')
saveas(fh5, 'fig\rep2_mass_hist_sml.jpg')

fh6 = figure; histogram(fsmr_data.total_volume_fl(fsmr_data.mass_pg < 22),150)
xlabel('Volume (fl)')
ylabel('Count')
saveas(fh6, 'fig\rep2_vol_hist_sml.jpg')

fh6_1 = figure; histogram(fsmr_data.total_density_gcm3(fsmr_data.mass_pg < 22),150)
xlabel('Density (g/cm3)')
ylabel('Count')
saveas(fh6_1, 'fig\rep2_dns_hist_sml.jpg')

fh7 = figure; histogram(fsmr_data.mass_pg(fsmr_data.mass_pg > 22),150)
xlabel('Mass (pg)')
ylabel('Count')
saveas(fh7, 'fig\rep2_mass_hist_lge.jpg')

fh8 = figure; histogram(fsmr_data.total_volume_fl(fsmr_data.mass_pg > 22),150)
xlabel('Volume (fl)')
ylabel('Count')
saveas(fh8, 'fig\rep2_vol_hist_lge.jpg')

fh8_1 = figure; histogram(fsmr_data.total_density_gcm3(fsmr_data.mass_pg > 22),150)
xlabel('Density (g/cm3)')
ylabel('Count')
saveas(fh8_1, 'fig\rep2_dns_hist_lge.jpg')