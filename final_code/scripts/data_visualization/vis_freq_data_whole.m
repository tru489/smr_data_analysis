% close all;
addpath('..\..\analysis\helpers')

%% User preferences
% Specify slice of data to plot. Empty list implies plotting all data
slice = [];

%%

[freqfile, data_dir] = get_raw_file_handle('frequency');
[timefile, ~] = get_raw_file_handle('time');

freq = fread(freqfile, 'float64=>double');
time = fread(timefile, 'float64=>double');

freq = sgolayfilt(freq, 3, 11);

if isempty(slice)
    sl = 1:length(time);
else
    sl = slice;
end

fh = figure;
plot(sl, freq(sl))
xlabel('Datapoints', 'FontSize', 12)
ylabel('Frequency (Hz)', 'FontSize', 12)

fclose(freqfile);
fclose(timefile);