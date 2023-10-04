function formatted_date = get_creation_date(fpath)
% Get creation date of a file and return it in a formatted string
% 
% Arguments:
%   fpath (str): path of file to examine
% Returns:
%   formatted_date (str): formatted string of creation date of file

d = System.IO.File.GetCreationTime(fpath);
if d.Month < 10
    month_str = ['0' num2str(d.Month)];
else
    month_str = num2str(d.Month);
end
if d.Day < 10
    day_str = ['0' num2str(d.Day)];
else
    day_str = num2str(d.Day);
end
formatted_date = [num2str(d.Year) month_str day_str];

end

