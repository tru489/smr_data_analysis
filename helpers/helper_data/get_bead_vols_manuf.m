function vol_dict = get_bead_vols_manuf()
% Returns sample polystyrene bead volumes from coulter counter data. Returns 
% a dictionary with rounded diameter values as keys and volumes as values

diam_list = [5.000, 6.007, 6.976, 7.979, 8.956, 10.12, 12.01, 14.97]; 
vol_list = 4/3 * pi * (diam_list / 2).^3;
vol_dict = dictionary(round(diam_list), vol_list);

end

