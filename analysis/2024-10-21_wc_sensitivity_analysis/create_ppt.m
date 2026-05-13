function create_ppt(ppt_path, template_path, figpath_arr, title_arr)

disp('Generating powerpoint...')
import mlreportgen.ppt.*
ppt = Presentation(ppt_path, template_path);
open(ppt);

for i = 1:length(figpath_arr)
    slide = add(ppt,"title+content");
    replace(slide, 'title', title_arr(i))
    figPicture = Picture(figpath_arr(i));
    replace(slide,"content",figPicture);
end
close(ppt);

rptview(ppt);

end

