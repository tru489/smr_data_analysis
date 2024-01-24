close all;

% st = load("C:\Users\Blue\Desktop\test\bead.mat"); freq = st.freq_sl;
st = load("C:\Users\Blue\Desktop\test\trap_2.mat"); freq = st.f;
fs = 1e4;

% --------------------------------------------------------
x = freq;
[ss_ft, f] = ss_fft(x, fs);
figure('Position', [1923, 575, 560, 420]); sgtitle('unfiltered')
subplot(2,1,1); plot(fs * 0:length(x)-1, x)
subplot(2,1,2); plot(f(3:end), ss_ft(3:end))

% --------------------------------------------------------
% lp_fpass = 30;
% x = lowpass(freq, lp_fpass, 1e4);
% [ss_ft, f] = ss_fft(x, fs);
% figure; sgtitle('lowpass')
% subplot(2,1,1); plot(fs * 0:length(x)-1, x)
% subplot(2,1,2); plot(f(3:end), ss_ft(3:end))

% --------------------------------------------------------
% hp_fpass = 20;
% x = highpass(freq, hp_fpass, 1e4);
% [ss_ft, f] = ss_fft(x, fs);
% figure; sgtitle('highpass')
% subplot(2,1,1); plot(fs * 0:length(x)-1, x)
% subplot(2,1,2); plot(f(3:end), ss_ft(3:end))

% --------------------------------------------------------
x = freq - highpass(freq, hp_fpass, 1e4);
[ss_ft, f] = ss_fft(x, fs);
figure; sgtitle('freq - highpass')
subplot(2,1,1); plot(fs * 0:length(x)-1, x)
subplot(2,1,2); plot(f(3:end), ss_ft(3:end))
% --------------------------------------------------------
band = [25, 400];
x = bandpass(freq, band, 1e4);
[ss_ft, f] = ss_fft(x, fs);
figure('Position', [2484, 575, 560, 420]); sgtitle('bandpass')
subplot(2,1,1); plot(fs * 0:length(x)-1, x);
subplot(2,1,2); plot(f(3:end), ss_ft(3:end)); xline(band)

target_idx = [7000:7180, 7326, 7416, 7560:7730];
target_f = x(target_idx);
p = polyfit(target_idx, target_f, 7);
adj_bl = polyval(p, target_idx(1):target_idx(end)); figure; 
x_tgt = x;
x_tgt(target_idx(1):target_idx(end)) = x_tgt(target_idx(1):target_idx(end)) - adj_bl';
figure; plot(x_tgt)

gauss_model = @(mu, sigma, scale, x) scale * exp(-(x-mu).^2 / sigma^2) - 0.55;
vals = fit(target_idx', target_f, gauss_model, 'StartPoint', [mean([7326, 7416]), 185, 11]);



% Reconstructing SMR shape boundary function using iFFT
f_slice = [zeros(sum(f<5),1)', ss_ft(f>5 & f<59)', zeros(sum(f>59),1)'];
f_slice_2s = [f_slice(1) f_slice(2:end) / 2 fliplr(conj(f_slice(2:end)))/2];
X = ifft(f_slice_2s);
plot((0:length(X)-1) * 1, X)



% mu = mean([7326, 7416]);
% x_vals = 6900:7800;
% dist_adj = 11 * exp(-(x_vals - mu).^2 / 185^2) - 0.55;
% x_tgt2 = x;
% x_tgt2(x_vals) = x_tgt2(x_vals) - dist_adj';
% figure; plot(x_tgt2)




% x_tgt = x;
% x_tgt(7100:7620) = x_tgt(7100:7620) - (-0.55 + 11*sin(2*pi / 520/2 * (0:520)))';
% figure; plot(x_tgt)

% figure(3); subplot(2,1,1); hold on; plot(7000:7730, adj_bl)
% figure(3); subplot(2,1,1); hold on; plot(x_vals, dist_adj)
figure(3); subplot(2,1,1); hold on; plot(vals)



% figure(3); subplot(2,1,1); hold on;  plot(7100:7620, -0.55 + 11*sin(2*pi / 520/2 * (0:520)))
% --------------------------------------------------------


function [ss_ft, f] = ss_fft(x, fs)
    ft = fft(x);
    ss_ft = abs(ft / length(x));
    ss_ft = ss_ft(1:length(x) / 2 + 1);
    ss_ft(2:end-1) = 2 * ss_ft(2:end-1);
    
    f = fs / length(x) * (0:length(x) / 2);
end