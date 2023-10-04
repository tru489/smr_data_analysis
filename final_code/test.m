close all;
import mlreportgen.ppt.*

fh = figure;
scatter(0:0.1:10, (0:0.1:10).^2)
ax = gca; ax.FontSize = 12;
xlabel('Dry density (g/cm^3)', 'FontSize', 14)
ylabel('Volume (fl)', 'FontSize', 14)
saveas(fh, 'C:\Users\Blue\Desktop\test\test_fig.jpg')

ppt = Presentation("C:\Users\Blue\Desktop\test\test.pptx", "C:\thomasu\smr_data_analysis\final_code\visualization\template.potx");
open(ppt);
title_slide = add(ppt, 'Fig_slides_title');
replace(title_slide, "Title", "asdfasdfASDF");


slide = add(ppt,"matlab_pic_slide");
figSnapshotImage = 'C:\Users\Blue\Desktop\test\test_fig.jpg';
figPicture = Picture(figSnapshotImage);
replace(slide,"Pic Placeholder",figPicture);


slide2 = add(ppt, "matlab_pic_slide");
m = find(slide2, "Pic Placeholder");
replace(m(1), ...
    {'asdfasdf', ...
    'lllllllll', ...
    {'hello', 'hello2'}})

slide3 = add(ppt, '6_panel');
n1 = find(slide3, 'fig1');
n11 = replace(n1(1), 'abcd');
n11.FontSize = '35pt';
n1.BackgroundColor = 'lightgreen';

n2 = find(slide3, 'fig2');
n22 = replace(n2(1), 'efgh');
n22.FontSize = '35pt';
n2.BackgroundColor = 'lightblue';

n3 = find(slide3, 'fig3');
n33 = replace(n3(1), 'ijkl');
n33.FontSize = '35pt';
n3.BackgroundColor = 'lightsalmon';

n4 = find(slide3, 'fig4');
n44 = replace(n4(1), 'mnop');
n44.FontSize = '35pt';
n4.BackgroundColor = 'thistle';

n5 = find(slide3, 'fig5');
n55 = replace(n5(1), 'qrst');
n55.FontSize = '35pt';
n5.BackgroundColor = 'beige';

n6 = find(slide3, 'fig6');
n66 = replace(n6(1), 'uvwx');
n66.FontSize = '35pt';
n6.BackgroundColor = 'gold';

% replace(m(2), 'asdkfkasdf')

% replace(slide2(1),"Pic Placeholder",'asdasdfasd');
% replace(slide2(2),"Pic Placeholder",'asdasdfasd');

close(ppt);
rptview(ppt);










