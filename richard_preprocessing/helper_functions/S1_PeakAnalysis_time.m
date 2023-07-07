function [data, analysis_params, elapsed_time] = ...
    S1_PeakAnalysis_time(x, t, datalast, sectionnumber, analysisparams, ...
    estimated_datapoints, elapsed_time)
    %% Setup
    global left_base
    global right_base
    global segmentbound
    global samplepeak
    global sampletime 
    global sidelength
    
    analysis_params.analysismode = analysisparams.analysismode;
    analysis_params.dispprogress = analysisparams.dispprogress;
    vv = zeros(length(x),1);
    
    % Clear all S1 variables
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
    
    % If data is very short, move on and just record a row of 0 data for
    % this function call
    if length(x) < 10
        %disp('No GOOD peak found in this section: data Length< 10');
        data=zeros(13,1); 
        %disp(' '); 
        elapsed_time = elapsed_time + t(end);  
        return;
    end
    
    %% Estimated data points per frequency peak & noise in system
    % Added 03/22/2019
    % Estimated_datapoints = 200; %for full transit; deafult
    
    % Remove outliers from data and estimate noise
    noise_data_keep = rmoutliers(diff(x), 'percentiles', [1,99]);
    analysis_params.estimated_noise = std(noise_data_keep) * 3;
    
    % Set savitsky-golay filter length. Based on the estimated datapoint
    % number required to detect peaks.
    % This will make default length of 5 for 50 idx transits.
    sgolay_length_idx = 1;
    sgolay_length = 2 * round(sgolay_length_idx * ...
        (estimated_datapoints / 50)) + 1;
    
    %fprintf(['sgolay length for datapoints per transit of %4.0f', ...
    % ' will be %2.0f', estimated_datapoints, sgolay_length); disp(' ');
    
    % Pull out a sample of the raw SMR data and smooth it with a
    % savitsky-golay filter, including plotting using the parameters
    % defined above.
    if elapsed_time == 0
        xtest = x(1:min([1e5, length(x)])) - x(1);
        figure(2); plot(xtest); hold on;
        plot(sgolayfilt(xtest, 3, 5));
        if sgolay_length > 3
            plot(sgolayfilt(xtest, 3, sgolay_length));
            legend('raw', 'sgolay 3-5', strcat('sgolay 3-', num2str(sgolay_length)));
        else
            legend('raw', 'sgolay 3-5');
        end
    % noise_estimate_frame = input('What is the x-axis frame for estimating noise? [_,_]');
    % measured_noise = std(xtest(noise_estimate_frame));
    % 
    % fprintf('estimated noise level is %2.3f', measured_noise); disp(' ');
    % input('check if the filtering is okay and your noise level');
    % analysis_params.estimated_noise = measured_noise;
    end    
    
    % Smooth entire x data using savitsky-golay filter
    if sgolay_length > 3
        ydata = sgolayfilt(x, 3, sgolay_length); 
    else
        ydata = sgolayfilt(x, 3, 5);
    end
    xdata = (1:length(ydata))';
    %disp('Finding peak indices...')
    
    %% Baseline selection parameters
    % ——————————————————Optimize using below parameters——————————————————
    % Find extremely flat part of curve (sys1)
    diff_threshold_param = 0.005;
    % Window of median filter, which removes the flat part in the anti-node
    med_filt_wd_param = 200;
    % Baseline dev_threshold; threshold used to remove the flat part in 
    % the anti-node
    bs_dev_thres_param = 0.5;
    % Distance over which is a unique 2nd mode peaks, default 200
    unqPeakDist_param = 150;
    % Baseline offset to select for peaks
    offset_input_param = 5;
    
    % ——————————————————USER ADJUSTABLE——————————————————
    % Below is assuming 400 data points per transit
    
    % Choose the first point left/right of the secondary peaks 40% 
    % percent of the average baseline freqvalue
    analysis_params.edgethres = 0.12;
    % Allow 102% of the minimum standard deviation
    analysis_params.stdevmultiplier = 3;
    % Allow 90% of the deviation from mean frequency closest to 2ndary peaks
    analysis_params.diffmultiplier = 0.9;
    % Number of points searching for baseline collection
    analysis_params.winsize = 150;

    %% Compensate for number of data points & noise level
    % Added 03/22/2019; provides corrections for noise in data and baseline
    % for peak detection

    % Derivative threshold below which to remove points not in flat,
    % baseline parts of the signal (in order to select for the baseline)
    analysis_params.diff_threshold = ...
        diff_threshold_param * ...
        ((analysis_params.estimated_noise / 0.1) ^ (1/2)) / ...
        (estimated_datapoints / 400);

    % Size of median filter used to smooth baseline signal
    analysis_params.med_filt_wd = ...
        round(med_filt_wd_param * estimated_datapoints/400);
    
    % Distance within the baseline within which to search for points to
    % establish baseline signal for interpolation
    analysis_params.bs_dev_thres = ...
        bs_dev_thres_param * ...
        ((analysis_params.estimated_noise / 0.1) ^ (1/2));
    
    % Sets an offset from the baseline value. Signal values that are larger
    % than this offset value will be marked as peaks for future analysis
    analysis_params.offset_input = offset_input_param;

    % Minimum allowed distance between unique peaks
    analysis_params.unqPeakDist = ...
        round(unqPeakDist_param * estimated_datapoints / 400);
    
    %% Filter to extract baseline for peak detection
    % Remove fast varying points to get baseline (i.e. points with a
    % derivative smaller than a certain threshold value)
    idx = find(abs(diff(ydata)) < analysis_params.diff_threshold);                                                
    
    % Using the baseline indices (i.e. portions there the derivative of 
    % the signal is flat) from before, uses a median filter to extract a 
    % smoothed baseline. In particular, this just selects for sections of
    % contiguous baseline, rather than flat parts above the antinodes
    mf_ydata_thres = medfilt1(ydata(idx), analysis_params.med_filt_wd);
    
    % Find points within a small distance of the established baseline
    idx_f = abs(ydata(idx) - mf_ydata_thres) < ...
        analysis_params.bs_dev_thres;
    idx = idx(idx_f);
    
    % Interpolate baseline y values across all x values. Note that this is
    % interpolation to establish a baseline, accounting for the fact that
    % the baseline could have a nonzero slope over time
    ydata_thres = interp1(xdata(idx), ydata(idx), xdata);

    % Apply set offset to interpolated baseline. This offset will serve as
    % a threshold for peak detection
    ydata_thres = ydata_thres-analysis_params.offset_input;
    
    % Find which y data points are less than the threshold. These points
    % that deviate significantly from the baseline are the main peaks
    idx = find(ydata < ydata_thres);
    
    %% Peak detection
    repeatflag = 1;
    while(repeatflag == 1)
        if ~isempty(idx)
            % Find all breaks in y_diff indices; that is, contiguous 
            % regions where the signal deviates significantly from the 
            % baseline. Each segment is a peak of interest, with end on 
            % idx_end and start on (idx_end + 1)
            idx_ends = find(abs(diff(idx)) > 1);

            % Cap the beginning and end of idx with markers
            idx_ends = [0 idx_ends' length(idx)];
    
            % Preallocate peak index array (indices in ydata where the
            % peaks occur)
            peak_idx = zeros(1,length(idx_ends) - 1);
            for i = 1:length(idx_ends) - 1
                % Extract y data corresponding to current peak
                ydata_segment = ...
                    ydata(idx((idx_ends(i) + 1):idx_ends(i+1)));
                
                % Find index of the maximum deviation, i.e. the apex of the
                % peak identified within this deviating data segment
                segment_idx_max = ...
                    min(find(ydata_segment == min(ydata_segment)));
                
                % Convert the apex index (index local to data segment in 
                % which we are analyzing) to the global index within y_diff
                global_idx_max = idx(idx_ends(i) + 1) + ...
                    segment_idx_max - 1;
                peak_idx(i) = global_idx_max(1);  
            end
            
            % Filter for unique peaks, based on unqPeakDist parameter.
            % Ensures that peaks that are overlapping aren't saved.
            % length(xdata) is added to the end of the array to make the
            % same size as peak_idx
            unique_peaks = diff([peak_idx, length(xdata)]) > analysis_params.unqPeakDist;
            peak_idx = peak_idx(unique_peaks);
                                
            % Now we have the global indices of the main peaks in this 
            % segment of the entire frequency data... iterate until we 
            % get all of the peaks in the data 
            repeatflag = 0;
            %disp('...Done.')
        else
            % No peak is found in this section. No need to continue
            % iterating since there is no peak data.
            repeatflag = 0;
            data = zeros(13,1); 
            elapsed_time = elapsed_time + t(end); 
            return;
        end
    end
    
    %% Setup for data segmentation
    
    % Create array of intermediate indices between each peak
    segmentbound = zeros(1,length(peak_idx));
    segmentbound(1) = peak_idx(1) + round((peak_idx(2) - peak_idx(1)) / 2);
    for i = 2:length(peak_idx)-1
        segmentbound(i) = peak_idx(i) + ...
            round((peak_idx(i+1) - peak_idx(i)) / 2);
    end
    segmentbound(end) = xdata(end);
    segmentbound = [1 segmentbound];
    
    segment_med_wd = round(median(diff(segmentbound))/10);
    
    set(gca,'XLim',[0 length(xdata)]);
    set(gca,'YLim',[min(ydata) - 10 max(ydata) + 10]);
    %disp('Done.')
    
    %% Segmentizing the dataset
    i = 0;
    
    segment_threshold = 200; % Number of data points from peaks 
    segment_threshold = segment_threshold * estimated_datapoints / 400;
    sidelength = 3000; % Number of more indices on each side of baseline 
     
    for i = 1:length(peak_idx)
        % If distance of peak to previous or next boundary between two
        % adjacent peaks (halfway between the peaks; from segmentbound) is
        % larger than the set value, then we have enough datapoints for
        % that peak to proceed
        dist_to_prev_boundary = abs(peak_idx(i) - segmentbound(i));
        dist_to_next_boundary = abs(peak_idx(i) - segmentbound(i+1));
        if min(dist_to_prev_boundary, dist_to_next_boundary) ...
                > segment_threshold
            % Slice x and y data to get segment containing peak. x data is
            % local values relative to the beginning of this segment
            local_xdata = xdata(segmentbound(i):segmentbound(i + 1)) - ...
                xdata(segmentbound(i)) + 1;
            local_ydata = ydata(segmentbound(i):segmentbound(i + 1));

            % Parameters to use in peak finder
            baseparams = [analysis_params.stdevmultiplier,...
                analysis_params.diffmultiplier, ...
                analysis_params.edgethres,...
                analysis_params.winsize, ...
                analysis_params.diff_threshold,...
                analysis_params.med_filt_wd, ...
                analysis_params.bs_dev_thres];
            
            % Find peaks in each segment of x and y data
            peaks = S2_PeaksetFinder(local_xdata, local_ydata, ...
                analysis_params.offset_input, baseparams, ...
                analysis_params.analysismode);                

            % If detected peak set contains 3 peaks (as is expected with
            % second mode measurements), then ___________________
            if numel(peaks) == 3
                % Number of indices between first and last peak
                peakdist_temp = peaks(end)-peaks(1);
                
                % Identify sections of baseline to the left and right of
                % the peakset and their indices
                [left_base, right_base, edgeidx] = S2_BaselineFinder(local_xdata, local_ydata, peaks, baseparams, peakdist_temp, analysis_params.analysismode);  
                
                % Skip this peak if the baseline around the peak cannot be
                % identified
                if(numel(left_base) == 0 || numel(right_base) == 0 || numel(edgeidx) == 0 || numel(peaks) == 0)
                    i=i+1;
                else
                    % Number of datapoints in the peak
                    local_peakwidth = diff(edgeidx);  
                    
                    % Slice out x and y data around peak, normalizing the
                    % indices of x to start at 1
                    pk_xdata = local_xdata(left_base(1):right_base(end)) - local_xdata(left_base(1)) + 1;
                    pk_ydata = local_ydata(left_base(1):right_base(end));
                    
                    % Subtract baseline from the left and right baseline
                    % segments and the peaks for polynomial fitting
                    local_peaks = peaks - left_base(1) + 1;
                    local_baseline = [left_base - left_base(1) + 1, right_base - left_base(1) + 1];
                    % disp('...Done.')
                    
                    % input('continue?');
                    % Perform polynomial fits to refine peak location and to measure peak height
                    %disp(' ')
                    %disp('Performing polynomial fit on segment peaks...')
                    [local_pkidx_poly, local_pkht_poly, local_apkidx_poly, local_apkht_poly, local_baselineslope, local_htdiff_poly, local_ahtdiff_poly] ...
                        = S2_PeakFitter(pk_xdata, pk_ydata, local_baseline, local_peaks, local_peakwidth, analysis_params.dispprogress); 
                    %disp('...Done.')
                    %disp(' ')
                    
                    % ---------------- added by JK 09/18/14 ------
                    %here we are trying to save the mode shape for each peak detected
             
                    %% Input Experiment parameters
                    
                    % -----------START HERE--------------------
                    Experiment.R = 32768;
                    Experiment.decimation = 1;
                    Experiment.Fs = 100e6 / Experiment.R / Experiment.decimation;
        
                    temppeak = local_ydata(left_base(1): right_base(end));
                    
                    temptime = [t(segmentbound(i) + left_base(1))+1/Experiment.Fs:1/Experiment.Fs:t(segmentbound(i) + left_base(1))+1/Experiment.Fs*length(temppeak)];
                    samplepeak = [samplepeak temppeak' 1e3 i sectionnumber]; 
                    sampletime = [sampletime temptime 0 i sectionnumber];
                    % 0 is to distinguish different peaks
        
                    format shortg
                    
                    % fprintf('------- Section %1.0f ------ \n', sectionnumber);
                    % fprintf('-- Data for Segment %1.0f -- \n', i);
                    % fprintf('Baseline slope: %1.5f \n', local_baselineslope);
                    % fprintf('2nd mode %%diff: %1.5f \n', local_htdiff_poly);
                    % fprintf('-------------------------- \n')
                    % disp(' ')
        
                    pkidx_poly = [pkidx_poly local_pkidx_poly + segmentbound(i) + left_base(1)];                % Peak apex index from polynomial fit
                    apkidx_poly = [apkidx_poly local_apkidx_poly + segmentbound(i) + left_base(1)];             % Peak anti-apex index from polynomial fit
                    pk_t = [pk_t t(local_pkidx_poly + segmentbound(i) + left_base(1))'];                        % Time of peak apex index from polynomial fit
                    apk_t = [apk_t t(local_apkidx_poly + segmentbound(i) + left_base(1))' 0];                   % Time of peak anti-apex index from polynomial fit
                    pkht_poly = [pkht_poly local_pkht_poly];                                                    % Peak apex height from polynomial fit
                    apkht_poly = [apkht_poly local_apkht_poly 0];                                               % Peak anti-apex height from polynomial fit
                    peakwidth = [peakwidth local_peakwidth*ones(1,length(peaks))];                              % Peak widths
                    pk_leftbase = [pk_leftbase mean(local_ydata(left_base))*ones(1,length(peaks))];             % Mean of baseline to the left of peak
                    pk_rightbase = [pk_rightbase mean(local_ydata(right_base))*ones(1,length(peaks))];          % Mean of baseline to the right of peak
                    baselinedist = [baselinedist (right_base(end) - left_base(1) + 1)*ones(1,length(peaks))];   % Distance between baseline fragments to the left and right of peak
                    baselineslope = [baselineslope local_baselineslope*ones(1,length(peaks))];                  % Baseline slope
                    htdiff_poly = [htdiff_poly local_htdiff_poly*ones(1,length(peaks))];                        % Mean height distance between anti-apices (i.e. antinodes)
                    ahtdiff_poly = [ahtdiff_poly local_ahtdiff_poly*ones(1,length(peaks))];                     % Peak FWHM
                    pknum = [pknum 1:length(peaks)];                                                            % Integer number of peak
                    pkorder = [pkorder i*ones(1,length(peaks))];                                                % Integer order of peak
                    sectnum = [sectnum sectionnumber*ones(1,length(peaks))];                                    % Section number (within full frequency data) of peak
        
                    % Plot xdata, ydata, peak apices, and left and right
                    % boundaries of peak
                    if analysis_params.dispprogress == 1
                        hold off; drawnow;
                        figure(1);
                        
                        subplot(2,2,[1 2]); plot(xdata, ydata, '-'); 
                        hold on;
                        subplot(2,2,[1 2]); plot(peak_idx, ydata(peak_idx), '.r');
                        subplot(2,2,[1 2]); plot(left_base + segmentbound(i), ydata(left_base + segmentbound(i)), '.g', right_base + segmentbound(i), ydata(right_base + segmentbound(i)), '.g')
                        
                        % if (left_base(1)-segment_med_wd<1)
                        %     subplot(2,2,[1 2]); plot(left_base-left_base(1)+1, ydata(left_base-left_base(1)+1), '.g', ...
                        %     right_base + peak_idx(i)-segment_med_wd, ydata(right_base + peak_idx(i)-segment_med_wd), '.g')
                        % else
                        %     subplot(2,2,[1 2]); plot(left_base + peak_idx(i)-segment_med_wd, ydata(left_base + peak_idx(i)-segment_med_wd), '.g', ...
                        %     right_base + peak_idx(i)-segment_med_wd, ydata(right_base + peak_idx(i)-segment_med_wd), '.g')
                        % end
                        % subplot(2,2,[1 2]); plot(left_base + peak_idx(i)-segment_med_wd, ydata(left_base + peak_idx(i)-segment_med_wd), '.g', ...
                        % right_base + peak_idx(i)-segment_med_wd, ydata(right_base + peak_idx(i)-segment_med_wd), '.g')
                        
                        % Mark last analyzed peakset
                        subplot(2,2,[1 2]); plot(xdata(peak_idx(i)), ydata(peak_idx(i)), '.c');
                        % Plot line across baseline
                        subplot(2,2,[1 2]); line([segmentbound' segmentbound'], [min(ydata) - 100 max(ydata) + 100], 'Color', 'k', 'LineStyle', ':')
                        % Plot y threshold for peak detection
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
                
                    if(analysis_params.analysismode ~= 1)
                        input('Hit ENTER to continue with analysis, CTRL+C to stop analysis......  ');
                    end
                i=i+1;
                end
            else
                %disp('no good peaks in this segment or number of peaks is not 3');
            end
        else
           %disp('JK: skipping this segment. Too short for baseline selection');
        end
    end
    %%% assign peak number in data matrix (1,2,3)
    
    % Data to save
    if (~isempty(pk_t))
        data(1,:) = pk_t;             % LabVIEW record computer real-time
        data(2,:) = pkht_poly;        % Peak height from polynomial fit
        data(3,:) = peakwidth;        % Peak width
        data(4,:) = pk_leftbase;      % Peak left baseline
        data(5,:) = pk_rightbase;     % Peak right baseline
        data(6,:) = baselinedist;     % Baseline left to right distance
        data(7,:) = baselineslope;    % 1st order baseline fit slope before flattening
        data(8,:) = apkht_poly;       % Node deviation
        data(9,:) = ahtdiff_poly;     % FWHM
        data(10,:) = sectnum;         % Section number in analysis
        data(11,:) = pknum;           % Peak number
        data(12,:) = pkorder;         % Peak order
        data(13,:) = vv(pkidx_poly);
        %save('data.csv','data','-ascii','-double','-append');                                   % save the current processing
    else
        %disp('No GOOD peak found in this section');
        data=zeros(13,1);
    end
    
    elapsed_time = elapsed_time + t(end);                                            % update initial time for the next iteration
    
    %disp(' ')
    
    return

end