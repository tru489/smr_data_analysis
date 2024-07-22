function vol_std_dict = get_bead_vols_std_manuf()
% Returns sample polystyrene bead volume STDs from manufacturer-reported values.
% Calculated from manufacturer-reported diameter STDs, so the values
% provided in the dictionary are the min and max volume values at the lower
% and higher end of the diameter 1 STD range.
% Returns a dictionary with rounded diameter values as keys and vol stds as values

diam_list = [5.000, 6.007, 6.976, 7.979, 8.956, 10.12, 12.01, 14.97]; 
vol_cv_list = [1.0, 1.0, 1.0, 1.1, 1.0, 0.9, 1.0, 0.9] * 0.01;
vol_stds = vol_cv_list .* diam_list;

min_vols = 4/3 * pi * ((diam_list - vol_stds) / 2) .^ 3;
max_vols = 4/3 * pi * ((diam_list + vol_stds) / 2) .^ 3;

vol_std_list = cell(1,length(min_vols));
for i = 1:length(min_vols)
    vol_std_list{i} = [min_vols(i), max_vols(i)];
end

vol_std_dict = dictionary(round(diam_list), vol_std_list);

end

