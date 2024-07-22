function density_dict = get_bead_density()
% Returns sample polystyrene bead densities from SMR population-level 
% 2-fluid measurements (H2O+D2O; averaged from 3x replicates). Returns a 
% dictionary with rounded diameter values as keys and densities as values

diam_list = [5.000, 6.007, 6.976, 7.979, 8.956, 10.12, 12.01, 14.97]; 
density_list = [1.0512	1.0496	1.05 1.0498	1.0493	1.0492	1.0499	1.0487];
density_dict = dictionary(round(diam_list), density_list);

end

