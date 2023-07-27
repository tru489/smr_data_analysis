function json_struct = get_json_struct(data_name)
% Get the file handle/ID of a raw data binary file
% 
% Arguments:
%   data_name (str): type of data file to be accessed
% Returns: 
%   json_struct (struct): struct read from json file

disp("Getting " + data_name + " data...")
[path, dir, ind] = uigetfile('../*.json', ...
    "Select " + data_name + " file", ' ');
if ind ~= 0
    f_handle = fopen(strcat(dir, path));
    raw = fread(f_handle, inf);
    str_json = char(raw');
    json_struct = jsondecode(str_json);
else
    error("IOError: JSON file not selected")
end

end

