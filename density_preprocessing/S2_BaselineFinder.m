function [left_base, right_base, edgeidx] = S2_BaselineFinder(xdata, ydata, peaks, baseparams,peakdist, analysismode)

%%% Written by Nikita Khlystov
%%% Latest edit: 12/16

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    S2 PART II: Find baselines    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% baseparams = [stdevmultiplier diffmultiplier edgethres winsize];
stdevmultiplier = baseparams(1);
diffmultiplier = baseparams(2);

%================ New way of selecting baseline motivated by small size
%particles
winsize = baseparams(4);
% edgethres = baseparams(3)
if min(ydata)<-2000 || max(ydata)>2000      % edit on 01062021
    ydata1=ydata(1:min(peaks(end)+winsize, length(ydata)));    % duet to the high noise introduced by switching flow, remove freq data at the end of the segment
    edgethres = baseparams(3)*abs(median(ydata1)-min(ydata1))/100; %Accounts for edge threshold to be smaller for small cells
else
    edgethres = baseparams(3)*abs(median(ydata)-min(ydata))/100; %Accounts for edge threshold to be smaller for small cells
end


% locally smooth ydata again
% ydata=smooth(ydata, 50);


%New way of accounting for transit time
% add on 01052021
edgethres = edgethres/(peakdist/200); %assuming 400 data points per transit gives peak_dist of 200
winsize = round(winsize*peakdist/200);

% locally smooth ydata again just for baseline finding...
sgolay_length_idx_base = 7; %this will make default length of 5 for 100 idx index
sgolay_length_base = 2*round(sgolay_length_idx_base*(peakdist/200))+1;
if sgolay_length_base >5
    ydata= sgolayfilt(ydata, 3, sgolay_length_base);
else
    ydata= sgolayfilt(ydata, 3, 5);
end


exitflag = 0;
while exitflag == 0
    leftedgesearch = max(1,(peaks(1) - 4*winsize)):1:peaks(1);
    rightedgesearch = peaks(end):1:min((peaks(end) + 4*winsize) , length(ydata));
    
    if (isempty(find((diff(ydata(leftedgesearch))) < -edgethres)) || isempty(find((diff(ydata(rightedgesearch))) > edgethres)))
        disp('Skipping this peakset... no proper edge found') 
         
        left_base = [];
        right_base = [];
        edgeidx = []; exitflag=1;
        return
    end
        
%         edgeidx(1) = min(find(diff(ydata(leftedgesearch)) < -edgethres)) + peaks(1) - 4*winsize;
        edgeidx(1) = leftedgesearch(min(find((diff(ydata(leftedgesearch))) < -edgethres)));
      
%         edgeidx(2) = max(find(diff(ydata(rightedgesearch)) > edgethres)) + peaks(end);
        edgeidx(2) = rightedgesearch(max(find((diff(ydata(rightedgesearch))) > edgethres)));
        
           
        
        
        meanedgefreq(1) = mean(ydata(max(1,(edgeidx(1)-winsize)):edgeidx(1)));
        meanedgefreq(2) = mean(ydata(edgeidx(2):min((edgeidx(2)+winsize),length(ydata))));

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
       
        
        offset_length=round((edgeidx(2)-edgeidx(1))/80);
%         minleftbaseidx = find((leftstdevs < stdevmultiplier*min(leftstdevs)).*(abs(leftmeans - meanedgefreq(1)) <= diffmultiplier*median(leftdiff)), 1, 'last');
%         minleftbaseidx = find((leftstdevs < stdevmultiplier*min(leftstdevs)), 1, 'last');
%         left_base = leftsearchidx(minleftbaseidx):1:(leftsearchidx(minleftbaseidx)+winsize);
        
%% JK's finding of the baseline.
%instead of selecting the baseline at the edge, select lots of datapoints,
%and take a median value out of it. (we can safely do this since the
%baselineslope will be negligible in the bead case).


        %%%%%===============CHANGE HERE FOR BASELINE LENGHT========================
         sidelength=round(2*0.25*peakdist);
         offset_length=25;    % edit on 01062021
         
        %%%========================================================= 
        left_base = max(edgeidx(1)-sidelength-offset_length,1):1:edgeidx(1)-offset_length;
%         minrightbaseidx = find((rightstdevs < stdevmultiplier*min(rightstdevs)).*(abs(rightmeans - meanedgefreq(2)) <= diffmultiplier*median(rightdiff)), 1);
%         minrightbaseidx = find((rightstdevs < stdevmultiplier*min(rightstdevs)), 1);
        right_base = edgeidx(2)+offset_length:1:min(edgeidx(2)+sidelength+offset_length, length(ydata));
       
        if analysismode==0  
        freqdata = ydata - median(ydata(left_base));
        drawnow;
        hold off
        subplot(2,2,3); plot(xdata, freqdata, '-');
        hold on
        subplot(2,2,3); plot(peaks, freqdata(peaks), '.r');
        subplot(2,2,3); plot(edgeidx(1),meanedgefreq(1)- median(ydata(left_base)),'ok',edgeidx(2),meanedgefreq(2) -median(ydata(left_base)),'ok')
        set(gca,'XLim',[0 length(xdata)]);
        if isnan(min(freqdata)) || isnan(max(freqdata))
            set(gca,'YLim',[-5000 5000])
        else
            set(gca,'YLim',[1.1*min(freqdata)  1.1*max(freqdata)]);
        end

        subplot(2,2,3); plot(left_base, freqdata(left_base), '.g'); plot(right_base, freqdata(right_base), '.g');
        numel(left_base)
        numel(right_base)

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

%     catch error
% %         if strcmp(error.identifier, 'MATLAB:badRectangle')
% % 
% %             hold off
% %             subplot(2,2,3); plot(xdata, ydata, '-');
% %             hold on
% %             subplot(2,2,3); plot(peaks, ydata(peaks), '.r');
% %             subplot(2,2,3); plot(edgeidx(1),meanedgefreq(1),'og',edgeidx(2),meanedgefreq(2),'og')
% %             set(gca,'XLim',[0 length(xdata)]);
% %             set(gca,'YLim',[min(ydata) - 10 max(ydata) + 10]);
% % 
% %             fprintf('No valid baselines could be found because selection criteria is too strict. Please adjust parameters. \n')
% %             fprintf('Previous stdevmultiplier:      %1.3f \n', stdevmultiplier)
% %             fprintf('Previous diffmultiplier:       %1.3f \n', diffmultiplier)
% %             fprintf('Previous edgethres:         %1.1f \n', edgethres)
% %             stdevmultiplier = input('Input new stdevmultiplier:     ');
% %             diffmultiplier = input('Input new diffmultiplier:      ');
% %             edgethres = input('Input new edgethres:        ');
% %             if stdevmultiplier == 0  || diffmultiplier == 0
% %                 disp('Skipping this peakset...')
% %                 left_base = [];
% %                 right_base = [];
% %                 edgeidx = [];
% %                 return
% %             end
% %         else
%             disp('Skipping this peakset...')
%             input('goll');
%             left_base = [];
%             right_base = [];
%             edgeidx = [];
%             return
% %         end
% 
%     end
end
return
end
