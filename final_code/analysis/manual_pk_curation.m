function datasmr_processed = manual_pk_curation(run_params, samplepeak, ...
    sampletime, datasmr)
% Manual peak curation for frequency data
% 
% Arguments:
%   run_params (struct): run parameters necessary for running peak analysis
%       scripts
%   samplepeak (array(double)): array containing frequency peak data 
%   sampletime (array(double)): array containing corresponding time data
%   datasmr (array(double)): summary data array for detected peaks
% Returns:
%   datasmr_processed (array(double)): summary data array for detected
%       peaks, filtered based on manual curation

%% Setup
% samplepeak looks like [(..data...), 1000, pkorder, sectionnumber, etc...]
% Finds the number of peaks (i.e. number of "1000s" in array)
dataidx = [];
idx0 = find(samplepeak == 1e3);

% Creates local struct to store high-level peak data
Peak.count = length(idx0);
Peak.start = zeros(1, Peak.count);
Peak.process = zeros(1, Peak.count); % 2 = peak rejected; 1 = accepted
Peak.peakorder = zeros(1, Peak.count);
Peak.start(1) = 1;

disp('-----------------------------------------------');
fprintf('Total Number Peaks : %d', length(idx0));

if length(idx0) ~= length(datasmr)
    disp('WARNING. Length of sample peaks does not match datasmr!');
    input('Go?');
end

disp('-----------------------------------------------');
disp('Press the following keys: ');
disp('    1) accept the peak = a');  
disp('    2) go to the previous accepted peak = b'); 
disp('    3) reject this peak = any key'); 
disp('    4) exit this routine = x'); 
disp('-----------------------------------------------');

% Find starting indices for each peak within array of frequency data
for j=2:Peak.count
    Peak.start(j) = idx0(j-1) + 3; 
end

% Save peak index within total array of peaks
for j=1:Peak.count
    Peak.peakorder(j) = samplepeak(idx0(j) + 1);
end

% Save segment number for each peak
for j=1:Peak.count
    Peak.sectnum(j) = samplepeak(idx0(j) + 2);
end

%% Discard peaks with weird node and peak height imbalance
% Unload parameters
pk_imbal_thresh = run_params.curation.pk_imbal_thresh;
nod_imbal_thresh = run_params.curation.nod_imbal_thresh;
nod_dev_thresh = run_params.curation.nod_dev_thresh;

% Peak imbalance mask; difference of peak 3 and 1 height / average 
pk_imbal_mask = abs((datasmr(:,6) - datasmr(:,8)) ./ datasmr(:,3)) > ...
    pk_imbal_thresh;

% Node imbalance mask; difference of node deviations 1 and 2 / 
% average of peak 3 and 1 height
nod_imbal_mask = abs((datasmr(:,9) - datasmr(:,10)) ./ datasmr(:,3)) > ...
    nod_imbal_thresh;

% Node deviation mask; average node deviation between nodes 1 and 2 / 
% average of peak 1 and 3 height
nod_dev_mask = abs(datasmr(:,11) ./ datasmr(:,3)) > nod_dev_thresh;

% Indices to discard
idx_discard = find(pk_imbal_mask | nod_imbal_mask | nod_dev_mask);

% Mark peaks for discarding
Peak.process(idx_discard) = 2;
fprintf('#of peaks pre-discarded: %d', length(idx_discard));
disp('-----------------------------------------------');

%% Iterate through peaks for manual curation
scrsize = get(0, 'Screensize');
figure('OuterPosition',[0 0.05*scrsize(4) scrsize(3) 0.95*scrsize(4)])

exit_flag = 0;
i= 0 ;

while i < length(idx0)
    i=i+1;
    
    if exit_flag
        break
    end
    
    % Process/accept user inputs for a single peak
    skip = 0;
    while ~skip && ~exit_flag
        if i == Peak.count % final peak in array
            peak = samplepeak(Peak.start(i):idx0(end)-1);
            time = sampletime(Peak.start(i):idx0(end)-1);
        elseif ismember(i, idx_discard) ==1
            disp('Peak marked for auto-discard. Jumping to next one');
            break;
        else % If peak not marked for auto-discard
            peak = samplepeak(Peak.start(i):Peak.start(i+1)-4);
            time = sampletime(Peak.start(i):Peak.start(i+1)-4);
        end
        
        % Set peak to baseline of 0 for plotting
        peak = peak-median(peak);
        plot(time, peak);

        fprintf('Peak #%d / %d', i, length(idx0)-i);
        evaluate_fit = getkey('non-ascii'); 
        if evaluate_fit == 'a' % Accept the peak
            Peak.process(i) =  1;
            skip = 1;
            disp('ACCEPTED');
            disp('------------------------------------------------------');
            fprintf('    # peaks accepted so far: %d / %d', ...
                length(find(Peak.process == 1)), i);
            fprintf('    # peaks rejected so far: %d / %d', ...
                length(find(Peak.process == 2)), Peak.count);
            disp('------------------------------------------------------');
            
            % Find index of peak in datasmr summary array to mark the peak
            % for retention
            tempidx = find(datasmr(:,14) == Peak.sectnum(i) & ...
                datasmr(:,17) == Peak.peakorder(i));
            if tempidx == i
                disp('Matches well!');
            end

            dataidx = [dataidx tempidx];
        elseif evaluate_fit == 'x' % Exit from the aligner routine
            exit_flag = 1;
        elseif evaluate_fit == 'b' % Go to previous peak
            i = find(Peak.process(1:i-1) == 1, 1, 'last') - 1; 
            Peak.process(i+1) = 0;
            disp('going back to previous peak...');
            dataidx(end) = [];
            skip = 1;
        else % If any other key is pressed, reject peak
            Peak.process(i) = 2;  
            disp('REJECTED');
            disp('------------------------------------------------------');
            fprintf('    # of peaks selected so far: %d / %d', ...
                length(find(Peak.process == 1)), i);
            fprintf('    # of peaks rejected so far: %d / %d', ...
                length(find(Peak.process == 2)), Peak.count);
            disp('------------------------------------------------------');
            skip = 1;
        end
    end
end

% Final processed datasmr summary array
datasmr_processed = datasmr(dataidx,:);

end

