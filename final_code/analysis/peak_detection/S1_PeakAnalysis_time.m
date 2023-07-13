function [pk_data, pass_struct] = S1_PeakAnalysis_time(x, t, datalast, sectionnumber, ...
    run_params, pass_struct)
% Analyzes an individual data segment of frequency-time data to find peaks
%
% Arguments:
%   x (array(double)): frequency data array
%   t (array(double)): time data array
%   datalast (array(double)): array of data from previous segment 
%       iterations
%   sectionnumber (array(double)): current segment number
%   analysisparam (struct): preferences for displaying data analysis
% Returns:
%   pk_data (array(double)): peak data 

global left_base
global right_base
global segmentbound
global sidelength;

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

analysismode = run_params.analysis_params.analysismode;
dispprogress = run_params.analysis_params.dispprogress;

t = t - t(1);

if length(x) < 100
    disp('Data length too short; moving onto next data segment');
    pk_data = zeros(13, 1);
    pass_struct.elapsed_time = pass_struct.elapsed_time + t(end);

    return;
end

%% Baseline selection and filtering
estimated_datapoints = run_params.bl_select.estimated_datapoints;
estimated_noise = run_params.bl_select.estimated_noise;
sgolay_length_idx = run_params.bl_select.sgolay_length_idx;

sgolay_length = 2 * round(sgolay_length_idx * ...
    (estimated_datapoints / 400)) + 1;

% Filter frequency data with savitsky-golay filter
if sgolay_length > 3
    ydata = sgolayfilt(x, 3, sgolay_length); 
else
    ydata = sgolayfilt(x, 3, 5);
end

xdata = (1:length(ydata))';

diff_threshold = run_params.bl_select.diff_threshold;
med_filt_wd = run_params.bl_select.med_filt_wd;
bs_dev_thres = run_params.bl_select.bs_dev_thres;
unqPeakDist = run_params.bl_select.unqPeakDist;
offset_input = run_params.bl_select.offset_input;

diff_threshold = diff_threshold * ((estimated_noise / 0.1)^(1/2)) / ...
    (estimated_datapoints / 400);
med_filt_wd = round(med_filt_wd * estimated_datapoints / 400);
bs_dev_thres = bs_dev_thres * ((estimated_noise / 0.1)^(1/2));
unqPeakDist = round(unqPeakDist * estimated_datapoints / 400);

% Remove fast varying points (i.e. pts with high derivative) from baseline
idx = find(abs(diff(ydata)) < diff_threshold);

% Filter out the flat points found over the anti-node
mf_ydata_thres = medfilt1(ydata(idx), med_filt_wd);

idx_f = abs(ydata(idx) - mf_ydata_thres) < bs_dev_thres;
idx = idx(idx_f);

if isempty(idx)
    disp('Filtered baseline is empty; moving on to next segment');
    pk_data=zeros(13,1);
    pass_struct.elapsed_time = pass_struct.elapsed_time + t(end);
    return;
end

% Interpolate baseline based on filtering above
ydata_thres = interp1(xdata(idx), ydata(idx), xdata);

% Find datapoints that drop below offset threshold; these are main peaks
ydata_thres = ydata_thres - offset_input; 
idx = find(ydata < ydata_thres);

% Iterate through indices at which peaks were identified to find peak 
% indices
if ~isempty(idx)
    peak_idx = S1_get_peak_idx(idx, ydata);
else
    disp('No peak found; moving to next segment');
    pk_data = zeros(13,1); 
    pass_struct.elapsed_time = pass_struct.elapsed_time + t(end);  
    return;
end

if length(peak_idx) > 1
    segmentbound = zeros(1,length(peak_idx));
    
    segmentbound(1) = peak_idx(1) + round((peak_idx(2) - peak_idx(1))/2);
    
    for i = 2:length(peak_idx)-1
        segmentbound(i) = peak_idx(i) + round((peak_idx(i+1) - peak_idx(i))/2);
    end
    segmentbound(end) = xdata(end);
    segmentbound = [1 segmentbound];
    
    set(gca,'XLim',[0 length(xdata)]);
    set(gca,'YLim',[min(ydata) - 10 max(ydata) + 10]);
else
    disp('size of peak_idx is smaller than 2')
end
%%=======================================================================
%% ==================== INDIVIDUAL PEAK ANALYSIS================ %%
%% ==============================================================%%
disp(' ')
disp('Beginning individual peak analysis.')
i = 0;

%-------------- Segmentizing the dataset -------------------------%%
segment_threshold=200; %number of data points from peaks. 
segment_threshold = segment_threshold*estimated_datapoints/400;
sidelength = 3000; %number of more indices on each side of baseline 
 
for i=1:length(peak_idx)
    if min(abs(peak_idx(i)-segmentbound(i)), abs(peak_idx(i)-segmentbound(i+1))) > segment_threshold
        local_xdata = xdata(segmentbound(i):segmentbound(i + 1)) - xdata(segmentbound(i)) + 1;
        local_ydata = ydata(segmentbound(i):segmentbound(i + 1));
    
        %%%%%%%% USER ADJUSTABLE (Below is assuming 400 data points per transit) %%%%%%%%
        edgethres = 0.12;               % choose the first point left/right of the secondary peaks 40% percent of the average baseline freqvalue
        stdevmultiplier = 3;         % allow 102% of the minimum standard deviation
        diffmultiplier = 1;           % allow 90% of the deviation from mean frequency closest to 2ndary peaks
        winsize = 120;                  % number of points searching for baseline collection
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        baseparams = [stdevmultiplier diffmultiplier edgethres winsize diff_threshold med_filt_wd bs_dev_thres];
        
        %%% Identify primary and secondary peaks within segment:
        disp(' ')
        disp('Locating segment peaks...')
        peaks = S2_PeaksetFinder(local_xdata, local_ydata, offset_input, baseparams, analysismode);  
        disp('...Done.')
    
        if numel(peaks)==3
            
            
        peakdist_temp = peaks(end)-peaks(1);
        %%% Identify left- and right-hand baselines within segment:
        disp(' ')
        disp('Identifying baseline...')
        
        [left_base, right_base, edgeidx] = S2_BaselineFinder(local_xdata, local_ydata, peaks, baseparams, peakdist_temp, analysismode);  
        if(numel(left_base) == 0 || numel(right_base) == 0 || numel(edgeidx) == 0 || numel(peaks) == 0)
            i=i+1;   
        else
            local_peakwidth = diff(edgeidx);  
            
            pk_xdata = local_xdata(left_base(1):right_base(end)) - local_xdata(left_base(1)) + 1;
            pk_ydata = local_ydata(left_base(1):right_base(end));
        
            local_peaks = peaks - left_base(1) + 1;
            local_baseline = [left_base - left_base(1) + 1, right_base - left_base(1) + 1];
            disp('...Done.')
        
            %%% Perform polynomial fits to refine peak location and to measure peak height:
            disp(' ')
            disp('Performing polynomial fit on segment peaks...')
            [local_pkidx_poly, local_pkht_poly, local_apkidx_poly, local_apkht_poly, local_baselineslope, local_htdiff_poly, local_ahtdiff_poly] ...
                = S2_PeakFitter(pk_xdata, pk_ydata, local_baseline, local_peaks, local_peakwidth, dispprogress); 
            disp('...Done.')
            disp(' ')
        
            %% Input Experiment parameters
            %Experiment.R = 32768;
            Experiment.R = 10000;
            Experiment.decimation = 1;
            Experiment.Fs = 100e6 / Experiment.R / Experiment.decimation;

            temppeak = local_ydata(left_base(1): right_base(end));
            
            temptime = [t(segmentbound(i) + left_base(1))+1/Experiment.Fs:1/Experiment.Fs:t(segmentbound(i) + left_base(1))+1/Experiment.Fs*length(temppeak)];
            pass_struct.samplepeak=[pass_struct.samplepeak temppeak' 1e3 i sectionnumber]; 
            pass_struct.sampletime = [pass_struct.sampletime temptime 0 i sectionnumber];
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
        
                if (right_base + segmentbound(i))<=2000000   % trouble shooting on 12/03/2020, sometime right_base of the last peak exceeds the length of the segment
                     subplot(2,2,[1 2]); plot(left_base + segmentbound(i), ydata(left_base + segmentbound(i)), '.g', right_base + segmentbound(i), ydata(right_base + segmentbound(i)), '.g')
                else
                    subplot(2,2,[1 2]); plot(left_base + segmentbound(i), ydata(left_base + segmentbound(i)), '.g', right_base + segmentbound(i), ydata(2000000), '.g')
                end
        
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
                subplot(2,2,[1 2]); line([segmentbound' segmentbound'], [min(ydata) - 100 max(ydata) + 100], 'Color', 'k', 'LineStyle', ':')
                subplot(2,2,[1 2]); plot(xdata, ydata_thres, 'k')
                set(gca,'XLim',[0 length(xdata)]);
                set(gca,'YLim',[min(ydata) - 10 max(ydata) + 10]); hold off;
                                                                     % Plot all peak heights over time in bottom right graph
                if sum(datalast)==0
                    subplot(2,2,4); plot(pass_struct.elapsed_time + pk_t, pkht_poly, '.')                       % add each new analyzed point to this existing plot
                    hold on
                else
                    subplot(2,2,4); plot(datalast(1,2:end), datalast(2,2:end), '.')                     % plot all previous data points
                    hold on
                    subplot(2,2,4); plot(pass_struct.elapsed_time + pk_t, pkht_poly, '.')                       % add each new analyzed point to this existing plot
                end
        
                subplot(2,2,4); plot(pk_t((end - length(peaks) + 1):end) + pass_struct.elapsed_time, pkht_poly((end - length(peaks) + 1):end), 'or') % highlight last point
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
        disp('no good peaks in this segment or number of peaks is not 3');
     
    end
    
    else
       disp('JK: skipping this segment. Too short for baseline selection');
    end
    
end

if (~isempty(pk_t))
    pk_data(1,:) = pk_t + pass_struct.elapsed_time;
    pk_data(2,:) = pkht_poly;
    pk_data(3,:) = peakwidth;
    pk_data(4,:) = pk_leftbase;
    pk_data(5,:) = pk_rightbase;
    pk_data(6,:) = baselinedist;
    pk_data(7,:) = baselineslope;
    pk_data(8,:) = apkht_poly;    %node deviation
    pk_data(9,:) = ahtdiff_poly;   %FWHM
    pk_data(10,:) = sectnum;
    pk_data(11,:) = pknum;
    pk_data(12,:) = pkorder;
    pk_data(13,:) = 0;
else
    disp('No GOOD peak found in this section');
    pk_data=zeros(13,1);
end

pass_struct.elapsed_time = pass_struct.elapsed_time + t(end);    % update initial time for the next iteration

disp(' ')

return

end

