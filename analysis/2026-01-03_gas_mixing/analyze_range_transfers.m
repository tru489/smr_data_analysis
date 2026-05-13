close all;
addpath(genpath("..\..\helpers"));

fpaths = ls('A:\thomasu\raw_data\2025-12-20- MFC gas mixing experiment purging leakvalve\exmpnts_compiled');

tags = [...
    "full_range_purge", "half_range-half_purge", "half_range-no_purge", "half_range-whole_purge"];

for i = 1:length(fpaths)
    tab = readtable(fpaths{i});
    tab.time_norm = tab.time_s - tab.time_s(1);
    fh_subplot = figure(Position=[680   233   735   645]);
    subplot(2,1,1)
    scatter(tab.time_norm, tab.voltage_gas_v)
    xlabel('Time (s)')
    ylabel('Voltage (V)')

    subplot(2,1,2)
    scatter(tab.time_norm(1:end-1), diff(tab.voltage_gas_v)/0.01)
    xlabel('Time (s)')
    ylabel('Derivative (V/s)')
    sgtitle(replace(tags(i),'_','\_'))
    saveas(fh_subplot, "figs\" + tags(i) + ".jpg")
    savefig(fh_subplot, "figs\" + tags(i) + ".fig")
end