close all;
addpath(genpath("..\..\helpers"));

wc_mask = [1:3, 5];

dry_tab = readtable('results\dry_properties.csv');


figure; scatter(dry_tab.dry_volume_fl, dry_tab.dry_density_gcm3); hold on;

dry_tab.dry_volume_fl .* dry_tab.dry_density_gcm3

dens_range = linspace(min(dry_tab.dry_density_gcm3), max(dry_tab.dry_density_gcm3), 100);
vol_range = linspace(min(dry_tab.dry_volume_fl), max(dry_tab.dry_volume_fl), 100);
[dens_range,vol_range] = meshgrid(dens_range,vol_range);
Z = vol_range .* dens_range;
contour(vol_range,dens_range, Z, 30)

ax=gca; ax.FontSize=14;
xlabel('Dry Mass Volume (fL)', FontSize=14); ylabel('Dry Mass Density (g/cm^3)', FontSize=14); 