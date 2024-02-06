close all;

% Load empirical reconstructed noise (validated)
st = load("C:\Users\Blue\Desktop\test\bl_noise_compiled_final1.mat");
emp_bl = st.compiled_f;

seg_size = 1e6;
emp_bl_start = randi(length(emp_bl) - 1e6);
emp_bl_seg = emp_bl(emp_bl_start:emp_bl_start + 1e6);
% figure; periodogram(emp_bl_seg);
[ft, f] = ss_fft(emp_bl_seg, 1e4);
figure; plot(f, ft); title('compiled')

% Simulated white noise
Colornoise_2 = dsp.ColoredNoise(0, 1e6, ...
    'OutputDataType', 'double');
noise_term = Colornoise_2()' / std(Colornoise_2()') * 0.33;
% figure; periodogram(noise_term);
[ft, f] = ss_fft(noise_term, 1e4);
ft_whitenoise = ft; f_whitenoise = f;
figure; plot(f, ft); title('simulated')

st = load("C:\Users\Blue\Desktop\test\bl_noise_sample.mat");
[ft, f] = ss_fft(st.f, 1e4);
ft_empnoise = ft; f_empnoise = f;
figure; plot(f, ft); title('sample')

st = load("A:\thomasu\raw_data\2024-01-26\smr_baseline_no_flow\data.mat");
freq_data = st.f;
freq_data_adj = zeros(size(freq_data));
for i = 1:floor(length(freq_data) / 1e3)
    freq_data_adj((i-1) * 1e3 + 1:i*1e3) = freq_data((i-1) * 1e3 + 1:i*1e3) - mean(freq_data((i-1) * 1e3 + 1:i*1e3));
end

figure; plot(freq_data_adj)
[ft, f] = ss_fft(freq_data_adj, 1e4);
figure; plot(f, ft); title('sample')

% ft = ft';
% ft_ds = [ft(1) ft(2:end)/2 fliplr(conj(ft(2:end)))/2];
% X = ifft(ft_ds);
% [ft, f] = ss_fft(X, 1e4);
% figure; plot(f, ft); title('ft from inv')

% figure(4); xline(120*[1 2 3 4 5 6 7 8 9])

% f_no_delta_seg = f(f > 0);
% ft_no_delta_seg = ft(f > 0);
% fh = figure; plot(f_no_delta_seg, ft_no_delta_seg); 
% 
% block_size = 100;
% num_blocks = floor(length(ft_no_delta_seg) / block_size);
% max_idxs = zeros(num_blocks,1);
% max_vals = zeros(num_blocks,1);
% for i = 1:num_blocks
%     [m_val, m_idx] = max(ft_no_delta_seg((i-1) * block_size + 1:(i) * block_size));
%     rel_start_idx = (i-1) * block_size + 1;
%     max_idxs(i) = rel_start_idx + m_idx;
%     max_vals(i) = m_val;
% end
% 
% 
% 
% figure(fh); hold on; %scatter(f_no_delta_seg(max_idxs), max_vals)
% scatter(f_no_delta_seg(max_idxs), movmedian(max_vals, 100))

function [ss_ft, f] = ss_fft(x, fs)
    ft = fft(x);
    ss_ft = abs(ft / length(x));
    ss_ft = ss_ft(1:length(x) / 2 + 1);
    ss_ft(2:end-1) = 2 * ss_ft(2:end-1);
    
    f = fs / length(x) * (0:length(x) / 2);
end