close all;
addpath(genpath("..\..\helpers"));

trav_chip_fpath = "A:\thomasu\raw_data\2024-09-06\l1210_fxm_endpoint\20240906.1352_PMT_ch1.bin";
trav_fh = fopen(trav_chip_fpath, 'r', 'b');
trav_data = fread(trav_fh, 1e7, 'float64=>double');

f1 = figure;
mask = 7e6:length(trav_data);
plot(1:length(mask), trav_data(mask))
xlabel('Time (s)'); ylabel('PMT Voltage (V)')
saveas(f1, 'fig\trav_chip.jpg')

%%
old_chip_fpath = "A:\thomasu\raw_data\2024-09-07\l1210_fxm_505_oldgen_chip\20240907.1653_PMT_ch1.bin";
old_fh = fopen(old_chip_fpath, 'r', 'b');
old_data = fread(old_fh, 1e7, 'float64=>double');

f2 = figure;
mask = 7e6:length(old_data);
plot(1:length(mask), old_data(mask))
xlabel('Time (s)'); ylabel('PMT Voltage (V)')
saveas(f2, 'fig\old_chip.jpg')