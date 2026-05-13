function [path_dvol, path_ddens, path_wc] = plot_drywc_scatters(ind_var, dvol_arr, ddens_arr, wc_arr, xlabel_, file_tag)

fh_dvol = plot_scatter_fmt(ind_var, dvol_arr, xlabel_, 'Dry Volume (fL)');
fh_ddens = plot_scatter_fmt(ind_var, ddens_arr, xlabel_, 'Dry Density (g/cm^3)');
fh_wc = plot_scatter_fmt(ind_var, wc_arr, xlabel_, 'Water Content (v/v)');

path_dvol = string(strcat('fig\wc_sens\', file_tag, '_dvol.jpg'));
saveas(fh_dvol, path_dvol)

path_ddens = string(strcat('fig\wc_sens\', file_tag, '_ddens.jpg'));
saveas(fh_ddens, path_ddens)

path_wc = string(strcat('fig\wc_sens\', file_tag, '_wc.jpg'));
saveas(fh_wc, path_wc)

end

