function [left_base, right_base, edgeidx] = S2_BaselineFinder(run_params, xdata, ...
    ydata, peaks, baseparams, peakdist)
% Finds relevant baseline sections to the left and right of peakset as well
% as indices of the two edges of the frequency peaks
%
% Arguments:
%   run_params (struct): running parameters for analysis
%   xdata (array(double)): indices of local frequency data
%   ydata (array(double)): local frequency data
%   peaks (array(double)): local indices of peak apices
%   baseparams (struct): parameters for baseline selection
%   peakdist (array(double)): total length in datapoints between last and
%       first peak apex
% Returns:
%   left_base (array(double)): local indices of baseline segment to the
%       left of the peakset
%   right_base (array(double)): local indices of baseline segment to the
%       right of the peakset
%   edgeidx (array(double)): indices indicating the left and right edge of
%       the peakset

%% Unload relevant running parameters
analysismode = run_params.analysis_params.analysismode;

%% Identify baseline sections
edgethres = baseparams.edgethres;
winsize = baseparams.winsize;

% New way of selecting baseline motivated by small size; accounts for 
% edge threshold to be proportional to cell size
edgethres = edgethres * abs(max(ydata) - min(ydata)) / 100;

% Accounting for transit time; assuming 400 data points per transit gives
% inter-peak distance of 200 pts
edgethres = edgethres / (peakdist / 200);
winsize = round(winsize * peakdist / 200);

% Locally smooth ydata again just for baseline finding
sgolay_length_idx_base = 7;
sgolay_length_base = 2 * round(sgolay_length_idx_base * ...
    (peakdist / 200)) + 1;
if sgolay_length_base > 5
    ydata = sgolayfilt(ydata, 3, sgolay_length_base);
else
    ydata = sgolayfilt(ydata, 3, 5);
end

exitflag = 0;
while ~exitflag
    % Indices to search for baseline segments to the left and right of a
    % peakset
    leftedgesearch = ...
        max(1, peaks(1) - winsize):1:...
        max(1, peaks(1) - round(peakdist / 6));
    rightedgesearch = ...
        min(length(ydata), peaks(end) + round(peakdist / 6)):1:...
        min((peaks(end) + winsize) , length(ydata));
    
    % Find datapoints at the left and right edges of the peakset
    left_edge_thresh_logi = ...
        find((diff(ydata(leftedgesearch))) < -edgethres, 1);
    right_edge_thresh_logi = ...
        find((diff(ydata(rightedgesearch))) > edgethres, 1);
    if isempty(left_edge_thresh_logi) || isempty(right_edge_thresh_logi)
        disp('Skipping this peakset; no proper edge found')
        left_base = [];
        right_base = [];
        edgeidx = [];
        return
    end
    
    % Find the baseline segments not exceeding a certain derivative
    % threshold (i.e. flat parts of baseline to the left and right of the
    % peakset)
    idx_idx1 = find(diff(ydata(leftedgesearch)) > -edgethres, 1, 'last');
    idx_idx2 = find(diff(ydata(rightedgesearch)) < edgethres, 1);
    
    if (isempty(idx_idx1) || isempty(idx_idx2))
        left_base=[];
        right_base=[];
    else
    edgeidx(1) = leftedgesearch(idx_idx1);
    edgeidx(2) = rightedgesearch(idx_idx2);
    
    % Slice out large baseline segments to the left and right of peakset
    sidelength = round(4 * 0.25 * peakdist); 
    offset_length = 30; 
    left_base = max(edgeidx(1) - sidelength - offset_length, 1):1: ...
        edgeidx(1) - offset_length;
    right_base = edgeidx(2) + offset_length:1: ...
        min(edgeidx(2) + sidelength + offset_length, length(ydata));
    
    if ~analysismode
        figure(1);
        freqdata = ydata - median(ydata(left_base));
        drawnow;
        hold off

        % Plot peakset data
        subplot(2,2,3); plot(xdata, freqdata, '-');
        hold on

        % Mark peaks in red
        subplot(2,2,3); plot(peaks, freqdata(peaks), '.r');
        
        % Mark left and right edges of peakset
        subplot(2,2,3); 
        plot(edgeidx(1), ydata(edgeidx(1)) - median(ydata(left_base)), ...
            'ok', ...
            edgeidx(2), ydata(edgeidx(2)) - median(ydata(left_base)), 'ok')
        
        % Plot left and right baselines of peakset
        subplot(2,2,3); 
        plot(left_base, freqdata(left_base), '.g'); 
        plot(right_base, freqdata(right_base), '.g');
        
        % Mark segments of left and right baseline that were searched over
        % to find the final baseline segments (for debugging)
        subplot(2,2,3); 
        plot(leftedgesearch, freqdata(leftedgesearch), '.c'); 
        plot(rightedgesearch, freqdata(rightedgesearch), '.c');
        
        set(gca,'XLim',[min(left_base) max(right_base)]);
        set(gca,'YLim',[1.1*min(freqdata)  1.1*max(freqdata)]);
        
        input('Continue?')
        
    end
    end
    
    if(isempty(left_base) || isempty(right_base))
        disp('Skipping this peakset...')
        left_base = [];
        right_base = [];
        edgeidx = [];
        return
    else
        exitflag = 1;
    end
    
end
return

end
