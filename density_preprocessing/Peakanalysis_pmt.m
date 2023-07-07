function [data1, data2, data3] = Peakanalysis_pmt(x1, x2, x3, s, analysisparam)

% Original by Joon Ho Kang
% Edit: 12/29/2015

xdata=[]; xorgdata=[];
ydata1=[];
ydata2=[];
ydata3=[];
global peakamplitude
global elapsed_time;
global elapsed_index;
 
% tempamplitude1 = datalast(2,:);
% tempamplitude2 = datalast(4,:);
% tempamplitude3 = datalast(6,:);

analysismode = analysisparam(1);
dispprogress = analysisparam(2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OFFSET INPUT CALCULATION START
% Optimize using below parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    offset_input1 = 0.01; %DAPI
    offset_input2 = 0.01; %FITC
    offset_input3 = 0.01; %PE
    uniqpeak = 200;
    med_filt_wd_offset = 2000;           % window of median filter, which removes the flat part in the anti-node
    bs_dev_thres = 0.02;         % threshold used to remove the flat part in the anti-node

    cutoff1 = 0.02; %not using this
    cutoff2 = 0.02; %not using this
    cutoff3 = 0.02;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OFFSET INPUT CALCULATION DONE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%% Roughly detect 1st mode Peak in index
idxon = find(x2 > cutoff2);
xorgdata = [1:length(x2)]';
if numel(idxon)<med_filt_wd_offset
    fprintf('no PMT signal above our cutoff: %1.3f', cutoff2); disp(' ');
    data1=[]; data2=[]; data3=[];
    elapsed_time = elapsed_time + (s(end) - s(1));
    elapsed_index = elapsed_index + length(x1);
    return;
end

ydata1 = x1(idxon);
ydata2 = x2(idxon);
ydata3 = x3(idxon);


t = s(idxon); 
t = t - s(1); %making the first timepoint to be 0

Data.read_1 = ydata1; 
Data.read_2 = ydata2; 
Data.read_3 = ydata3;

med1 = median(Data.read_1);
med2 = median(Data.read_2);
med3 = median(Data.read_3);

Data.normalized_1 = Data.read_1 - med1;
Data.normalized_2 = Data.read_2 - med2;
Data.normalized_3 = Data.read_3 - med3;

fprintf('median baseline for PMT1 is : %1.2f -------', median(Data.read_1)); disp(' ');
fprintf('median baseline for PMT2 is : %1.2f -------', median(Data.read_2)); disp(' ');
fprintf('median baseline for PMT3 is : %1.2f -------', median(Data.read_3)); disp(' ');
disp(' ');

%====================== Apply Median FIlter ========================
medfiltlength = 150;
Data.filtered_1 = medfilt1(Data.normalized_1, medfiltlength);
Data.filtered_2 = medfilt1(Data.normalized_2, medfiltlength);
Data.filtered_3 = medfilt1(Data.normalized_3, medfiltlength);
%===================================================================
 
    disp ('applied median filter...')
    fprintf( ' ----- default filter length is: %2.0f ----- \n', medfiltlength);
    disp (' ');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TIME and INDEX SETUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xdata=[1:length(Data.normalized_1)]';
xdata_plot = xdata;
xdatabreak = xorgdata(idxon);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mf_xdata = [1:med_filt_wd_offset:xdata(end)];
% length(mf_xdata);
mf_ydata1 = zeros(1, length(mf_xdata));
mf_ydata2 = zeros(1, length(mf_xdata));
mf_ydata3 = zeros(1, length(mf_xdata));

i=0;
while i<length(mf_xdata)-1
    i=i+1;
    
    range = mf_xdata(i):mf_xdata(i+1);
    mf_ydata1(i) = median(Data.filtered_1(range));
    mf_ydata2(i) = median(Data.filtered_2(range));
    mf_ydata3(i) = median(Data.filtered_3(range));
    
end
    if mf_xdata(end) == xdata(end)
        mf_ydata1(end) = mf_ydata1(end-1);
        mf_ydata2(end) = mf_ydata2(end-1);
        mf_ydata3(end) = mf_ydata3(end-1);
    else % if end is different
        mf_ydata1(end) = median(Data.filtered_1([mf_xdata(end):xdata(end)]));
        mf_ydata2(end) = median(Data.filtered_2([mf_xdata(end):xdata(end)]));
        mf_ydata3(end) = median(Data.filtered_3([mf_xdata(end):xdata(end)]));
    end
    

baseline1=interp1(mf_xdata, mf_ydata1, xdata, 'linear', 'extrap');
baseline2=interp1(mf_xdata, mf_ydata2, xdata, 'linear', 'extrap');
baseline3=interp1(mf_xdata, mf_ydata3, xdata, 'linear', 'extrap');

Process.peak_threshold1=baseline1 + offset_input1;
Process.peak_threshold2=baseline2 + offset_input2;
Process.peak_threshold3=baseline3 + offset_input3;

repeatflag = 1;
while(repeatflag == 1)
     
%     % Apply moving average filter to the raw data
%     windowSize1 = 100;
%     b1 = (1/windowSize1)*ones(1,windowSize1);
%     a1=1;
%     
%     Data.filtered_12 = filter(b1,a1,Data.normalized_1);
%     Data.filtered_22 = filter(b1,a1,Data.normalized_2);
%     Data.filtered_32 = filter(b1,a1,Data.normalized_3);
    
%     disp ('applying moving average filter...')
%     fprintf( ' ----- default windowsize for raw data is: %2.0f ----- \n', windowSize1);
%     disp (' ');
    
    % Apply moving average filter to the median filtered data
    windowSize2 = 5;
    b2 = (1/windowSize2)*ones(1,windowSize2);
    a2=1;
    
    Data.filtered_13 = filter(b2,a2,Data.filtered_1);%%applying moving average filter to the median filtered se
    Data.filtered_23 = filter(b2,a2,Data.filtered_2);
    Data.filtered_33 = filter(b2,a2,Data.filtered_3);
    disp ('applying moving average filter...')
    
    fprintf( ' ----- default windowsize for median filtered data is: %2.0f ----- \n', windowSize2);
    disp (' ');
    
    
    %%%================================================================================
    %   Find rough peak indices
    peak_indices{1} = find(Data.filtered_1 > Process.peak_threshold1)'; %%this is rough estimates
    peak_indices{2} = find(Data.filtered_2 > Process.peak_threshold2)';
    peak_indices{3} = find(Data.filtered_3 > Process.peak_threshold3)';
    %%%================================================================================
    

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % FINDING PEAK RANGE
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:3
        
        if ~isempty(peak_indices{i})
            Peak.start{i} = [peak_indices{i}(1) peak_indices{i}([0 diff(peak_indices{i})]>uniqpeak)];
            Peak.end{i} = fliplr([peak_indices{i}(end) fliplr(peak_indices{i}(fliplr([0 diff(fliplr(peak_indices{i}))]<-uniqpeak)))]);
            Peak.count{i} = length(Peak.end{i});
        else
            Peak.start{i}=[];
            Peak.end{i}=[];
            Peak.count{i}=length(Peak.end{i});
        end
        
        Save.start{i} = Peak.start{i};  %These are the value to be kept throughout the code. Peak values will be modified step by step
        Save.end{i} = Peak.end{i};
        Save.count{i} = length(Save.end{i});
    end
    
    
    if Save.count{1}==0 & Save.count{2}==0 & Save.count{3}==0 
        disp('No peak found in this section');
        data1=[]; data2=[]; data3=[];
        repeatflag = 0; 
        elapsed_time = elapsed_time + (s(end) - s(1));
        elapsed_index = elapsed_index + length(x1);
        return;
        
        
    else 
      totalnumpeaks=0; exitflag = 0;  
      
      while (exitflag ~=1)
        totalnumpeaks=totalnumpeaks+1;
        nonemptych=[]; minchsearch=[];
        
        nonemptych = find(~cellfun(@isempty, Peak.start)); %find channels that have non empty Peak.start
        num_nonempty = length(nonemptych);
        
        minstart = min([Peak.start{nonemptych}]); %find smallest index of a given range
       
        % It is somewhat complicated, but this is to onyl search for the
        % channel that gives the minimum start index...
        for i=1:num_nonempty
           minchsearch(i) = ismember(minstart, Peak.start{nonemptych(i)});
        end
       
        minch = nonemptych(find(minchsearch(:)));
        
       otherch = setxor(minch(1), nonemptych);
       if isempty(otherch)==1 %if there is only one channel remaining to be analyzed
           tempstart = Peak.start{minch(1)}(1)-50;
           tempend = Peak.end{minch(1)}(1)+50;
           
           
       
       elseif length(otherch)==1 %there is two channles that passed the peak threshold
          unionrange = union([Peak.start{minch(1)}(1):Peak.end{minch(1)}(1)], [Peak.start{otherch(1)}(1): Peak.end{otherch(1)}(1)]);
          if isempty(find(diff(unionrange)>1))==1 %those have intersecting range
              tempstart = min(unionrange)-50;
              tempend = max(unionrange)+50;
              
            
              Peak.start{otherch(1)}(1)=[];
              Peak.end{otherch(1)}(1)=[];%delete peak region for next step
          
          else %they are separated
             tempstart = Peak.start{minch}(1)-50;
             tempend = Peak.end{minch}(1)+50;
             
      
          end
          
       else %there are three channels remaining to be analyzed
         unionrange12 = union([Peak.start{minch(1)}(1):Peak.end{minch(1)}(1)], [Peak.start{otherch(1)}(1): Peak.end{otherch(1)}(1)]);
         idx12 = find(diff(unionrange12)>1);
         
          if isempty(idx12)==1 %no breakage between minch1 and otherch1
              Peak.start{otherch(1)}(1)=[];
              Peak.end{otherch(1)}(1)=[];
          end
          
         unionrange13 = union([Peak.start{minch(1)}(1):Peak.end{minch(1)}(1)], [Peak.start{otherch(2)}(1): Peak.end{otherch(2)}(1)]);
         idx13 = find(diff(unionrange13)>1);
         
          if isempty(idx13)==1 %no breakage between minch1 and otherch2
              Peak.start{otherch(2)}(1)=[];
              Peak.end{otherch(2)}(1)=[];
          end
         
         
         unionrange = union(unionrange12, unionrange13);
         idx = find(diff(unionrange)>1);
         if isempty(idx)==1
             tempstart = min(unionrange)-50;
             tempend = max(unionrange)+50;
         else
             tempstart = min(unionrange)-50;
             tempend = unionrange(min(idx));
         end
             
             
       end
       
       
           Peak.start{minch(1)}(1)=[];
           Peak.end{minch(1)}(1)=[]; %delete peak region for next step
            
           maxrange = [max(tempstart,1):min(tempend, xdata(end))];
           plotrange = [max(tempstart-100,1):min(tempend+100, xdata(end))];
           
           bpoint = diff(xdatabreak);
           idxbreak = find(bpoint>100); idxbreak=[1; idxbreak];
           isbreak=intersect(idxbreak, plotrange);
           if numel(isbreak)~=0
               display('WARNING: PLOT RANGE CONTAINS FORMER PEAK BASELINE');
%                input('move on?');
           end
           
           
           
           
           
           
           local_baseline1 = median(Data.filtered_1(setxor(plotrange, maxrange)));
           local_baseline2 = median(Data.filtered_2(setxor(plotrange, maxrange)));
           local_baseline3 = median(Data.filtered_3(setxor(plotrange, maxrange)));
           i=totalnumpeaks;
            
            [Peak.amplitude1(i), Peak.location1(i)] = max(Data.filtered_13(maxrange));
            Peak.location1(i) = Peak.location1(i) + maxrange(1) - 1;
            Peak.amplitude1(i) = Peak.amplitude1(i) - local_baseline1; %correct for local baseline
            Peak.time1(i)=t(Peak.location1(i));
            Peak.baseline1(i) = local_baseline1 + med1; 
            %Since all data we are dealing with is with Data.normalized, to correctly get the baseline, addback the subtracted median value. get the baseline near the peak. added 09/13/2016
       
            [Peak.amplitude2(i), Peak.location2(i)] = max(Data.filtered_23(maxrange));
            Peak.location2(i) = Peak.location2(i) + maxrange(1) - 1;
             Peak.amplitude2(i) = Peak.amplitude2(i) - local_baseline2;
            Peak.time2(i)=t(Peak.location2(i));
            Peak.baseline2(i) = local_baseline2 + med2;
      
            [Peak.amplitude3(i), Peak.location3(i)] = max(Data.filtered_33(maxrange));
            Peak.location3(i) = Peak.location3(i) + maxrange(1) - 1;
             Peak.amplitude3(i) = Peak.amplitude3(i) - local_baseline3;
            Peak.time3(i)=t(Peak.location3(i));
            Peak.baseline3(i) = local_baseline3 + med3;
            
           
        %         size(Peak.amplitude1)
        
        if analysismode==0
            input('go1?'); dispprogress=1;
        end
        
        if dispprogress==1
        hold off; 
%         subplot(3,4,[1 3]); plot(xdata, Data.filtered_12, 'b-'); 
%         subplot(3,4,[1 3]); plot(xdata, smooth(Data.filtered_1,3), 'k-');
        subplot(3,4,[1 3]); plot(xdata_plot, Data.filtered_13, 'r-');hold on;
        subplot(3,4,[1 3]); plot(Peak.location1, Data.filtered_13(Peak.location1), '*g');
        subplot(3,4,[1 3]); plot(xdata_plot, Process.peak_threshold1, 'k'); 
        subplot(3,4,[1 3]); plot(xdata_plot, baseline1, 'LineStyle', ':'); hold off;
%         ylim([-0.02 0.2]);
        
%         subplot(3,4,[5 7]); plot(xdata, Data.filtered_22, 'b-'); hold on;
%         subplot(3,4,[5 7]); plot(xdata, smooth(Data.filtered_2,3), 'k-');
        subplot(3,4,[5 7]); plot(xdata_plot, Data.filtered_23, 'r-'); hold on;
        subplot(3,4,[5 7]); plot(Peak.location2, Data.filtered_23(Peak.location2), '*g');
        subplot(3,4,[5 7]); plot(xdata_plot, Process.peak_threshold2, 'k'); hold off;
%          ylim([-0.02 0.2]);
        
%         subplot(3,4,[9 11]); plot(xdata, Data.filtered_32, 'b-'); hold on;
%         subplot(3,4,[9 11]); plot(xdata, smooth(Data.filtered_3,3), 'k-');
        subplot(3,4,[9 11]); plot(xdata_plot, Data.filtered_33, 'r-'); hold on;
        subplot(3,4,[9 11]); plot(Peak.location3, Data.filtered_33(Peak.location3), '*g');
        subplot(3,4,[9 11]); plot(xdata_plot, Process.peak_threshold3, 'k'); 
        subplot(3,4,[9 11]); plot(xdata_plot, baseline3, 'LineStyle', ':');  hold off;
%          ylim([-0.02 0.05]);
        drawnow;

            subplot(3,4,4); plot(plotrange, Data.filtered_1(plotrange)-local_baseline1, '.', 'color', 'blue'); hold on;
                            plot(maxrange, Data.filtered_13(maxrange)-local_baseline1, '-r');
%                             plot(maxrange, Data.filtered_12(maxrange)-baseline1, '-b');
                            plot(Peak.location1(i), Peak.amplitude1(i), 'ok'); 
                            plot(plotrange, zeros(1,length(plotrange)), 'k-');  
                            if numel(isbreak)~=0
                                [trash, temp] = min(abs(idxbreak - plotrange(1)))
                                plot(idxbreak(temp), 0, 'og'); 
                            end
                            drawnow; hold off;
                            
            subplot(3,4,8); plot(plotrange, Data.filtered_2(plotrange)-local_baseline2, '.', 'color', 'blue'); hold on;
                            plot(maxrange, Data.filtered_23(maxrange)-local_baseline2, '-r');
%                             plot(maxrange, Data.filtered_22(maxrange)-baseline2, '-b');
                            plot(Peak.location2(i), Peak.amplitude2(i), 'ok'); 
                            plot(plotrange, zeros(1,length(plotrange)), 'k-');  
                             if numel(isbreak)~=0
                               
                                plot(idxbreak(temp), 0, 'og');
                             end
                            drawnow; hold off;
            
            subplot(3,4,12); plot(plotrange, Data.filtered_3(plotrange)-local_baseline3, '.', 'color', 'blue'); hold on;
                            plot(maxrange, Data.filtered_33(maxrange)-local_baseline3, '-r');
%                             plot(maxrange, Data.filtered_32(maxrange)-baseline3, '-b');
                            plot(Peak.location3(i), Peak.amplitude3(i), 'ok'); 
                            plot(plotrange, zeros(1,length(plotrange)), 'k-');  
                            if numel(isbreak)~=0
                                plot(idxbreak(temp),0, 'og');
                            end
                            drawnow; hold off;
        
        end                 
                            
            
            
%             subplot(2,2,4); hist(tempamplitude1);
            
        for i=1:3
         Peak.count{i} = length(Peak.end{i});
        end
        
%          Peak
%         
%          input('go2');
        
         if Peak.count{1}==0 & Peak.count{2}==0 & Peak.count{3}==0
             exitflag = 1;
         else
             exitflag = 0;
         end
        
       
        repeatflag = 0;
        disp('...Done.')
        
        
        
      end
        
    
    end
end

data1(1,:)=Peak.time1+elapsed_time;
data1(2,:)=Peak.amplitude1;
data1(3,:)=Peak.location1+elapsed_index;
data1(4,:)=Peak.baseline1;

data2(1,:)=Peak.time2+elapsed_time;
data2(2,:)=Peak.amplitude2;
data2(3,:)=Peak.location2+elapsed_index;
data2(4,:)=Peak.baseline2;

data3(1,:)=Peak.time3+elapsed_time;
data3(2,:)=Peak.amplitude3;
data3(3,:)=Peak.location3+elapsed_index;
data3(4,:)=Peak.baseline3;

elapsed_time = elapsed_time + (s(end) - s(1));
elapsed_index = elapsed_index + length(x1);

disp(' ')
fprintf( ' %%-- elapsed index #: %2.0f %%-- \n', elapsed_index);
fprintf('  %%-- elapsed time   : %2.0f %% --\n', elapsed_time);
disp(' ' )

disp(' ')

return


end %function end




