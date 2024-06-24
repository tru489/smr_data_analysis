close all;
addpath(genpath("..\..\helpers"));

%% Create figure
% 21 16 11 6 1

p1_fracs = 0:0.1:1;
for i = 1:length(p1_fracs)
    fh=figure;
    x = 0:0.001:1;
    
    p1_frac = p1_fracs(i); 
    p2_frac = 1 - p1_frac;
    pd1 = makedist('Normal','mu',0.8,'sigma', 0.03);
    pd2 = makedist('Normal','mu',0.3,'sigma', 0.03);
    pdf_normal = pdf(pd1,x)*p1_frac + pdf(pd2,x)*p2_frac;
    plot(pdf_normal,x,'LineWidth',8)
    xlim([0 13.4])
    set(gca,'YTickLabel',[]); set(gca,'XTickLabel',[]);
    set(gca,'XTick',[]); set(gca,'YTick',[]);
    box off
    set(gca,'linewidth',8)
    saveas(fh, "figs\sample_fig_" + num2str(i) + ".jpg")
end