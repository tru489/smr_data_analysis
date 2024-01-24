close all;
addpath(genpath('..\..\..\simulation'))

%% User preferences
% Cell arr of slice indices
slice = {1.0013e6:1.0017e6, 3.8414e6:3.84185e6, 6.3875e6:6.38795e6, ...
    8.7050e6:8.7054e6, 1.2755800e7:1.2756150e7, 9.9203e6:9.92075e6, ...
    1.242745e7:1.2428e7, 1.43736e7:1.43741e7};

% bottom left: [1922, 42]
% bottom right: [3282+560, 42]
% top left: [1922, 576+420]
% top right: [3282+560, 576+420]
% total height: 954 --> 477
% total width: 1920 --> 240
% format: [px to right of bottom left corner of display 1, px above, width, height]
width = 240*2;
height = 477;
x_coords = 1922 + (0:3) * width;
x_coords = [x_coords x_coords]';
y_coords = [repmat(42, 4, 1); repmat(42+height, 4, 1)];
widths = repmat(width, 8, 1);
heights = repmat(height, 8, 1);
full_coords = [x_coords, y_coords, widths, heights];

%%

scale = {58, 65, 58, 60, 63, 48, 50, 72};
x_offset = {40, 75, 74, 47, 8, 75, 110, 93};
pkwid = {311, 310, 307, 310, 313, 301, 305, 312};

% A:\thomasu\raw_data\2023-11-20\fsmr_l1210_test
[freqfile, data_dir] = get_raw_file_handle('frequency');

freq = fread(freqfile, 'float64=>double');

for i = 1:length(slice)
    freq_sl = freq(slice{i});
    freq_sl = freq_sl - freq_sl(1);
    fh = figure('Position', full_coords(i,:));
    un = U_n(385e-6, 2, pkwid{i}, 'single-clamped').^2;
    un = un / max(un(1:round(length(un)/3)));
    shifted_data = [zeros(1, x_offset{i}), un * scale{i}];

    Colornoise_2 = dsp.ColoredNoise(alpha_factor, length(shifted_data), ...
        'OutputDataType', 'double');
    noise_term = Colornoise_2()' / std(Colornoise_2()') * 0.33;
    shifted_data = shifted_data + noise_term;

    plot(shifted_data); 
    hold on;
    plot(freq_sl)
end

fclose(freqfile);