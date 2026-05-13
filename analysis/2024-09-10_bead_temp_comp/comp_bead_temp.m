close all;
addpath(genpath("..\..\helpers"));

rf = 1159424;
intc = 1.3335929208278775E+6;
slope = -174312.26307490587;

fh_swarm = figure;

%% 26c
tab_26c = readtable('data\26c.csv');
tab_26c = tab_26c(tab_26c.avg_pk_ht_hz > 57 & tab_26c.avg_pk_ht_hz < 66, :);
fd_26c = (rf - mean(tab_26c.avg_baseline) - intc) / slope;
vol_26c = 996.5;

add_swarmchart(fh_swarm, '26C', tab_26c.mass_pg)

%% 21c
tab_21c = readtable('data\21c.csv');
tab_21c = tab_21c(tab_21c.avg_pk_ht_hz > 57 & tab_21c.avg_pk_ht_hz < 66, :);
fd_21c = (rf - mean(tab_21c.avg_baseline) - intc) / slope;
vol_21c = 994.5;

add_swarmchart(fh_swarm, '21C', tab_21c.mass_pg)

%% 4c
tab_4c = readtable('data\4c.csv');
tab_4c = tab_4c(tab_4c.avg_pk_ht_hz > 57 & tab_4c.avg_pk_ht_hz < 66, :);
fd_4c = (rf - mean(tab_4c.avg_baseline) - intc) / slope;
vol_4c = 995.2;

add_swarmchart(fh_swarm, '4C', tab_4c.mass_pg)

%% Modification after plotting
figure(fh_swarm); ax=gca; ax.FontSize=13; ylabel('Buoyant Mass (pg)')
saveas(fh_swarm, 'fig\swarm.jpg')

res_tab = table();
res_tab.labels = ["4C", "21C", "26C"]';
res_tab.buoy_mass_mean = [mean(tab_4c.mass_pg), mean(tab_21c.mass_pg), mean(tab_26c.mass_pg)]';
res_tab.volume = [vol_4c, vol_21c, vol_26c]';
res_tab.fluid_density = [fd_4c, fd_21c, fd_26c]';
res_tab.particle_density = res_tab.buoy_mass_mean ./ res_tab.volume + res_tab.fluid_density;
