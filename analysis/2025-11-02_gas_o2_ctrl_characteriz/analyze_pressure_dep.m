close all;
addpath(genpath("..\..\helpers"));

fpaths = ls('A:\thomasu\raw_data\2025-10-31\pressure_dep');

data = readtable(fpaths{2}, VariableNamingRule='preserve');
time = data.('Time (s)'); time = (time - time(1));
volts = data.('Gas Voltage (V)');

ranges = ...
    [60, 90; ...
    120, 200; ...
    240, 280; ...
    315, 340; ...
    370, 420; ...
    460, 485; ...
    520, 620];

pressures = 0:0.5:3;
volts_means = zeros(1, size(ranges,1));
for i = 1:size(ranges, 1)
    mask = time > ranges(i, 1) & time < ranges(i, 2);
    volts_means(i) = mean(volts(mask));
end

fh = figure;
s=scatter(pressures, volts_means, 50, 'filled');
s.MarkerFaceAlpha = 0.4;
xlabel('Regulator voltage in (V)', FontSize=13)
ylabel('Sensor voltage out (V)', FontSize=13)
ax=gca; ax.FontSize=12;
saveas(fh, 'fig\pressure_dependence.jpg')

