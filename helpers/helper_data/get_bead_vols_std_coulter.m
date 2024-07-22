function vol_std_dict = get_bead_vols_std_coulter()
% Returns sample polystyrene bead volume STDs from coulter counter data (3x 
% replicates average). Returns a dictionary with rounded diameter values as 
% keys and vol stds as values

diam_list = [5.000, 6.007, 6.976, 7.979, 8.956, 10.12, 12.01, 14.97]; 
vol_std_list = [11.2	16.17	20.4	26.13	32.93	44.07	62.77	97.23];
vol_std_dict = dictionary(round(diam_list), vol_std_list);

end

