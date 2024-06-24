close all;
addpath(genpath("..\..\helpers"));

data_st = get_json_struct('mass_cal');

% 0.997; 1.0056
density = 0.997;

gt_bm = 4/3 * pi * (data_st.bead_diameter_um/2)^3 * (1.05 - density);

cal_factor_new = gt_bm / data_st.avg_freq_hz;

fprintf('Cal factor: %.9f\n', cal_factor_new)