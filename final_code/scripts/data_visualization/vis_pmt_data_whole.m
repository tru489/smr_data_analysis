% close all;
addpath('..\..\analysis\helpers')

%% User preferences
% Specify slice of data to plot. Empty list implies plotting all data
slice = [1:5e6];

%%

[file, dir_] = uigetfile({'*.bin'}, 'Select pmt data file...', 'A:\thomasu\raw_data\');
pmt_file_id = fopen(fullfile(dir_, file), 'r', 'b');

pmt_data = fread(pmt_file_id, 'float64=>double');

if isempty(slice)
    sl = 1:length(pmt_data);
else
    sl = slice;
end

fh = figure;
h = plot(sl, pmt_data(sl));
ax = ancestor(h, 'axes');
ax.XAxis.Exponent = 0;
xtickformat('%.0f')
xlabel('Datapoints', 'FontSize', 12)
ylabel('Voltage (V)', 'FontSize', 12)

fclose(pmt_file_id);
