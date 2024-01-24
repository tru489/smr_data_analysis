function fh = plot_scatter_histogram(table_, xdata, ydata, xlabel_, ylabel_, ...
    fig_visibility, group_variable)
% Plots scatter histogram from table
% 
% Arguments:
%   table_ (table): table containing data
%   xdata (str): name of table column with x data
%   ydata (str): name of table column with y data
%   xlabel_ (str): xaxis label
%   ylabel_ (str): yaxis label
%   fig_visibility (bool): whether or not to plot figure or just save to
%       file
%   group_variable (str): variable to use to group scatter and histogram
%       data by color. Optional, defaults to NaN
% Returns:
%   fh (figure handle): figure handle for plot

arguments
    table_
    xdata
    ydata
    xlabel_
    ylabel_
    fig_visibility
    group_variable = NaN
end

fh = figure('visible', fig_visibility);
set(fh, 'color', 'w')
if isnan(group_variable)
    s = scatterhistogram(table_, xdata, ydata, 'NumBins', 50);
else
    s = scatterhistogram(table_, xdata, ydata, 'GroupVariable', group_variable);
end

xlabel(xlabel_)
ylabel(ylabel_)
s.MarkerAlpha = 0.5; s.MarkerSize = 15;

end