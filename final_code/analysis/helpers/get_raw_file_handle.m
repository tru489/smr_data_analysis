function [f_handle, dir] = get_raw_file_handle(data_name)
% Get the file handle/ID of a raw data binary file
% 
% Arguments:
%   data_name (str): type of data file to be accessed
% Returns: 
%   f_handle (file ID): file handle binary file to be used

disp("Getting " + data_name + " data...")
[path, dir, ind] = uigetfile('../*.*', "Select " + data_name + " file", ...
    ' ');
if ind ~= 0
    f_handle = fopen(strcat(dir, path), 'r', 'b');
else
    error("IOError: Binary file not selected")
end

end