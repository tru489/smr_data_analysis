function [peaks] = S2_PeaksetFinder(xdata, ydata, offset_input, baseparams, analysismode)

%%% Original by Sungmin Son
%%% Extensively modified by Nikita Khlystov
%%% Latest edit 12/16

%% Find primary and secondary peaks

% Start by doing the same baseline analysis done in S1_PeakAnalysis_time;
% filter baseline, 
diff_threshold = baseparams(5);
med_filt_wd = baseparams(6);
bs_dev_thres = baseparams(7);

% Remove fast varying points to get baseline (i.e. points with a derivative 
% smaller than a certain threshold value)
idx = find(abs(diff(ydata)) < diff_threshold);                                                  

% Using the baseline indices (i.e. portions there the derivative of 
% the signal is flat) from before, uses a median filter to extract a 
% smoothed baseline. In particular, this just selects for sections of
% contiguous baseline, rather than flat parts above the antinodes
mf_ydata_thres = medfilt1(ydata(idx), med_filt_wd);

% Find points within a small distance of the established baseline
idx_f = abs(ydata(idx) - mf_ydata_thres) < bs_dev_thres;
idx = idx(idx_f);

% ydata_thres(idx) = smooth(ydata(idx), 2);
% filter extreme outliers.
% in density measurement flat part forms in outliers

idx=[idx; length(ydata)];

% If no flat baseline section is found, then we can't reliably detect
% peaks. Return without any peak data
if length(idx) < 2
    peaks = [];
    return
end

% Interpolate baseline y values across all x values
ydata_thres = interp1(xdata(idx), ydata(idx), xdata);

% Locally smooth ydata
ydata = smooth(ydata, 3);

% Like when finding peaks, provide an offset (this time defined from the
% ydata itself) that functions as a threshold below which peaks will be
% detected
offset_input = (max(ydata) - min(ydata)) * 0.5;
minpkht_thres = ydata_thres-offset_input;

% Plot the data for this peak segment as well as the threshold if in
% analysis mode
if analysismode == 0
    hold off;
    figure(1);
    subplot(2,2,3); plot(xdata, ydata, '-');
    hold on;
    subplot(2,2,3); plot(xdata(idx), ydata(idx), '.g'); 
    subplot(2,2,3); plot(xdata, minpkht_thres, '-k');
    input('go');
end



% START HERE ON MONDAY!!!!!!!!!!!!!!!!!!!!!!!



% 
repeatflag = 1;
while(repeatflag == 1)
    pkidx = find(ydata < minpkht_thres);                                                  % find all freq values that pass this threshold - these are the main peaks
    if ~isempty(pkidx)
        idx_ends = find(abs(diff(pkidx)) > 1);                                                  % find all breaks in y_diff indices; each segment is a peak of interest, with end on idx_end and start on (idx_end + 1)
        idx_ends = [0 idx_ends' length(pkidx)];                                                   % cap the beginning and end of idx with markers
        peaks = zeros(1,length(idx_ends) - 1);                                            % set empty matrix for loop efficiency
        for i = 1:length(idx_ends) - 1
            data_segment = ydata(pkidx(idx_ends(i)+1:idx_ends(i + 1)));                        % focus on the piece of y_diff between two consecutive idx_end markers
            segment_idx_max = min(find(data_segment == min(data_segment)));                      % find index of the maximum deviation, i.e. the apex within the piece
            global_idx_max = pkidx(idx_ends(i) + 1) + segment_idx_max - 1;
            peaks(i) = global_idx_max;                                                       % convert the apex index to the global index within y_diff      
        end
        
        if analysismode == 0
        figure(1);    
        hold off                                                                                    %%% the entire frequency data
        subplot(2,2,3); plot(xdata, ydata, '-');
        hold on
        subplot(2,2,3); plot(xdata(idx), ydata(idx), '.g');
        subplot(2,2,3); plot(xdata, minpkht_thres, '-k');
        subplot(2,2,3); plot(peaks, ydata(peaks), '.r');                                      % peak location is only estimated - due to smoothing, actual apex is a bit different; refinement is below
        set(gca,'XLim',[0 length(xdata)]);
        set(gca,'YLim',[min(ydata) - 10 max(ydata) + 10]);
        
        
            %input('go?');
        end
        
        goflag = 0;
        if mod(length(peaks),3) ~= 0 
            %disp('Warning: the number of peaks found is not a multiple of three. Check plot.')
%             peaks=[];
            checkthres = 0;%input('Enter 1 if you want to adjust threshold, enter 0 to skip:   ');
            if length(peaks)==1
                %disp('Skipping this peak set. There is only one peak..');
                peaks=[];
                repeatflag=0;
            end
            
            if checkthres == 1
               % fprintf('Previous threshold multiplier:   %3.0f \n', minpkht_thres);
                minpkht_thres = input('Input new threshold:   ');
            else  %%%%% add elseif statement to try anyways
%                 peaks = [];
                goflag = 1;
            end
            
        else
            goflag = 1;
        end

        if goflag == 1
            repeatflag = 0;
        end
        
    elseif isempty(pkidx)
%         figure(1);
%         hold off                                                                                   
%         subplot(2,2,3); plot(xdata, ydata, '-');
%         hold on
%         set(gca,'XLim',[0 length(xdata)]);
%         set(gca,'YLim',[min(ydata) - 10 max(ydata) + 10]);
        %disp('No peaks were found. Please adjust threshold baseline.')
%         fprintf('Previous threshold multiplier:    %3.0f \n', minpkht_thres)
%         minpkht_thres = input('Input new threshold multiplier:    ');
        peaks = [];
        repeatflag=0;
    end
    
end
return
end
