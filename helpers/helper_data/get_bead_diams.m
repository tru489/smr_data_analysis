function [diam_dict, diam_list] = get_bead_diams()
% Returns sample polystyrene bead diameters. Returns an array of values as
% well as a dictionary with rounded values as keys and true values as
% values

diam_list = [4.000, 5.000, 6.007, 6.976, 7.979, 8.956, 10.12, 12.01, 14.97]; 
diam_dict = dictionary(round(diam_list), diam_list);

end

