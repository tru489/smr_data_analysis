function vol_std_dict = get_bead_diams_std_manuf()
% Returns sample polystyrene bead diameter STDs from manufacturer-reported values.
% Returns a dictionary with rounded diameter values as keys and diameter stds as values

diam_list = [5.000, 6.007, 6.976, 7.979, 8.956, 10.12, 12.01, 14.97]; 
vol_cv_list = [1.0, 1.0, 1.0, 1.1, 1.0, 0.9, 1.0, 0.9] * 0.01;
vol_std_dict = dictionary(round(diam_list), vol_cv_list .* diam_list);

end

