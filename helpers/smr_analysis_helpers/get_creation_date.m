function formatted_date = get_creation_date(fpath)
% Get a yyyymmdd date string for a data file. Cross-platform (macOS/Windows):
% prefers a yyyyMMdd timestamp embedded at the start of the filename (the SMR
% raw-data naming convention, e.g. "20260623.1154_frequencies"), and otherwise
% falls back to the file system modification date.
%
% Arguments:
%   fpath (str): path of file to examine
% Returns:
%   formatted_date (char): date as 'yyyymmdd'

[~, name, ext] = fileparts(fpath);
fname = [name ext];

% 1) Acquisition date embedded in the filename: leading 8-digit yyyyMMdd token
tok = regexp(fname, '^\d{8}', 'match', 'once');
if ~isempty(tok)
    yr = str2double(tok(1:4));
    mo = str2double(tok(5:6));
    dy = str2double(tok(7:8));
    if yr > 1990 && mo >= 1 && mo <= 12 && dy >= 1 && dy <= 31
        formatted_date = tok;
        return
    end
end

% 2) Fall back to the file system date (modification time; available on all
%    platforms via dir, unlike the Windows-only .NET creation-time call).
d = dir(fpath);
if isempty(d)
    error('get_creation_date:notFound', 'File not found: %s', fpath);
end
formatted_date = char(string(datetime(d(1).datenum, ...
    'ConvertFrom', 'datenum'), 'yyyyMMdd'));

end
