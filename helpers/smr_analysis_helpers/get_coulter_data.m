function coulter_data = get_coulter_data()
% Get coulter counter data from .#m4 file
%
% Returns:
%   coulter_data (table): coulter counter data from file
[coulter_filename, coulter_dir, ~] = ...
    uigetfile('../*.*','Select Coulter Counter .#m4 File', ' ');
file = fullfile(coulter_dir, coulter_filename);
% [tempDir, tempFile] = fileparts(file); 
% status = copyfile(file, fullfile(tempDir, [tempFile, '.txt']));
% coulter_data = readtable(strcat(tempDir,"\", [tempFile, '.txt']),...
%     'Delimiter',' ');
coulter_data = readtable(file, 'FileType', 'text', 'Delimiter', ' ');

end