close all;
addpath(genpath("..\..\helpers"));

fpaths = ls('A:\thomasu\raw_data\2025-10-31\range_transfer');

deriv_threshold = 0.01;

slice_bounds = [...
    600, 1300;
    450, 900;
    225, 900;
    100, 400];

oxy_dtime_arr = zeros(1, length(fpaths));
deoxy_dtime_arr = zeros(1, length(fpaths));
labels = ["none", "open", "both", "purge"];
for i = 1:length(fpaths)
    data = readtable(fpaths{i}, VariableNamingRule='preserve');
    time = data.('Time (s)'); time = (time - time(1));
    volts = data.('Gas Voltage (V)');
    
    lngth = 1000;
    time = time(lngth+2:end); volts = volts(lngth+2:end);

    mask = time > slice_bounds(i, 1) & time < slice_bounds(i, 2);
    time = time(mask); volts = volts(mask);

    coeff = ones(1, lngth)/lngth;
    volts_avg = filter(coeff, 1, volts);

    time = time(1000:end); volts_avg = volts_avg(1000:end);

    deriv = diff(volts_avg) ./ 0.001;

    if false
        figure; 
        [pref, fname, ext] = fileparts(fpaths{i});
        title(fname)
        yyaxis left
        scatter(1:length(volts_avg), volts_avg)
        yyaxis right
        
        scatter(deriv_idxs, deriv)
    end
    % [pref, fname, ext] = fileparts(fpaths{i});
    deriv_idxs = 1:length(deriv);
    
    if i ~= 4 && i ~= 1
        segment_mask_deoxy = deriv < -deriv_threshold;
    elseif i == 4
        segment_mask_deoxy = deriv < -deriv_threshold & deriv_idxs' > 2.3e4;
    else 
        segment_mask_deoxy = deriv < -deriv_threshold & deriv_idxs' > 1.14e5;
    end
    
    if i ~= 4
        segment_mask_oxy = deriv > deriv_threshold;
    else
        segment_mask_oxy = deriv > deriv_threshold & deriv_idxs' > 2.5e4;
    end
    
    if true
        figure; hold on;
        scatter(deriv_idxs, deriv)
        scatter(deriv_idxs(segment_mask_deoxy), deriv(segment_mask_deoxy))
    end

    fh_scatters = figure; hold on;
    scatter(time, volts_avg)
    sl_time = time(1:end-1); sl_volts_avg = volts_avg(1:end-1);
    deoxy_time = sl_time(segment_mask_deoxy); deoxy_volts = sl_volts_avg(segment_mask_deoxy);
    scatter(deoxy_time, deoxy_volts)

    oxy_time = sl_time(segment_mask_oxy); oxy_volts = sl_volts_avg(segment_mask_oxy);
    scatter(oxy_time, oxy_volts)
        
    ax=gca; ax.FontSize=13;
    xlabel('Time (s)', FontSize=14)
    ylabel('Voltage (V)', FontSize=14)

    saveas(fh_scatters, "fig\" + labels(i) + "_scattercolors.jpg")

    oxy_dtime_arr(i) = oxy_time(end) - oxy_time(1);
    deoxy_dtime_arr(i) = deoxy_time(end) - deoxy_time(1);
end

labels = labels([2,3,4,1]);
oxy_dtime_arr = oxy_dtime_arr([2,3,4,1]);
deoxy_dtime_arr = deoxy_dtime_arr([2,3,4,1]);

fh_oxy = figure;
title('Oxgenation times, 0% to 21%')
bar(categorical(labels), oxy_dtime_arr)
ax=gca; ax.FontSize=13;
ylabel('Transition time (s)', FontSize=14)
saveas(fh_oxy, "fig\oxy_bars.jpg")

fh_deoxy = figure;
title('Deoxgenation times, 21% to 0%')
bar(categorical(labels), deoxy_dtime_arr)
ax=gca; ax.FontSize=13;
ylabel('Transition time (s)', FontSize=14)
saveas(fh_deoxy, "fig\deoxy_bars.jpg")