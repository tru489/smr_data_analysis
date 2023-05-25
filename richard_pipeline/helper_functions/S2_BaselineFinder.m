function [left_base, right_base, edgeidx] = S2_BaselineFinder(xdata, ydata, peaks, baseparams,peakdist, analysismode)

%%% Written by Nikita Khlystov
%%% Latest edit: 12/16

%% Find baselines
% New way of selecting baseline motivated by small size
edgethres = baseparams(3) * abs(max(ydata) - min(ydata)) / 100; % Accounts for edge threshold to be proportional to cell size
winsize = baseparams(4);


% New way of accounting for transit time
edgethres = edgethres / (peakdist / 200); % assuming 400 data points per transit gives peak_dist of 200
winsize = round(winsize * peakdist/200);

% Locally smooth ydata again just for baseline finding
sgolay_length_idx_base = 7; % This will make default length of 5 for 100 idx index
sgolay_length_base = 2 * round(sgolay_length_idx_base * (peakdist/200)) + 1;
if sgolay_length_base > 5
    ydata= sgolayfilt(ydata, 3, sgolay_length_base);
else
    ydata= sgolayfilt(ydata, 3, 5);
end

% Search around left and right edges of detected peak signal to find left
% and right bondaries of the signal
exitflag = 0;
while exitflag == 0
    % Set indices to search around left edge of peak signal
    leftsearch_leftbound = max(1, (peaks(1) - winsize));
    leftsearch_rightbound = max(1, peaks(1) - round(peakdist/6));
    leftedgesearch = leftsearch_leftbound:1:leftsearch_rightbound;
    
    % Set indices to search around right edge of peak signal
    rightsearch_leftbound = min(length(ydata), ...
        peaks(end) + round(peakdist / 6));
    rightsearch_rightbound = min((peaks(end) + winsize) , length(ydata));
    rightedgesearch = rightsearch_leftbound:1:rightsearch_rightbound;
    
    % Based on a derivative threshold, see if the left and right boundaries
    % capture the left and right edges of the secondary peaks
    contains_left_edge = isempty((diff(ydata(leftedgesearch))) < -edgethres);
    contains_right_edge = isempty((diff(ydata(rightedgesearch))) > edgethres);
    if contains_left_edge || contains_right_edge
        %disp('Skipping this peakset... no proper edge found')
        
        % If doesn't contain left or right edge, then skip this peakset
        left_base = [];
        right_base = [];
        edgeidx = []; exitflag=1;
        return
    end
    
    % If edges are identified, identify the left and right boundary indices 
    % that exceed the derivative threshold
    idx_idx1 = find(diff(ydata(leftedgesearch)) > -edgethres, 1, 'last');
    idx_idx2 = find(diff(ydata(rightedgesearch)) < edgethres, 1);
    
    % Set left and right boundaries to empty if boundary indices can't be
    % found for either one (if can't be found for one, set both to empty)
    if (isempty(idx_idx1) || isempty(idx_idx2))
        left_base=[];
        right_base=[];
    else
        % Set left and right boundary indices
        edgeidx(1) = leftedgesearch(idx_idx1);
        edgeidx(2) = rightedgesearch(idx_idx2);
        
        % Parameters for selecting regions around the left and right
        % boundary
        sidelength = round(0.25 * peakdist); offset_length = 0;
        
        % Slice out a region around the left boundary of the frequency
        % peak signal
        left_base_leftbound = max(edgeidx(1) - sidelength-offset_length, 1);
        left_base_rightbound = edgeidx(1) - offset_length;
        left_base = left_base_leftbound:1:left_base_rightbound;

        % Slice out a region around the right boundary of the frequency
        % peak signal
        right_base_leftbound = edgeidx(2) + offset_length;
        right_base_rightbound = ...
            min(edgeidx(2) + sidelength + offset_length, length(ydata));
        right_base = right_base_leftbound:1:right_base_rightbound;
    
        if analysismode==0
            figure(1);
            
            % Subtract baseline from ydata
            freqdata = ydata - median(ydata(left_base));
            drawnow;
            hold off
            % Plot raw frequency data
            subplot(2,2,3); plot(xdata, freqdata, '-');
            hold on

            % Plot peaks
            subplot(2,2,3); plot(peaks, freqdata(peaks), '.r');

            % Plot left and right peakset boundaries and regions selected
            % around those boundaries
            subplot(2,2,3); plot(edgeidx(1), ydata(edgeidx(1))- median(ydata(left_base)),'ok',edgeidx(2),ydata(edgeidx(2)) -median(ydata(left_base)),'ok')
            subplot(2,2,3); plot(left_base, freqdata(left_base), '.g'); plot(right_base, freqdata(right_base), '.g');
            subplot(2,2,3); plot(leftedgesearch, freqdata(leftedgesearch), '.c'); plot(rightedgesearch, freqdata(rightedgesearch), '.c');
            
            set(gca,'XLim',[min(left_base) max(right_base)]);
            set(gca,'YLim',[1.1*min(freqdata)  1.1*max(freqdata)]);
            
            input('go')
        end
    end
    
    % If either left_base or right_base is empty, then make them both empty
    % and proceed (skip this peakset)
    if(isempty(left_base) || isempty(right_base))
        %disp('Skipping this peakset...')
        left_base = [];
        right_base = [];
        edgeidx = [];
        return
        
        %             fprintf('No valid baselines could be found because selection criteria is too strict. Please adjust parameters. \n')
        %             fprintf('Previous stdevmultiplier:      %1.3f \n', stdevmultiplier)
        %             fprintf('Previous diffmultiplier:       %1.3f \n', diffmultiplier)
        %             fprintf('Previous edgethres:         %1.1f \n', edgethres)
        %             stdevmultiplier = input('Input new stdevmultiplier:     ');
        %             diffmultiplier = input('Input new diffmultiplier:      ');
        %             edgethres = input('Input new edgethres:        ');
        %             if stdevmultiplier == 0  || diffmultiplier == 0
        %                 disp('Skipping this peakset...')
        %                 left_base = [];
        %                 right_base = [];
        %                 edgeidx = [];
        %                 return
        %             end
    else
        exitflag = 1;
    end
end
return
end
