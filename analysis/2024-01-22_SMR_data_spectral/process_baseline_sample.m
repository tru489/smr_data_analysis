close all;

path = "A:\thomasu\raw_data\2024-01-22\bl_noise_segment_1\20240122.1027_frequencies";
f_handle = fopen(path, 'r', 'b');

freq = fread(f_handle, 'float64=>double');
% 
% figure; x = 0 * 7e6 + 1:1 * 7e6; plot(x, freq(x));
% figure; x = 1 * 7e6 + 1:2 * 7e6; plot(x, freq(x));
% figure; x = 2 * 7e6 + 1:3 * 7e6; plot(x, freq(x));
% figure; x = 3 * 7e6 + 1:4 * 7e6; plot(x, freq(x));
% figure; x = 4 * 7e6 + 1:5 * 7e6; plot(x, freq(x));
% figure; x = 5 * 7e6 + 1:6 * 7e6; plot(x, freq(x));
% figure; x = 6 * 7e6 + 1:length(freq); plot(x, freq(x));

sl = {7e6:8e6, 3e6:6.5e6, 1.4e7:1.75e7, 1.78e7:1.88e7, 1.91e7:1.98e7, 2.01e7:2.1e7, 2.85e7:3.35e7, 3.5e7:3.85e7, 6.2e7:6.7e7};
norm_data = cell(length(sl), 1);
full_data = [];
for i = 1:length(sl)
    norm_data{i} = freq(sl{i}) - mean(freq(sl{i}));
    full_data = [full_data; freq(sl{i}) - mean(freq(sl{i}))];
end
save("C:\Users\Blue\Desktop\test\bl_noise_sample_final.mat", 'full_data')

plot(full_data)