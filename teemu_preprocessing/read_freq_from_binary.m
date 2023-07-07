function rawdata_smr = read_freq_from_binary(smr_file_ID)
% Converts binary frequency data from the binary file saved from the 
% SMR driver client to the format saved by the main VI
% Arguments:
%   smr_file_id (double): file handle for SMR frequency data binary 
%       file
% Returns:
%   rawdata_smr (double): converted binary data to new format
rawdata_smr = fread(smr_file_ID, 'int32','b') / 2^32;
rawdata_smr(1:129:end) = [];
rawdata_smr = rawdata_smr';

rawdata_smr = diff(atan(rawdata_smr(1:2:end) ./ rawdata_smr(2:2:end)));
rawdata_smr(rawdata_smr > pi/2) = rawdata_smr(rawdata_smr > pi/2) - pi;
rawdata_smr(rawdata_smr <= -pi/2) = ...
    rawdata_smr(rawdata_smr <= -pi/2) + pi;
rawdata_smr = rawdata_smr*10000/(2*pi);
fclose(smr_file_ID);
end