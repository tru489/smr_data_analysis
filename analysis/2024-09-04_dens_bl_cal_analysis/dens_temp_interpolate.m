close all;
addpath(genpath("..\..\helpers"));

dens_mat = readmatrix('data\nacl_density_temp.csv');
col_lab = [0 10 25 40];
row_lab = [0 1 2 4 8 12 16 20 24 26];

dens_mat = [0.99982 0.99977 0.99713 0.99225; dens_mat];

% Interpolate over rows to get desired concentrations
dq = [1 3 5 7 9 12 14 16];

interp_dens_row = zeros(length(dq), size(dens_mat, 2));
for i = 1:size(dens_mat,2)
    interp_dens_row(:, i) = interp1(row_lab, dens_mat(:,i), dq);
end

% Interpolate over columns to get desired temperatures
tq = [4 26];

interp_dens_col = zeros(size(interp_dens_row,1), length(tq));
for j = 1:size(interp_dens_row,1)
    interp_dens_col(j, :) = interp1(col_lab, interp_dens_row(j, :), tq);
end