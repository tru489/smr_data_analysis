close all;

st = load("C:\Users\Blue\Desktop\test\bl_noise_sample.mat");
[ft, f] = ss_fft(st.f, 1e4);
figure; plot(f, ft);

y = randsample(st.f, 2e6, true);
[ft, f] = ss_fft(y, 1e4);
figure; plot(f, ft);


function [ss_ft, f] = ss_fft(x, fs)
    ft = fft(x);
    ss_ft = abs(ft / length(x));
    ss_ft = ss_ft(1:length(x) / 2 + 1);
    ss_ft(2:end-1) = 2 * ss_ft(2:end-1);
    
    f = fs / length(x) * (0:length(x) / 2);
end