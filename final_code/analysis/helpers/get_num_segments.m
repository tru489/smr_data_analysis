function num_segments = get_num_segments(freqfile, datasize)
% Gets the number of segments of length datasize (chunks in which to
% analyze frequency data)
% Arguments:
%   freqfile (file ID): file handle of frequency binary file
%   datasize (int): number of datapoints in each segment
% Returns:
%   num_segments (int): number of segments in frequency dataset

arguments
    freqfile
    datasize = 2e6
end

n = 0;
while fseek(freqfile, n*8*datasize, 'bof') == 0 
    % flip forward 8*datasize bytes repeatedly until file ends
    n = n + 1;
end     

num_segments = n - 1; % total number of data segments

end