close all;
addpath(genpath("..\..\helpers"));

fpaths = ls('A:\thomasu\raw_data\2025-11-02');
labels_ = {'Air', 'N2'};

slice_idxs = {[220,305], [5, 50]};
for i = 1:length(fpaths)
    data = readtable(fpaths{i}, VariableNamingRule='preserve');
    time = data.('Time (s)'); time = (time - time(1));
    volts = data.('Gas Voltage (V)');

    mask = time>slice_idxs{i}(1) & time<slice_idxs{i}(2);
    time = time(mask); volts = volts(mask);

    p = polyfit(time, volts, 1);
    v_fit = polyval(p, time);

    fh = figure; hold on; 
    scatter(time-time(1), volts, DisplayName='Sensor Voltage')
    plot(time-time(1), v_fit, LineWidth=3, DisplayName='Linear fit')
    legend(Box='off', Location='best')
    xlabel('Time (s)', FontSize=13)
    ylabel('Sensor Voltage (V)', FontSize=13)
    ax=gca; ax.FontSize=10;
    title(['Sensor in ', labels_{i}, ' | Std = ', sprintf('%.7f', std(volts-v_fit)), ' V'])
    saveas(fh, ['fig\baselinenoise_', labels_{i}, '.jpg'])
end