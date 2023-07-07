function gethist()

global datafullpmt

figure;
edges = 10.^(log10(0.015):0.01:log10(1.5));
histogram(datafullpmt, edges);
set(gca, 'xscale', 'log')

end
