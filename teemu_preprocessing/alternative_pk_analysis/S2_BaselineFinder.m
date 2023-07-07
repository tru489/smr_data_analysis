function [left_base, right_base, edgeidx] = S2_BaselineFinder(xdata, ydata, peaks, baseparams,peakdist, analysismode)

%%% Written by Nikita Khlystov
%%% Latest edit: 12/16

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    S2 PART II: Find baselines    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% baseparams = [stdevmultiplier diffmultiplier edgethres winsize];
stdevmultiplier = baseparams(1);
diffmultiplier = baseparams(2);
edgethres = baseparams(3);
winsize = baseparams(4);

% locally smooth ydata again
ydata=smooth(ydata, 50);


exitflag = 0;
while exitflag == 0
    try
        leftedgesearch = (peaks(1) - 4*winsize):1:peaks(1);
%         edgeidx(1) = min(find(diff(ydata(leftedgesearch)) < -edgethres)) + peaks(1) - 4*winsize;
        edgeidx(1) = leftedgesearch(min(find((diff(ydata(leftedgesearch))) < -edgethres)));
        rightedgesearch = peaks(end):1:(peaks(end) + 4*winsize);
%         edgeidx(2) = max(find(diff(ydata(rightedgesearch)) > edgethres)) + peaks(end);
        edgeidx(2) = rightedgesearch(max(find((diff(ydata(rightedgesearch))) > edgethres)));
      
        meanedgefreq(1) = mean(ydata((edgeidx(1)-winsize):edgeidx(1)));
        meanedgefreq(2) = mean(ydata(edgeidx(2):(edgeidx(2)+winsize)));

        leftsearchidx = fliplr(edgeidx(1):-winsize:1);
        rightsearchidx = edgeidx(2):winsize:length(xdata);
    
        leftstdevs = zeros(1,length(leftsearchidx)-1);
        rightstdevs = zeros(1,length(rightsearchidx)-1);
        leftmeans = leftstdevs;
        leftdiff = leftstdevs;
        rightmeans = rightstdevs;
        rightdiff = rightstdevs;
        for j = 1:(length(leftsearchidx)-1)
            leftstdevs(j) = ((abs(peaks(1) - leftsearchidx(j)) + 1)/(winsize)+1)*std(ydata(leftsearchidx(j):leftsearchidx(j+1)));
%             leftstdevs(j) = std(ydata(leftsearchidx(j):leftsearchidx(j+1)));
            leftmeans(j) = mean(ydata(leftsearchidx(j):leftsearchidx(j+1)));
            leftdiff(j) = max(ydata(leftsearchidx(j):leftsearchidx(j+1)))-min(ydata(leftsearchidx(j):leftsearchidx(j+1)));
        end
        for j = 1:(length(rightsearchidx) - 1)
            rightstdevs(j) = ((abs(peaks(end) - rightsearchidx(j)) + 1)/(winsize)+1)*std(ydata(rightsearchidx(j):rightsearchidx(j+1)));
%             rightstdevs(j) = std(ydata(rightsearchidx(j):rightsearchidx(j+1)));
            rightmeans(j) = mean(ydata(rightsearchidx(j):rightsearchidx(j+1)));
            rightdiff(j) = max(ydata(rightsearchidx(j):rightsearchidx(j+1)))-min(ydata(rightsearchidx(j):rightsearchidx(j+1)));
        end
       
        
        offset_length=round((edgeidx(2)-edgeidx(1))/15);
%         minleftbaseidx = find((leftstdevs < stdevmultiplier*min(leftstdevs)).*(abs(leftmeans - meanedgefreq(1)) <= diffmultiplier*median(leftdiff)), 1, 'last');
%         minleftbaseidx = find((leftstdevs < stdevmultiplier*min(leftstdevs)), 1, 'last');
%         left_base = leftsearchidx(minleftbaseidx):1:(leftsearchidx(minleftbaseidx)+winsize);
        
%% JK's finding of the baseline.
%instead of selecting the baseline at the edge, select lots of datapoints,
%and take a median value out of it. (we can safely do this since the
%baselineslope will be negligible in the bead case).
       
         sidelength=4*peakdist;
        left_base = max(edgeidx(1)-sidelength,1):1:edgeidx(1)-offset_length;
%         minrightbaseidx = find((rightstdevs < stdevmultiplier*min(rightstdevs)).*(abs(rightmeans - meanedgefreq(2)) <= diffmultiplier*median(rightdiff)), 1);
%         minrightbaseidx = find((rightstdevs < stdevmultiplier*min(rightstdevs)), 1);
        right_base = edgeidx(2)+offset_length:1:min(edgeidx(2)+sidelength, length(ydata));
         
        if analysismode==0
        hold off
        subplot(2,2,3); plot(xdata, ydata, '-');
        hold on
        subplot(2,2,3); plot(peaks, ydata(peaks), '.r');
        subplot(2,2,3); plot(edgeidx(1),meanedgefreq(1),'ok',edgeidx(2),meanedgefreq(2),'ok')
        set(gca,'XLim',[0 length(xdata)]);
        set(gca,'YLim',[min(ydata) - 10 max(ydata) + 10]);
          
        subplot(2,2,3); plot(left_base, ydata(left_base), '.g', right_base, ydata(right_base), '.g')
         end
        if(isempty(left_base) || isempty(right_base))
            disp('Skipping this peakset...') 
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

    catch error
%         if strcmp(error.identifier, 'MATLAB:badRectangle')
% 
%             hold off
%             subplot(2,2,3); plot(xdata, ydata, '-');
%             hold on
%             subplot(2,2,3); plot(peaks, ydata(peaks), '.r');
%             subplot(2,2,3); plot(edgeidx(1),meanedgefreq(1),'og',edgeidx(2),meanedgefreq(2),'og')
%             set(gca,'XLim',[0 length(xdata)]);
%             set(gca,'YLim',[min(ydata) - 10 max(ydata) + 10]);
% 
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
%         else
            disp('Skipping this peakset...')
            left_base = [];
            right_base = [];
            edgeidx = [];
            return
%         end

    end
end
return
end
