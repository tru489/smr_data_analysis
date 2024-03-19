close all;

pct_soln = [0.5, 1:10, 12:2:18];
dens = [1.0018, 1.0053, 1.0125, 1.0196, 1.0268, 1.034, 1.0413, 1.0486, ...
    1.0559, 1.0633, 1.0707, 1.0857, 1.1008, 1.1162, 1.1319];
intr_vals = 100 * 0.1 * [1 3 5 7 9 12 14 16] ./ [10.1, 10.3, 10.5, 10.7, 10.9, 11.2, 11.4, 11.6];

dens_rescaled = interp1(pct_soln, dens, intr_vals, 'linear', 'extrap');

tab = readtable("A:\thomasu\raw_data\2024-02-24\old_dens_bl_calibration\template_density_cal_old.csv");

p = polyfit([0.997 dens_rescaled], tab.feedback_freq, 1);

fprintf('[%.5e, %.5e]\n', p(1), p(2))