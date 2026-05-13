function fh = plot_scatter_fmt(xdata, ydata, xlabel_, ylabel_)

fh = figure(Position=[2024 245 702 473]); 
scatter(xdata, ydata, 40, 'filled', MarkerFaceAlpha=0.2);
xlabel(xlabel_, FontSize=13, Interpreter='tex')
ylabel(ylabel_, FontSize=13, Interpreter='tex')
ax=gca; ax.FontSize=12;

end

