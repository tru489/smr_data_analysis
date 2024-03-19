function disp_dir_link(abs_path)
% Displays a link to open a folder in the command window
%
% Arguments:
%   abs_path (str): absolute path of dir

abs_path = char(abs_path);
disp(['<a href="matlab:dos(''explorer.exe /e, ' abs_path ', &'')' ...
    '">Open results folder</a>']);

end

