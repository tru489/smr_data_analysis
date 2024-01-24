function [pk_data, pass_struct] = S1_PeakAnalysis_time(x, t, valve_state, ...
    datalast, sectionnumber, run_params, pass_struct)
% Analyzes an individual data segment of frequency-time data to find peaks
%
% Arguments:
%   x (array(double)): frequency data array
%   t (array(double)): time data array
%   valve_state (array(double)): valve state data array
%   datalast (array(double)): array of data from previous segment 
%       iterations
%   sectionnumber (array(double)): current segment number
%   analysisparam (struct): preferences for displaying data analysis
% Returns:
%   pk_data (array(double)): peak data 

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

if run_params.backend.alternative_smoothing
    ydata = sgolayfilt(sgolayfilt(x, 3, 7), 3, 7);
else
    sgolay_length = 2 * round(sgolay_length_idx * ...
        (estimated_datapoints / 400)) + 1;
    
    % Filter frequency data with savitsky-golay filter
    if sgolay_length > 3
        ydata = sgolayfilt(x, 3, sgolay_length); 
    else
        ydata = sgolayfilt(x, 3, 5);
    end
end

xdata = (1:length(ydata))';

% Modify baseline selection parameters
run_params = S1_bl_select_compensate(run_params, estimated_noise, ...
    estimated_datapoints);

% Derivative threshold to find flat part of baseline
diff_threshold = run_params.bl_select.diff_threshold;
% Window of median filter, which removes the flat part in the anti-node
med_filt_wd = run_params.bl_select.med_filt_wd;
% Derivative threshold used to remove the flat part in the anti-node
bs_dev_thres = run_params.bl_select.bs_dev_thres;
% Baseline offset threshold to select for peaks
offset_input = run_params.bl_select.offset_input;

% Remove fast varying points (i.e. pts with high derivative) from 
% baseline
idx = find(abs(diff(ydata)) < diff_threshold);

% Filter out the flat points found over the anti-node
mf_ydata_thres = medfilt1(ydata(idx), med_filt_wd);

idx_f = abs(ydata(idx) - mf_ydata_thres) < bs_dev_thres;
idx = idx(idx_f);

if run_params.backend.compensate_baseline_fluct
    idx_in = ydata(idx) < 3000;
    idx = idx(idx_in);
end

if isempty(idx)
    disp('Filtered baseline is empty; moving on to next segment');
    pk_data = zeros(13,1);
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
    peak_idx = S1_get_peak_idx(run_params, xdata, ydata, idx);
else
    disp('No peak found; moving to next segment');
    pk_data = zeros(13,1); 
    pass_struct.elapsed_time = pass_struct.elapsed_time + t(end);  
    return;
end

if length(peak_idx) > 1
    segmentbound = S1_get_seg_bound(peak_idx, xdata);
    
    set(gca,'XLim',[0 length(xdata)]);
    set(gca,'YLim',[min(ydata) - 10 max(ydata) + 10]);
else
    disp('size of peak_idx is smaller than 2')
    pk_data = zeros(13,1); 
    pass_struct.elapsed_time = pass_struct.elapsed_time + t(end);  
    return;
end

disp('Beginning individual peak analysis.')

% Lower threshold to half-length (in datapoints) of data segment 
% surrounding a single peak
segment_threshold = run_params.bl_select.segment_threshold;
segment_threshold = segment_threshold * estimated_datapoints / 400;

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

% Iterate through each peak segment
for i = 1:length(peak_idx)
    to_last_bound = abs(peak_idx(i) - segmentbound(i));
    to_next_bound = abs(peak_idx(i) - segmentbound(i+1));
    if min(to_last_bound, to_next_bound) > segment_threshold
        local_xdata = xdata(segmentbound(i):segmentbound(i+1)) - ...
            xdata(segmentbound(i)) + 1;
        local_ydata = ydata(segmentbound(i):segmentbound(i+1));
        
        baseparams = run_params.bl_select;
        
        % Identify primary and secondary peak apex indices within 
        % segment
        disp('Locating segment peaks...')
        peaks = S2_PeaksetFinder(run_params, local_xdata, local_ydata, ...
            offset_input, baseparams);
        
        if numel(peaks) ~= 0 % numel(peaks) == 3
            % Distances (idx) between first and last of three 2nd mode
            % peaks
            peakdist_temp = peaks(end) - peaks(1);

            disp('Identifying baseline...')
            
            [left_base, right_base, edgeidx] = ...
                S2_BaselineFinder(run_params, local_xdata, ...
                local_ydata, peaks, baseparams, peakdist_temp);

            % If there are not enough datapoints detected, skip to the 
            % next peak
            if numel(left_base) == 0 || numel(right_base) == 0 || ...
                    numel(edgeidx) == 0 || numel(peaks) == 0
                continue;
            else
                % Identify the peak width from the left and right 
                % boundary markers of the peak
                local_peakwidth = diff(edgeidx);  
                
                % Slice out freq and index data local to this peakset
                pk_xdata = ...
                    local_xdata(left_base(1):right_base(end)) - ...
                    local_xdata(left_base(1)) + 1;
                pk_ydata = local_ydata(left_base(1):right_base(end));
                
                % Normalize indices of peak data and baseline data to 
                % local indexing specific to this peakset
                local_peaks = peaks - left_base(1) + 1;
                local_baseline = [left_base - left_base(1) + 1, ...
                    right_base - left_base(1) + 1];
            
                % Perform polynomial fits to refine peak location and 
                % to measure peak height
                disp('Performing polynomial fit on segment peaks...')
                peak_fit_metrics = S2_PeakFitter(run_params, ...
                    pk_xdata, pk_ydata, local_baseline, local_peaks, ...
                    local_peakwidth);

                local_pkidx_poly = peak_fit_metrics.pkidx_poly;
                local_pkht_poly = peak_fit_metrics.pkht_poly;
                local_apkidx_poly = peak_fit_metrics.apkidx_poly;
                local_apkht_poly = peak_fit_metrics.apkht_poly;
                local_baselineslope = peak_fit_metrics.baselineslope;
                local_htdiff_poly = peak_fit_metrics.htdiff_poly;
                local_ahtdiff_poly = peak_fit_metrics.ahtdiff_poly;
                fit_baseline = peak_fit_metrics.fit_baseline;
            
                %% Input Experiment parameters
                Experiment.R = 32768; % 32768
                Experiment.decimation = 1;
                Experiment.Fs = 100e6 / Experiment.R / ...
                    Experiment.decimation;
    
                temppeak = local_ydata(left_base(1): right_base(end));
                
                temptime = ...
                    t(segmentbound(i) + left_base(1)) + 1 / ...
                    Experiment.Fs: ...
                    1 / Experiment.Fs: ...
                    t(segmentbound(i) + left_base(1)) + 1 / ...
                    Experiment.Fs * length(temppeak);
                
                % 1000s, 0s, and NaNs (respectively) below separate
                % data for different peaks in the arrays
                pass_struct.samplepeak = ...
                    [pass_struct.samplepeak temppeak' ...
                    nan i sectionnumber]; 
                pass_struct.sampletime = ...
                    [pass_struct.sampletime temptime ...
                    0 i sectionnumber];
                pass_struct.sample_baseline_fits = ...
                    [pass_struct.sample_baseline_fits fit_baseline ...
                    nan i sectionnumber];
    
                fprintf('------- Data segment %1.0f ------ \n', ...
                    sectionnumber);
                fprintf('Peak segment %1.0f\n', i);
                fprintf('Baseline slope: %1.5f \n', local_baselineslope);
                fprintf('2nd mode %%diff: %1.5f \n', local_htdiff_poly);
                fprintf('-------------------------- \n')
                disp(' ')
    
                %% Peak metrics
                % Index of each peak and antipeak within each peakset, 
                % adjusted for indices global to segment
                pkidx_poly = [pkidx_poly ...
                    local_pkidx_poly + segmentbound(i) + left_base(1)];
                apkidx_poly = [apkidx_poly ...
                    local_apkidx_poly + segmentbound(i) + left_base(1)];

                % Time of each peak and antipeak within each peakset, 
                % adjusted for indices global to segment
                pk_t = [pk_t ...
                    t(local_pkidx_poly + segmentbound(i) + left_base(1))'];
                apk_t = [apk_t ...
                    t(local_apkidx_poly + segmentbound(i) + ...
                    left_base(1))' 0];

                % Peak height (from polynomial fit) for each peak and 
                % antipeak within peakset
                pkht_poly = [pkht_poly ...
                    local_pkht_poly];
                apkht_poly = [apkht_poly ...
                    local_apkht_poly 0];

                % Peak width of each peakset (not each individual peak).
                % Value is same across 3 individual peaks
                peakwidth = [peakwidth ...
                    local_peakwidth * ones(1, length(peaks))];

                % Mean baseline to the left and right of the peakset 
                % (same across 3 peaks in each peakset)
                pk_leftbase = [pk_leftbase ...
                    mean(local_ydata(left_base)) * ones(1,length(peaks))];
                pk_rightbase = [pk_rightbase ...
                    mean(local_ydata(right_base)) * ones(1,length(peaks))];

                % Distance between beginning of left baseline to end of
                % right baseline for a peakset (same across 3 peaks in 
                % each peakset)
                baselinedist = [baselinedist ...
                    (right_base(1) - left_base(end) + 1) * ...
                    ones(1, length(peaks))];

                % Linear slope of baseline (same across 3 peaks in 
                % each peakset)
                baselineslope = [baselineslope ...
                    local_baselineslope * ones(1, length(peaks))];

                % Mean node deviation in peakset (same across 3 peaks in 
                % each peakset)
                htdiff_poly = [htdiff_poly ...
                    local_htdiff_poly * ones(1,length(peaks))];

                % "FWHM" of peakset (i.e. distance in datapoints between 
                % half-max of leading edge of first peak to half-max of 
                % trailing edge of last peak in peakset; same across 3 
                % peaks in each peakset)
                ahtdiff_poly = [ahtdiff_poly ...
                    local_ahtdiff_poly * ones(1, length(peaks))];

                % Index of peak within 3 peaks for each peakset
                pknum = [pknum ...
                    1:length(peaks)];

                % Index of peak within all peaks detected for this 
                % segment
                pkorder = [pkorder ...
                    i * ones(1, length(peaks))];

                % Data segment number of peaks (same for all peaks in
                % peakset)
                sectnum = [sectnum ...
                    sectionnumber * ones(1, length(peaks))];

                % Main code block controlling how real-time peak analysis
                % is displayed
                if dispprogress
                    hold off; drawnow;
                    figure(1);
                    
                    % Plot entire frequency data
                    subplot(2,2,[1 2]); plot(xdata, ydata, '-'); 
                    hold on;

                    % Plot detected peak locations in red
                    subplot(2,2,[1 2]); plot(peak_idx, ydata(peak_idx), ...
                        '.r');
                    
                    % Trouble shooting on 12/03/2020, sometime right_base 
                    % of the last peak exceeds the length of the segment
                    if (right_base + segmentbound(i)) <= 2e6
                         subplot(2,2,[1 2]); 
                         plot(left_base + segmentbound(i), ...
                             ydata(left_base + segmentbound(i)), '.g', ...
                             right_base + segmentbound(i), ...
                             ydata(right_base + segmentbound(i)), '.g')
                    else
                        subplot(2,2,[1 2]); 
                        plot(left_base + segmentbound(i), ...
                            ydata(left_base + segmentbound(i)), '.g', ...
                            right_base + segmentbound(i), ...
                            ydata(2000000), '.g')
                    end
                    
                    % Mark last analyzed peakset
                    subplot(2,2,[1 2]); 
                    plot(xdata(peak_idx(i)), ydata(peak_idx(i)), '.c');
                    
                    % Mark all boundaries between peaksets
                    subplot(2,2,[1 2]); 
                    line([segmentbound' segmentbound'], ...
                        [min(ydata) - 100 max(ydata) + 100], ...
                        'Color', 'k', 'LineStyle', ':')
                    
                    % Mark initial peak detection threshold in black
                    subplot(2,2,[1 2]); 
                    plot(xdata, ydata_thres, 'k')
                    
                    set(gca,'XLim',[0 length(xdata)]);
                    set(gca,'YLim',[min(ydata) - 10 max(ydata) + 10]); 
                    hold off;
                    
                    % Plot all peak heights over time in bottom right graph
                    if sum(datalast) == 0
                        % Add each new analyzed point to this existing plot
                        subplot(2,2,4); 
                        plot(pass_struct.elapsed_time + pk_t, ...
                            pkht_poly, '.')
                        hold on
                    else
                        % Plot all previous data points
                        subplot(2,2,4); 
                        plot(datalast(1,2:end), datalast(2,2:end), '.')
                        hold on
                        
                        % Add each new analyzed point to this existing plot
                        subplot(2,2,4); 
                        plot(pass_struct.elapsed_time + pk_t, ...
                            pkht_poly, '.')
                    end
                    
                    % Highlight last point
                    subplot(2,2,4); 
                    plot(pk_t((end - length(peaks) + 1):end) + ...
                        pass_struct.elapsed_time, ...
                        pkht_poly((end - length(peaks) + 1):end), 'or') 
                    hold off
                end
                
                if(analysismode ~= 1)
                    input('Hit ENTER to continue with analysis, CTRL+C to stop analysis...');
                end
            end
        else
            disp('Number of peaks in this segment is not 3');
        end
    else
       disp('Segment too short for baseline selection');
    end
end

% Summary of peakwise (NOT peakset-wise) data to be analyzed downstream to
% create summary data file (by row number). Peakset-specific metrics are 
% the same for all component peaks:
% 
%   (1): peak time
%   (2): peak height (from polynomial fit)
%   (3): peak width of peakset
%   (4): average left baseline of peakset
%   (5): average right baseline of peakset
%   (6): distance between beginning of left detected baseline to end of
%        right detected baseline for peakset
%   (7): baseline slope over peakset
%   (8): average node deviation over peakset
%   (9): "FWHM" of peakset
%   (10): Data segment number of peaks
%   (11): Index of peak within 3 peaks for each peakset
%   (12): Index of peak within all peaks detected for this segment
%   (13): valve state

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
    pk_data(13,:) = valve_state(pkidx_poly);
else
    disp('No acceptable peak found in this section');
    pk_data = zeros(13,1);
end

% Update initial time for the next iteration
pass_struct.elapsed_time = pass_struct.elapsed_time + t(end);

return

end

