close all;
addpath('..\..\analysis\helpers')

%% User preferences
% Specify block size to plot
blocksize = 2e6;

%%

[freqfile, data_dir] = get_raw_file_handle('frequency');
[timefile, ~] = get_raw_file_handle('time');

freq = fread(freqfile, 'float64=>double');
time = fread(timefile, 'float64=>double');

freq = sgolayfilt(freq, 3, 11);
xdata = 1:length(time);

figure; hold off;
pointer = 1;
flag = 0;
while ~flag
    if (pointer + blocksize) > length(xdata)
        xdata_sl = xdata(pointer:end);
        freq_sl = freq(pointer:end);
    else
        xdata_sl = xdata(pointer:pointer+blocksize);
        freq_sl = freq(pointer:pointer+blocksize);
    end

    plot(xdata_sl, freq_sl)
    xlabel('Datapoints', 'FontSize', 12)
    ylabel('Frequency (Hz)', 'FontSize', 12)
    pointer = pointer + blocksize + 1;
    
    inp = input('Continue (y/n)? ', 's');
    if inp == 'y'
        flag = 0;
    else
        flag = 1;
    end
end

fclose(freqfile);
fclose(timefile);