close all;

[u, x, dudx] = U_n(400e-6, 2, 1000, 'single-clamped');

plot([x],[abs(u))