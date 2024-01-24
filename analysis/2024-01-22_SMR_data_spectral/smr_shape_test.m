close all;
addpath('C:\thomasu\smr_data_analysis\simulation\scripts\helpers')

emp_sig_path = "C:\Users\Blue\Desktop\test\l1210_1.mat";

emp_struct = load(emp_sig_path);
emp_freq = emp_struct.emp_freq;

figure;
plot(emp_freq+1); hold on;
plot([zeros(1, 4), U_n(1, 2, 320, 'single-clamped').^2 * 122])