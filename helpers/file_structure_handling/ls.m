function contents = ls(dirpath, is_fullpath, list_dirs)

arguments
    dirpath
    is_fullpath = true
    list_dirs = false
end
% Does the equivalent of ls in unix shells. Default is to only list files that 
% are in dir, not dirs. 
% 
% Arguments:
%   dirpath (str): path of directory
% Returns:
%   contents (cell(str)): list of dir contents

files = dir(dirpath);
if ~list_dirs
    contents = {files(~[files.isdir]).name};
else
    contents = {files.name};
end
contents = contents(~ismember(contents ,{'.','..'}));

if is_fullpath
    contents = cellfun(@(x) [char(dirpath) filesep x], contents, 'UniformOutput', false);
end
end

