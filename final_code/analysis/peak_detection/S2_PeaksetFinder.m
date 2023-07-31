function peaks = S2_PeaksetFinder(run_params, xdata, ydata, offset_input, ...
    baseparams)
% Given section of x and y data, identify indices of peaks in peakset
%
% Arguments:
%   run_params (struct): running parameters for analysis
%   xdata (array(double)): indices for frequency data within this data slice 
%       (i.e. for this peakset)
%   ydata (array(double)): frequency data
%   offset_input (double): offset from frequency baseline beyond which
%       deviations should be classed as a peak within this peakset
%   baseparams (struct): parameters for identifying baseline within this
%       data slice
% Returns:
%   peaks (array(double)): global indices of apices of frequency data peaks

%% Unload parameters
analysismode = run_params.analysis_params.analysismode;

diff_threshold = baseparams.diff_threshold;
med_filt_wd = baseparams.med_filt_wd;
bs_dev_thres = baseparams.bs_dev_thres;

idx = find(abs(diff(ydata)) < diff_threshold);

%% Identify peakset
% Ignore the flat points found over the anti-node
mf_ydata_thres = medfilt1(ydata(idx), med_filt_wd);
idx_f = abs(ydata(idx) - mf_ydata_thres) < bs_dev_thres;
idx = idx(idx_f);
idx = [idx; length(ydata)];

% If length of flat portion of baseline is insufficient
if length(idx) < 2
    peaks = [];
    disp("No sufficiently flat portion of baseline in peakset " + ...
        "finding is found; no peaks found")
    return
end

% Interpolated frequency data over whole baseline range
ydata_thres = interp1(xdata(idx), ydata(idx), xdata);

% Locally smooth ydata
ydata = smooth(ydata, 3);
minpkht_thres = ydata_thres - offset_input;

if ~analysismode
    hold off;
    figure(1);
    
    % Plot entire data segment around peak
    subplot(2,2,3); plot(xdata, ydata, '-');
    hold on;
    
    % Plot baseline segments
    subplot(2,2,3); plot(xdata(idx), ydata(idx), '.g'); 
    
    % Plot min. peak height threshold
    subplot(2,2,3); plot(xdata, minpkht_thres, '-k');
    input('Continue? ');
end


repeatflag = 1;
while repeatflag 
    % Find all freq values that pass this threshold - these are the main 
    % peaks (specifically: identify freq values that do not pass the
    % threshold, and find the indices not included in this array)
    pkidx = find(ydata < minpkht_thres);
    if ~isempty(pkidx)
        % Find all breaks in y_diff indices; each segment is a peak of 
        % interest, with end on idx_end and start on (idx_end + 1)
        idx_ends = find(abs(diff(pkidx)) > 1);
        idx_ends = [0 idx_ends' length(pkidx)];

        peaks = zeros(1, length(idx_ends) - 1);
        
        % Iterate through each index at which a peak was detected
        for i = 1:length(idx_ends) - 1
            % Focus on the piece of y_diff between two consecutive 
            % idx_end markers
            data_segment = ydata(pkidx(idx_ends(i) + 1:idx_ends(i+1)));

            % Find index of the maximum deviation, i.e. the apex within 
            % the slice
            segment_idx_max = find(data_segment == min(data_segment), 1);
            
            % Convert the apex index to the global index within y_diff
            global_idx_max = pkidx(idx_ends(i) + 1) + segment_idx_max - 1;
            peaks(i) = global_idx_max;
        end
        
        if analysismode == 0
            figure(1);    
            hold off

            % Plot frequency data for the data segment for this peakset
            subplot(2,2,3); plot(xdata, ydata, '-');
            hold on
            % Plot baseline segments
            subplot(2,2,3); plot(xdata(idx), ydata(idx), '.g');
            % Plot threshold for peak detection
            subplot(2,2,3); plot(xdata, minpkht_thres, '-k');
            % Plot peak apex locations
            subplot(2,2,3); plot(peaks, ydata(peaks), '.r');
            set(gca,'XLim',[0 length(xdata)]);
            set(gca,'YLim',[min(ydata) - 10 max(ydata) + 10]);
        end
        
        goflag = 0;
        if mod(length(peaks), 3) ~= 0 
            disp(['Warning: the number of peaks found is not a multiple ' ...
                'of three. Check plot.'])
            if length(peaks) == 1
                disp('Skipping this peak set. There is only one peak..');
                peaks = [];
                repeatflag = 0;
            end

            goflag = 1;
        else
            goflag = 1;
        end

        if goflag == 1
            repeatflag = 0;
        end
        
    elseif isempty(pkidx)
        figure(1);
        hold off;

        % Plot frequency data from this peak segment
        subplot(2,2,3); plot(xdata, ydata, '-');
        hold on
        set(gca,'XLim',[0 length(xdata)]);
        set(gca,'YLim',[min(ydata) - 10 max(ydata) + 10]);
        disp('No peaks were found. Please adjust threshold baseline.')
        peaks = [];
        repeatflag = 0;
    end
    
end
return
end