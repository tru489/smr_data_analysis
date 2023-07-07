function rawdata_smr = read_freq_from_binary(smr_file_ID)
    % Read in frequency data from binary file. For feedback
    rawdata_smr = fread(smr_file_ID, 'int32','b') / 2^32;
    rawdata_smr(1:129:end) = [];
    rawdata_smr = rawdata_smr';
    rawdata_smr = diff(atan(rawdata_smr(1:2:end) ./ rawdata_smr(2:2:end)));
    rawdata_smr(rawdata_smr > pi/2) = rawdata_smr(rawdata_smr > pi/2) - pi;
    rawdata_smr(rawdata_smr <= -pi/2) = ...
        rawdata_smr(rawdata_smr <= -pi/2) + pi;
    rawdata_smr = rawdata_smr*10000/(2*pi);
    % fclose(smr_file_ID);
end