function json_struct = get_json_struct(data_name, fpath_arg)
% Get the file handle/ID of a raw data binary file
% 
% Arguments:
%   data_name (str): type of data file to be accessed
% Returns: 
%   json_struct (struct): struct read from json file

arguments
    data_name
    fpath_arg = ""
end

% disp("Getting " + data_name + " data...")

if fpath_arg == ""
    [path, dir, ind] = uigetfile('../*.json', ...
        "Select " + data_name + " file", ' ');
    full_path = fullfile(dir, path);
else
    full_path = fpath_arg;
    ind = isfile(fpath_arg);
end

if ind ~= 0
    f_handle = fopen(full_path);
    raw = fread(f_handle, inf);
    str_json = char(raw');
    json_struct = jsondecode(str_json);
else
    error("IOError: JSON file not selected")
end
fclose(f_handle);

end

