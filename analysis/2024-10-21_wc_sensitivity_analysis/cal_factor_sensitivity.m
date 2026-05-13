close all;
addpath(genpath("..\..\helpers"));

v_bead = 924.0113208; rho_bead = 1.0499;
slope = -174731.71074873616;
intc = 1.3341472962939898E+6;
bead_bm_hz = 61;

rf_mean = 1159500; rf_std = 100; n_rf = 200;
rfs = normrnd(rf_mean, rf_std, [n_rf, 1]);

rho_fluid = zeros(n_rf, 1);
cal_factor = zeros(n_rf, 1);
for i = 1:n_rf
    rf_t = rfs(i);
    rho_fluid(i) = (rf_t - intc) / slope;
    cal_factor(i) = (v_bead * (rho_bead - rho_fluid(i))) / bead_bm_hz;
end

%% Plotting
fh_rf = figure; fh_rho = figure; fh_cf = figure;

add_swarmchart(fh_rf, 'ref. frequency', rfs/1e6); ylabel('Reference Frequency (MHz)', FontSize=15)
saveas(fh_rf, 'fig\cal_factor_sens\rf_swarm.jpg'); ax=gca; ax.FontSize=14;


add_swarmchart(fh_rho, 'densities', rho_fluid); ylabel('Fluid Density (g/cm3)', FontSize=15)
saveas(fh_rho, 'fig\cal_factor_sens\rho_fluid_swarm.jpg'); ax=gca; ax.FontSize=14;
std(rho_fluid)

add_swarmchart(fh_cf, 'cal. factor', cal_factor); ylabel('Calibration Factor (pg/Hz)', FontSize=15)
saveas(fh_cf, 'fig\cal_factor_sens\cal_factor_swarm.jpg'); ax=gca; ax.FontSize=14;
std(cal_factor)