function vol_dict = get_bead_vols_coulter()
% Returns sample polystyrene bead volumes from coulter counter data (3x 
% replicates average). Returns a dictionary with rounded diameter values as 
% keys and volumes as values

diam_list = [5.000, 6.007, 6.976, 7.979, 8.956, 10.12, 12.01, 14.97]; 
vol_list = [79.66767814	132.4638158	183.5542414	264.6251358	375.4053656	543.9865714	924.0113208	1744.831111];
vol_dict = dictionary(round(diam_list), vol_list);

end

