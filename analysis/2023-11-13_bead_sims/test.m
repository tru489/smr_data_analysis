close all
Colornoise_2 = dsp.ColoredNoise(-1, 1e6, ...
    'OutputDataType', 'double');
noise_term = Colornoise_2()' / std(Colornoise_2()') * 1;
% [Pxx,F] = pwelch(x,hamming(128),[],[],Fs,'psd');
% plot(log2(F(2:end)),10*log10(Pxx(2:end)))
% hold on;
% 
% PSDPink = 1./(F(2:end).^-1);
% plot(log2(F(2:end)),10*log10(PSDPink),'r',linewidth=2)


[dh, hb, cp] = dwtleader(noise_term);
disp(2 * cp(1) + 1)

hexp = wtmm(noise_term);
disp(2 * hexp + 1)
