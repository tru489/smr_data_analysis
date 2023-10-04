function gen_fig_ppt(run_params, run_stats_cell, fig_path_cell, ppt_title, presentation_title, save_abs_path)
% Creates a powerpoint presentation with figures from a data analysis
% instance
%
% Arguments:
%   run_params (struct): running parameters for analysis
%   run_stats_cell (cell): cell array of stats from this analysis run.
%       added to second slide of the presentation (just text)
%   fig_path_cell (cell): absolute file paths of figure files to add to 
%       presentation
%   ppt_title (str): filename of powerpoint presentation
%   presentation_title (str): text for title slide of powerpoint
%   save_abs_path (str): absolute path for saving powerpoint

disp('Generating powerpoint...')
import mlreportgen.ppt.*
ppt = Presentation(fullfile(save_abs_path, ppt_title), ...
    run_params.vis.ppt_template_abs_path);
open(ppt);
title_slide = add(ppt, 'Fig_slides_title');
replace(title_slide, "Title", presentation_title);

slide2 = add(ppt, "matlab_pic_slide");
stats_slide = find(slide2, "Pic Placeholder");
replace(stats_slide(1), run_stats_cell)

for i = 1:length(fig_path_cell)
    slide = add(ppt,"matlab_pic_slide");
    figPicture = Picture(fig_path_cell{i});
    replace(slide,"Pic Placeholder",figPicture);
end
close(ppt);

if run_params.vis.open_ppt
    rptview(ppt);
end

end

