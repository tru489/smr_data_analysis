function [file_id, date_str] = match_rawdata_file(dirpath, contents, ...
    analysis_name, regex_match, multiple_files)
% Given a cell array of raw data directory contents, returns file IDs of
% binary files specified by given regex. Built-in functionality to select
% for single files (i.e. freq, time, valvestate, PMT time) and multiple
% files (i.e. PMT channels). When single file is being selected, situations
% with more than 1 matching file will throw an error; all files detected in
% multiple file mode will be returned in order (i.e. PMT channel 1, PMT 
% channel 2, ...)
% 
% Arguments:
%   dirpath (str): path to directory containing raw data files in question
%   contents (cell(str)): full contents of raw data directory
%   analysis_name (str): name of analysis type. Simply used to populate
%       customized error messages
%   regex_match (str): regular expression to match filename of file being
%       searched
%   multiple_files (bool): optional, defaults to false. Species whether to
%       match a single file or search for all files matching the regex
% Returns:
%   file_id (int or array(int)): file id(s) of relevant matched files
%   date_str (str): date string (format yyyymmdd) useful for downstream
%       processing

arguments
    dirpath
    contents
    analysis_name
    regex_match
    multiple_files = 0
end

fname_match = regexp(contents, regex_match, 'match');
fname_match = fname_match(~cellfun('isempty', fname_match));

if ~multiple_files
    if length(fname_match) == 1
        fname = fname_match{1}{1};
        file_id = fopen(fullfile(dirpath, fname), 'r', 'b');
        date_cell = regexp(fname, '^\d+', 'match');
        date_str = date_cell{1};
    else
        error("RuntimeError: Multiple " + analysis_name + " files detected")
    end
else
    fname_match = cellfun(@(x) x, fname_match);
    fname_match = sort(fname_match);
    file_id = nan(length(fname_match), 1);
    for i = 1:length(fname_match)
        fname = fname_match{i};
        file_id(i) = fopen(fullfile(dirpath, fname), 'r', 'b');
    end
    date_cell = regexp(fname_match{1}, '^\d+', 'match');
    date_str = date_cell{1};
end

end

