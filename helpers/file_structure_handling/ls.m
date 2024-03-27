function contents = ls(dirpath, is_fullpath)

arguments
    dirpath
    is_fullpath = true
end
% Does the equivalent of ls in unix shells, lists dir contents. 
% 
% Arguments:
%   dirpath (str): path of directory
% Returns:
%   contents (cell(str)): list of dir contents

files = dir(dirpath);
contents = {files(~[files.isdir]).name};
contents = contents(~ismember(contents ,{'.','..'}));

if is_fullpath
    contents = cellfun(@(x) [char(dirpath) filesep x], contents, 'UniformOutput', false);
end
end

