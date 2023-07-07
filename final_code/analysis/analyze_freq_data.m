function datafull = analyze_freq_data(run_params, num_segments)
% Analyze frequency data to detect peaks.
%
% Arguments:
%   analysispararms (struct): 
%   num_segments (int): number of datasegments to iterate through in
%       frequency data

% TODO: what is this??
scrsize = get(0, 'Screensize');
figure('OuterPosition',[0 0.05*scrsize(4) scrsize(3) 0.95*scrsize(4)])

datafull = zeros(13,1);

i = 0;
while(1)
    % Flip to the next frequency data segment piece 8*datasize bytes ahead
    fseek(freqfile, i*8*datasize, 'bof');   % datatype double is 8bytes

    % Flip to the next time data segment piece 8*datasize bytes ahead
    fseek(timefile, i*8*datasize, 'bof'); % datatype int is 8bytes
    
    % Read data starting at i*8*datasize. x is a column vector of frequency
    % data from current segment
    freq = fread(freqfile, datasize, 'float64=>double');

    % x = read_freq_from_binary(freqfile, datasize);
    
    fprintf('Processing segment %d of %d...\n', i, num_segments)
    time = fread(timefile, datasize, 'float64=>double');
    datalast = S1_PeakAnalysis_time(-freq, time, datafull, i, ...
        run_params.analysis_params);
    datafull = [datafull datalast];
    
    i = i + 1; % Move to next segment
        
    % TODO: what is this plot??
    if length(freq) < datasize % If loop reaches end of main file, stop
        figure('OuterPosition', ...
            [0 0.05*scrsize(4) scrsize(3) 0.95*scrsize(4)])
        plot(datafull(1,:), datafull(2,:), '.b')
        title(strcat('Frequency Data for: ', freqfilepath));
        xlabel('Time (s)')
        ylabel('Frequency (Hz)')
        break
    end
end

end