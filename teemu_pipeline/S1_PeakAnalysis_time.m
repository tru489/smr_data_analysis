function data = S1_PeakAnalysis_time(x, s, datalast, sectionnumber, analysisparam, save_dir)

% Original by Sungmin Son
% Written by Nikita Khlystov
% Latest edit: 12/16

global xdata
global ydata
global left_base
global right_base
global segmentbound
global elapsed_time;
global samplepeak
global sampletime 
global sidelength;

analysismode = analysisparam(1);
dispprogress = analysisparam(2);

% clear all S1 variables
pkidx_poly = [];
apkidx_poly = [];
pk_t = [];
apk_t = [];
pkht_poly = [];
apkht_poly = [];
peakwidth = [];
pk_leftbase = [];
pk_rightbase = [];
baselinedist = [];
baselineslope = [];
htdiff_poly = [];
ahtdiff_poly = [];                                                                                          
pknum = [];
sectnum = [];
pkorder = [];
% x(3.09e6:3.15e6)=1182;                        
% x=x(0.5e6:end);
% medianfreq = median(x);
%x=x-median(x);

% cutoffdev = 3000;                                                                            % set cutoff +/- 250 Hz from average of data set
% a = abs(x - avgfreq) > cutoffdev;                                                           % find the outliers
% b = abs(x - avgfreq) < cutoffdev;                                                           % collect all other data values
% x(a) = mean(x(b));                                                                          % set the values of outlier points to the average of non-outlier points
% a=find(x<1000);
% x(a)=mean(x);
ydata = sgolayfilt(sgolayfilt(x, 3, 7), 3, 7);                                              % this is the smoothed frequency data
% idx0=find(ydata<=0);
% ydata(idx0)=1;
xdata = [1:length(ydata)]';                                                                 % these are just indices

% % convert time file to real time
% time_separator_begin=[1 (find(diff(s)>0.1))'+1];
% time_separator_end=[(find(diff(s)>0.1))' length(s)];
% for time_i=1:length(time_separator_begin)
%     sg_idx=time_separator_begin(time_i):time_separator_end(time_i);
%     t(sg_idx)=s(sg_idx(1))+cumsum(1./ydata(sg_idx));
% end
% t=t-t(1);
% t=t';
t=s;
t=t-t(1);
% 
  ydata=ydata;
disp('Finding peak indices...')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Baseline selection
% Optimize using below parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

diff_threshold = 0.01;      % Find extremely flat part of curve (sys1)
med_filt_wd = 50;           % window of median filter, which removes the flat part in the anti-node
bs_dev_thres = 0.5;         % threshold used to remove the flat part in the anti-node
unqPeakDist = 250;          % distance over which is a unique 2nd mode peaks
offset_input = 5;           % baseline offset to select for peaks

idx = find(abs(diff(ydata))<diff_threshold);                                                  

% ignore the flat points found over the anti-node
mf_ydata_thres=medfilt1(ydata(idx), med_filt_wd);
idx_f=find(abs(ydata(idx)-mf_ydata_thres)<bs_dev_thres);
idx=idx(idx_f);
ydata_thres(idx) = smooth(ydata(idx), 2);      % window=2
% filter extreme outliers.
% in density measurement flat part forms in outliers
idx_in=find(ydata(idx)<3000);
idx=idx(idx_in);

ydata_thres=interp1(xdata(idx), ydata(idx), xdata);
% j=1;
% for i=1:length(ydata)
%     if j>length(idx)
%         ydata_thres(i) = ydata_thres(idx(j-1));
%     else
%         if i < idx(j)
%             ydata_thres(i) = ydata_thres(idx(j));
%         else
%             j=j+1;
%         end
%     end
% end

% offset_input=input('Input offset(default 50)=');
% if isempty(offset_input)
%     offset_input=50;
% end

ydata_thres=ydata_thres-offset_input;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

idx = find(ydata < ydata_thres);                                                  % find all y_diff values that pass this threshold - these are the main peaks

repeatflag = 1;
while(repeatflag == 1)
    
    if ~isempty(idx)
        idx_ends = find(abs(diff(idx)) > 1);                                                    % find all breaks in y_diff indices; each segment is a peak of interest, with end on idx_end and start on (idx_end + 1)
        idx_ends = [0 idx_ends' length(idx)];                                                   % cap the beginning and end of idx with markers

        peak_idx = zeros(1,length(idx_ends) - 1);                                               % set empty matrix for loop efficiency

        for i = 1:length(idx_ends) - 1
            ydata_segment = ydata(idx(idx_ends(i)+1:idx_ends(i + 1)));                        % focus on the piece of y_diff between two consecutive idx_end markers
            segment_idx_max = min(find(ydata_segment == min(ydata_segment)));                      % find index of the maximum deviation, i.e. the apex within the piece
            global_idx_max = idx(idx_ends(i) + 1) + segment_idx_max - 1;
            peak_idx(i) = global_idx_max(1);                                                       % convert the apex index to the global index within y_diff      
        end
        
        unique_peaks = diff([peak_idx length(xdata)]) > unqPeakDist;
        peak_idx = peak_idx(unique_peaks);                                                      % which for single-cell 2nd-mode peaks are 3n+1, and thus we are saving the each third peak
                                                                                                %%% now we have the global indices of the main peaks in this segment of
                                                                                                %%% the entire frequency data


        peak_dist = diff([xdata(1) peak_idx xdata(end)]);                                       % find distance between peaks in terms of indices        
        repeatflag = 0;
        disp('...Done.')
    else
        disp('No peak found in this section');
        repeatflag = 0;
        data=zeros(13,1); elapsed_time = elapsed_time + t(end);  
        return;
    end
end



disp(' ')
disp('Segmentizing the dataset...')

segmentbound = zeros(1,length(peak_idx));
segmentbound(1) = round(peak_dist(1) + 0.5*peak_dist(2));
for i = 2:length(peak_idx)
    segmentbound(i) = round(segmentbound(i - 1) + 0.5*peak_dist(i) + 0.5*peak_dist(i + 1));
end
segmentbound = [1 segmentbound];
segment_med_wd = round(median(diff(segmentbound))/10);
set(gca,'XLim',[0 length(xdata)]);
set(gca,'YLim',[min(ydata) - 10 max(ydata) + 10]);
disp('Done.')

%%=======================================================================
%% ==================== INDIVIDUAL PEAK ANALYSIS================ %%
%% ==============================================================%%
disp(' ')
disp('Beginning individual peak analysis.')
i = 0;

%-------------- Segmentizing the dataset -------------------------%%
segment_threshold=300; %number of data points from peaks. 
sidelength = 3000; %number of more indices on each side of baseline 
 
for i=1:length(peak_idx)
    
    if min(abs(peak_idx(i)-segmentbound(i)), abs(peak_idx(i)-segmentbound(i+1))) > segment_threshold
    
        local_xdata = xdata(segmentbound(i):segmentbound(i + 1)) - xdata(segmentbound(i)) + 1;
        local_ydata = ydata(segmentbound(i):segmentbound(i + 1));
    
    
        
    
    %%%%%%%% USER ADJUSTABLE %%%%%%%%
    edgethres = 0.3;               % choose the first point left/right of the secondary peaks 40% percent of the average baseline freqvalue
    stdevmultiplier = 3;         % allow 102% of the minimum standard deviation
    diffmultiplier = 1;           % allow 90% of the deviation from mean frequency closest to 2ndary peaks
    winsize = 50;                  % number of points to be collected for baseline selection
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    baseparams = [stdevmultiplier diffmultiplier edgethres winsize diff_threshold med_filt_wd bs_dev_thres];
    
    %%% Identify primary and secondary peaks within segment:
    disp(' ')
    disp('Locating segment peaks...')
    peaks = S2_PeaksetFinder(local_xdata, local_ydata, offset_input, baseparams, analysismode);  
    disp('...Done.')
    
    if numel(peaks)~=0
        
        
    peakdist_temp = peaks(end)-peaks(1);
    %%% Identify left- and right-hand baselines within segment:
    disp(' ')
    disp('Identifying baseline...')
    
    [left_base right_base edgeidx] = S2_BaselineFinder(local_xdata, local_ydata, peaks, baseparams, peakdist_temp, analysismode);  
    if(numel(left_base) == 0 || numel(right_base) == 0 || numel(edgeidx) == 0 || numel(peaks) == 0)
    i=i+1;   
    else
        
        
        
        local_peakwidth = diff(edgeidx);  %probably we won't use it.
        
        pk_xdata = local_xdata(left_base(1):right_base(end)) - local_xdata(left_base(1)) + 1;
        pk_ydata = local_ydata(left_base(1):right_base(end));
        
        
       
        
        local_peaks = peaks - left_base(1) + 1;
        local_baseline = [left_base - left_base(1) + 1, right_base - left_base(1) + 1];
        disp('...Done.')
        
%         input('continue?');
        %%% Perform polynomial fits to refine peak location and to measure peak height:
        disp(' ')
        disp('Performing polynomial fit on segment peaks...')
        [local_pkidx_poly, local_pkht_poly, local_apkidx_poly, local_apkht_poly, local_baselineslope, local_htdiff_poly, local_ahtdiff_poly] ...
            = S2_PeakFitter(pk_xdata, pk_ydata, local_baseline, local_peaks, local_peakwidth, dispprogress); 
        disp('...Done.')
        disp(' ')
        
         %% ---------------- added by JK 09/18/14 ------
        %here we are trying to save the mode shape for each peak detected
     
       
        %% Input Experiment parameters
            Experiment.R = 32768;
            Experiment.decimation = 1;
            Experiment.Fs = 100e6 / Experiment.R / Experiment.decimation;

       
        temppeak = local_ydata(left_base(1): right_base(end));
        
        temptime = [t(segmentbound(i) + left_base(1))+1/Experiment.Fs:1/Experiment.Fs:t(segmentbound(i) + left_base(1))+1/Experiment.Fs*length(temppeak)];
        samplepeak=[samplepeak temppeak' 1e3 i sectionnumber]; 
        sampletime = [sampletime temptime 0 i sectionnumber];
        % 0 is to distinguish different peaks

        format shortg
        fprintf('------- Section %1.0f ------ \n', sectionnumber);
        fprintf('-- Data for Segment %1.0f -- \n', i);
        fprintf('Baseline slope: %1.5f \n', local_baselineslope);
        fprintf('2nd mode %%diff: %1.5f \n', local_htdiff_poly);
        fprintf('-------------------------- \n')
        disp(' ')

        pkidx_poly = [pkidx_poly local_pkidx_poly + segmentbound(i) + left_base(1)];
        apkidx_poly = [apkidx_poly local_apkidx_poly + segmentbound(i) + left_base(1)];
        pk_t = [pk_t t(local_pkidx_poly + segmentbound(i) + left_base(1))'];
        apk_t = [apk_t t(local_apkidx_poly + segmentbound(i) + left_base(1))' 0];
        pkht_poly = [pkht_poly local_pkht_poly];
        apkht_poly = [apkht_poly local_apkht_poly 0];
        peakwidth = [peakwidth local_peakwidth*ones(1,length(peaks))];
        pk_leftbase = [pk_leftbase mean(local_ydata(left_base))*ones(1,length(peaks))];
        pk_rightbase = [pk_rightbase mean(local_ydata(right_base))*ones(1,length(peaks))];
        baselinedist = [baselinedist (right_base(end) - left_base(1) + 1)*ones(1,length(peaks))];
        baselineslope = [baselineslope local_baselineslope*ones(1,length(peaks))];
        htdiff_poly = [htdiff_poly local_htdiff_poly*ones(1,length(peaks))];
        ahtdiff_poly = [ahtdiff_poly local_ahtdiff_poly*ones(1,length(peaks))];
        pknum = [pknum 1:length(peaks)];
        pkorder = [pkorder i*ones(1,length(peaks))];
        sectnum = [sectnum sectionnumber*ones(1,length(peaks))];

       
         if dispprogress == 1
          hold off; drawnow;
            figure(1);
       
        subplot(2,2,[1 2]); plot(xdata, ydata, '-'); 
        hold on;
        subplot(2,2,[1 2]); plot(peak_idx, ydata(peak_idx), '.r');
        subplot(2,2,[1 2]); plot(left_base + segmentbound(i), ydata(left_base + segmentbound(i)), '.g', right_base + segmentbound(i), ydata(right_base + segmentbound(i)), '.g')
%         if (left_base(1)-segment_med_wd<1)
%             subplot(2,2,[1 2]); plot(left_base-left_base(1)+1, ydata(left_base-left_base(1)+1), '.g', ...
%                 right_base + peak_idx(i)-segment_med_wd, ydata(right_base + peak_idx(i)-segment_med_wd), '.g')
%         else
%             subplot(2,2,[1 2]); plot(left_base + peak_idx(i)-segment_med_wd, ydata(left_base + peak_idx(i)-segment_med_wd), '.g', ...
%                 right_base + peak_idx(i)-segment_med_wd, ydata(right_base + peak_idx(i)-segment_med_wd), '.g')
%         end
%         subplot(2,2,[1 2]); plot(left_base + peak_idx(i)-segment_med_wd, ydata(left_base + peak_idx(i)-segment_med_wd), '.g', ...
%             right_base + peak_idx(i)-segment_med_wd, ydata(right_base + peak_idx(i)-segment_med_wd), '.g')
        subplot(2,2,[1 2]); plot(xdata(peak_idx(i)), ydata(peak_idx(i)), '.c');                 % mark last analyzed peakset
        subplot(2,2,[1 2]); line([segmentbound' segmentbound'], [-200 200], 'Color', 'k', 'LineStyle', ':')
        subplot(2,2,[1 2]); plot(xdata, ydata_thres, 'k')
        set(gca,'XLim',[0 length(xdata)]);
        set(gca,'YLim',[min(ydata) - 10 max(ydata) + 10]); hold off;
   
                                                                                            % Plot all peak heights over time in bottom right graph
        if sum(datalast)==0
            subplot(2,2,4); plot(elapsed_time + pk_t, pkht_poly, '.')                       % add each new analyzed point to this existing plot
            hold on
        else
            subplot(2,2,4); plot(datalast(1,2:end), datalast(2,2:end), '.')                     % plot all previous data points
            hold on
            subplot(2,2,4); plot(elapsed_time + pk_t, pkht_poly, '.')                       % add each new analyzed point to this existing plot
        end
        
        subplot(2,2,4); plot(pk_t((end - length(peaks) + 1):end) + elapsed_time, pkht_poly((end - length(peaks) + 1):end), 'or') % highlight last point
        hold off
        
         else
            clc
         end
        
        if(analysismode ~= 1)
            input('Hit ENTER to continue with analysis, CTRL+C to stop analysis......  ');
        end

       
        
        i=i+1;
    end
    else
        disp('no good peaks in this segment');
    end
    
    else
       disp('JK: skipping this segment. Too short for baseline selection');
    end
    
end
%%% assign peak number in data matrix (1,2,3)

if (~isempty(pk_t))
    data(1,:) = pk_t + elapsed_time;
    data(2,:) = pkht_poly;
    data(3,:) = peakwidth;
    data(4,:) = pk_leftbase;
    data(5,:) = pk_rightbase;
    data(6,:) = baselinedist;
    data(7,:) = baselineslope;
    data(8,:) = apkht_poly;    %node deviation
    data(9,:) = ahtdiff_poly;   %FWHM
    data(10,:) = sectnum;
    data(11,:) = pknum;
    data(12,:) = pkorder;
    data(13,:) = 0;
    
    %% baseline left to right distance
    %% 1st order baseline fit slope before flattening
    %% percent difference between 2nd mode peaks
    save([save_dir filesep 'data.csv'],'data','-ascii','-double','-append');                                   % save the current processing
else
    disp('No GOOD peak found in this section');
    data=zeros(13,1);
end

elapsed_time = elapsed_time + t(end);                                            % update initial time for the next iteration

disp(' ')

return

end