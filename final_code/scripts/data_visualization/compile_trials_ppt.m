% Compiles data from up to 6 similar experiments into a powerpoint format
% (assumes there are the same figures for all analysis runs to be compiled
% with the same filenames)

close all;
%% Modifiable parameters
% Path to which compiled figures will be saved
destination_path = "A:\thomasu\presentations\compiled_figs";
% Dir in which to start for manual selection of figure folders
start_dir = "A:\thomasu\raw_data";

%% Create presentation
run_params = set_run_params;

accept = 0;
while ~accept
    num_to_compile = ...
        input('How many analysis runs to compile (min 2, max 6): ');
    if num_to_compile >= 2 && num_to_compile <= 6
        accept = 1;
    else
        disp('Number of analyses to be compiled must be between 2 and 6.')
    end
end

analysis_name = cell(1, num_to_compile);
dir_abs_paths = cell(1, num_to_compile);
for i = 1:num_to_compile
    msg = "Select figure directory for run #" + num2str(i) + "...";
    disp(msg)
    dir_path = uigetdir(start_dir, msg);
    dir_abs_paths{i} = dir_path;
    analysis_name{i} = ...
        input("Analysis name for run #" + num2str(i) + ": ", 's');
    if i == 1
        files = dir(dir_path);
        contents = {files(~[files.isdir]).name};
        fig_names = contents(~ismember(contents ,{'.','..'}));
    end
end

import mlreportgen.ppt.*
d  = datetime('today'); d.Format = 'yyyyMMdd';
ppt_filename = string(d) + "_compiled_presentation.pptx";
ppt = Presentation(fullfile(destination_path, ppt_filename), ...
    run_params.vis.ppt_template_abs_path);
open(ppt);
title_slide = add(ppt, 'Fig_slides_title');
pres_title = input('Presentation title: ', 's');
replace(title_slide, "Title", pres_title);

% Slide name in template to use
template_slide_name = num2str(num_to_compile) + "_panel";

color_names = {'lightgreen', 'lightblue', 'lightsalmon', 'thistle', 'beige', ...
    'gold'};

for i = 1:length(fig_names)
    fprintf('Creating slide #%d...\n', i)
    slide = add(ppt, template_slide_name);
    for j = 1:num_to_compile
        % Populate title text box
        fig_box_handle = find(slide, "fig" + num2str(j) + "_title");
        replace(fig_box_handle(1), analysis_name{j});
        fig_box_handle.BackgroundColor = color_names{j};

        % Populate figure
        fig_path = fullfile(dir_abs_paths{j}, fig_names{i});
        pic_handle = Picture(fig_path);
        replace(slide, "fig" + num2str(j), pic_handle)
    end
end

disp("Creating powerpoint file...")
close(ppt);
rptview(ppt);
