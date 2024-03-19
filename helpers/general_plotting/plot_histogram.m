function fh = plot_histogram(data, xlabel_, fig_visibility, num_bins)
% Create histogram plot
%
% Arguments:
%   data (array(double)): data to be plotted
%   xlabel_ (str): xaxis label
%   fig_visibility (bool): whether or not to plot figure or just save to
%       file
%   num_bins (int): optional, defaults to 30. number of histogram bins

arguments
    data
    xlabel_
    fig_visibility
    num_bins = 100
end

fh = figure('visible', fig_visibility);
set(fh, 'color', 'w')
histogram(data, 'NumBins', num_bins)
ax = gca; ax.FontSize = 11;
xlabel(xlabel_, 'FontSize', 13)
ylabel('Count', 'FontSize', 13)

end

