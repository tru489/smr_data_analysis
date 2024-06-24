function dens_bl_cal_rescale()
% Rescales density baseline calibration file prepared with previous,
% improper concentrations of NaCl. Interpolates from table data to
% calculate correct values, and returns values in new json file in
% another folder.

addpath(genpath("..\..\helpers"))

disp('Select raw data baseline cal file...')
[fname, path] = uigetfile("A:\thomasu\raw_data");

tab = readtable(fullfile(path, fname));

pct_soln = [0.5, 1:10, 12:2:18];
dens = [1.0018, 1.0053, 1.0125, 1.0196, 1.0268, 1.034, 1.0413, 1.0486, ...
    1.0559, 1.0633, 1.0707, 1.0857, 1.1008, 1.1162, 1.1319];
intr_vals = 100 * 0.1 * [1 3 5 7 9 12 14 16] ./ [10.1, 10.3, 10.5, 10.7, 10.9, 11.2, 11.4, 11.6];

dens_rescaled = interp1(pct_soln, dens, intr_vals, 'linear', 'extrap');

p = polyfit([0.997 dens_rescaled], tab.feedback_freq, 1);
mkdir(fullfile(path, 'rescaled'))

formatted_date = get_creation_date(fullfile(path, fname));
st.slope = p(1);
st.intercept = p(2);
write_to_json(st, fullfile(fullfile(path, 'rescaled', formatted_date + ...
    "_density_baseline_calibration.json")))

disp_dir_link(fullfile(path, 'rescaled'))
end