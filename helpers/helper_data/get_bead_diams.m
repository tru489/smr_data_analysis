function [diam_dict, vol_dict] = get_bead_diams()
% Returns sample polystyrene bead diameters. Returns a dictionary with rounded 
% values as keys and true diameter values as values, and a second with 

diam_list = [4.000, 5.000, 6.007, 6.976, 7.979, 8.956, 10.12, 12.01, 14.97]; 
diam_dict = dictionary(round(diam_list), diam_list);

vol_list = 4/3 * pi * (diam_list / 2).^3;
vol_dict = dictionary(round(diam_list), vol_list);

end

