close all;

old_slope = -148965.06367249729;
old_intc = 1.3083957372789318E+6;

new_slope = -147066.06730386842;
new_intc = 1.3064506878223652E+6;

emp_freqs = [1141380, 1150648, 1133026, 1146480, 1160143];
emp_dens = [1.1, 1.0485, 1.1585, 1.0777, 0.997];

figure; hold on;
scatter(emp_dens, emp_freqs)
xv = 0.997:0.005:1.16;
plot(xv, old_slope * xv + old_intc, DisplayName='Old calibration')
plot(xv, new_slope * xv + new_intc, DisplayName='New calibration')
legend('Location', 'northoutside')