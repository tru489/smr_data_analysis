function contents = ls(dirpath)
% Does the equivalent of ls in unix shells, lists dir contents. 
% 
% Arguments:
%   dirpath (str): path of directory
% Returns:
%   contents (cell(str)): list of dir contents

files = dir(dirpath);
contents = {files(~[files.isdir]).name};
contents = contents(~ismember(contents ,{'.','..'}));
end

