function [datafull, pass_struct, init_time] = analyze_freq_data(run_params, ...
    freqfile, timefile, vsfile, inv_peaks)
% Analyze frequency data to detect peaks.
%
% Arguments:
%   run_params (struct): running parameters for analysis
%   freqfile (file handle): file handle for binary file with frequency
%       data
%   timefile (file handle): file handle for binary file with time
%       data
%   vsfile (file handle): file handle for binary file with valve state
%       data. Optional, defaults to NaN which implies no valve state file
%       supplied/necessary for this analysis type
%   inv_peaks (bool): inverts the frequency signal to detect peaks of the
%       opposite direction. E.g. necessary in density traps where the
%       second fluid is more dense than the particle being analyzed.
%       Optional, defaults to 0.
% Returns:
%   datafull (array(double)): array of peakwise (not peakset-wise)
%       unprocessed peak data. I treat columns as a black box and let
%       downstream processing reformat the columns nicely for
%       peakset-compiled data
%   pass_struct (struct): struct containing data that is passed through
%       each iteration of peak detection routine. Contains data necessary
%       for manual peak curation and real time visualization of data as
%       analysis is happening
%   init_time (double): absolute time at which analysis started in seconds

arguments
    run_params
    freqfile
    timefile
    vsfile = NaN
    inv_peaks = 0
end

if run_params.analysis_params.dispprogress || run_params.analysis_params.verbose
    scrsize = get(0, 'Screensize');
    figure('OuterPosition',[0 0.05 * scrsize(4) scrsize(3) 0.95 * scrsize(4)])
end

% Number of segments in frequency data
num_segments = get_num_segments(freqfile);

% Preallocate array for peak data
datafull = zeros(13,1);

% Struct to be passed through each iteration of loop to accumulate data
pass_struct.elapsed_time = 0;
pass_struct.samplepeak = [];
pass_struct.sampletime = [];
pass_struct.sample_baseline_fits = [];
pass_struct.left_bl_length = [];
pass_struct.right_bl_length = [];

i = 0;
datasize = run_params.backend.datasize;

init_time = 0;
while(1)
    % Flip to the next frequency data segment piece 8*datasize bytes ahead
    fseek(freqfile, i * 8 * datasize, 'bof');   % datatype double is 8bytes
    freq = fread(freqfile, datasize, 'float64=>double');

    % Flip to the next time data segment piece 8*datasize bytes ahead
    fseek(timefile, i * 8 * datasize, 'bof'); % datatype int is 8bytes
    time = fread(timefile, datasize, 'float64=>double');
    if init_time == 0
        init_time = time(1);
    end

    if numel(freq) == 0 || numel(time) == 0
        break
    end

    if ~isnan(vsfile)
        % Flip to the next valve state data segment piece 8*datasize bytes ahead
        fseek(vsfile, i * datasize, 'bof'); % datatype int is 8bytes
        valve_state = fread(vsfile, datasize);
    else
        valve_state = zeros(size(freq));
    end
    
    if run_params.analysis_params.dispprogress || run_params.analysis_params.verbose
        fprintf('    Processing segment %d of %d...\n', i, num_segments)
    end

    if inv_peaks
        [datalast, pass_struct] = S1_PeakAnalysis_time(freq, time, ...
            valve_state, datafull, i, run_params, pass_struct);
    else
        [datalast, pass_struct] = S1_PeakAnalysis_time(-freq, time, ...
            valve_state, datafull, i, run_params, pass_struct);
    end
    
    datafull = [datafull datalast];
    
    i = i + 1; % Move to next segment
    
    % Plot peak heights from polynomial fitting for each individual peak
    if length(freq) < datasize % If loop reaches end of main file, stop
        if run_params.vis.disp_fig_windows
            fig_visibility = 'on';
        else
            fig_visibility = 'off';
        end
        if run_params.analysis_params.dispprogress || run_params.analysis_params.verbose
            fh = figure('OuterPosition', ...
                [0 0.05*scrsize(4) scrsize(3) 0.95*scrsize(4)], ...
                'visible', fig_visibility);
            plot(datafull(1,:), datafull(2,:), '.b')
            title('Frequency Data');
            xlabel('Time (s)')
            ylabel('Frequency (Hz)')
            saveas(fh, fullfile(run_params.saving.save_abs_path, "pk_heights.jpg"));
        end
        break
    end
end

close(gcf)

end