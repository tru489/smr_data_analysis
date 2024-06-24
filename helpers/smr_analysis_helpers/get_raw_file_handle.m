function [f_handle, dir, fname] = get_raw_file_handle(data_name, freq_path)
arguments
    data_name
    freq_path = ""
end

% Get the file handle/ID of a raw data binary file
% 
% Arguments:
%   data_name (str): type of data file to be accessed
% Returns: 
%   f_handle (file ID): file handle binary file to be used

if freq_path == ""
    disp("Getting " + data_name + " data...")
    [path, dir, ind] = uigetfile('../*.*', "Select " + data_name + " file", ...
        ' ');
    if ind ~= 0
        f_handle = fopen(strcat(dir, path), 'r', 'b');
    else
        error("IOError: Binary file not selected")
    end
    fname = path;
else
    f_handle = fopen(freq_path, 'r', 'b');
    [dir, name, ext] = fileparts(freq_path);
    fname = strcat(name, ext);

end