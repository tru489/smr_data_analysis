function datafull = analyze_freq_data(run_params, freqfile)
% Analyze frequency data to detect peaks.
%
% Arguments:
%   analysispararms (struct): 
%   num_segments (int): number of datasegments to iterate through in
%       frequency data

% TODO: what is this??
scrsize = get(0, 'Screensize');
figure('OuterPosition',[0 0.05*scrsize(4) scrsize(3) 0.95*scrsize(4)])

% Number of segments in frequency data
num_segments = get_num_segments(freqfile);

% Preallocate array for peak data
datafull = zeros(13,1);

% Struct to be passed through each iteration of loop to accumulate data
pass_struct.elapsed_time = 0;
pass_struct.samplepeak = [];
pass_struct.sampletime = [];

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
    
    fprintf('\nProcessing segment %d of %d...\n', i, num_segments)
    time = fread(timefile, datasize, 'float64=>double');
    [datalast, pass_struct] = S1_PeakAnalysis_time(-freq, time, ...
        datafull, i, run_params, pass_struct);
    datafull = [datafull datalast];
    
    i = i + 1; % Move to next segment
    
    % Plot peak heights from polynomial fitting for each individual peak
    if length(freq) < datasize % If loop reaches end of main file, stop
        fh = figure('OuterPosition', ...
            [0 0.05*scrsize(4) scrsize(3) 0.95*scrsize(4)]);
        plot(datafull(1,:), datafull(2,:), '.b')
        title('Frequency Data');
        xlabel('Time (s)')
        ylabel('Frequency (Hz)')
        saveas(fh, run_params.saving.save_abs_path + filesep + ...
            "pk_heights.jpg")
        break
    end
end

end