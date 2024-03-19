function [output_pmt_table, param_table] = analyze_pmt_data(run_params, ...
    pmt_file_ID, time_file_ID, save_abs_path)
% Analysis function for fluorescent exclusion peak detection from PMT data 
%
% Arguments:
%   run_params (struct): running parameters for analysis
%   pmt_file_ID (array(int)): file IDs for each PMT channel
%   time_file_ID (int): file ID for PMT time file
%   save_abs_path (str): absolute path for saving files

%% Unload parameters
analysis_params = run_params.fl_excl;

%% Run mode and upstream compensation determination
% To detemine if the user wants to analyze data including fluorescence
% exclusion or purely for positive labeling

fxm_channel = find(analysis_params.detect_thresh_pmt < 0, 5);

if isempty(find(analysis_params.detect_thresh_pmt < 0, 5))
    analysis_params.fxm_mode = 0;
else
    analysis_params.fxm_mode = 1;
    analysis_params.fxm_channel = fxm_channel;
end
fxm_mode = analysis_params.fxm_mode;

% To detemine if the user wants to input compensation factor(s) from upstream
% channels to compensate for fxm channel
if fxm_mode == 1
    fprintf('Fluorescence exclusion (fxm) analysis mode entered...\n')
    analysis_params.upstream_compen = input('Apply upstream compensation for fxm channel? Yes-1 No-0\n');
    if analysis_params.upstream_compen == 1
        compen_flag = 0;
        while compen_flag == 0
            compen_factor = input('Input compensation factor(s) as an array (array must have entries for every upstream channel of fxm channel):\n');
            if length(compen_factor) ~= find(analysis_params.detect_thresh_pmt<0, 1)-1
                warning('Length of the compensation array does not match with expected input length, please re-enter.')
            else
                compen_flag = 1;
            end
        end
    end
end

analysis_mode = run_params.analysis_params.analysismode_pmt;
disp_progress = run_params.analysis_params.dispprogress_pmt;

%% ---------------- Runtime Display settings ----------------- %%
if disp_progress
    %set analysis display screen size
    scrsize = get(0, 'Screensize');
    figure('OuterPosition',[0 0.05*scrsize(4) scrsize(3) 0.95*scrsize(4)])
end
disp_params.analysis_mode = analysis_mode;
disp_params.disp_progress = disp_progress;

num_segments = get_num_segments(pmt_file_ID(1), run_params.fl_excl.datasize);


%% -------------  Main analysis on looping data segments  ------------ %%
% display progress bar
progress_bar = waitbar(0,'Starting analysis...');
progress_bar.Position=[600,400,290,170];
pause(0.5)

n_pmt_channel = run_params.fl_excl.n_pmt_channel;

rawdata_pmt = cell(1,n_pmt_channel);

segment_loop = 0;
flag = 0;
full_readout_initialized = 0;

pass_struct_pmt.elapsed_time=0;
pass_struct_pmt.elapsed_index=0;
pass_struct_pmt.elapsed_peak_count=0;

while ~flag 
    % seek data for current segement, datatype int is 8bytes
    for channel = 1:n_pmt_channel
        fseek(pmt_file_ID(channel), ...
            segment_loop * 8 * analysis_params.datasize, 'bof');
    end
    fseek(time_file_ID, segment_loop * 8 * analysis_params.datasize, 'bof');
    
    % read raw pmt and time file
    for channel = 1:n_pmt_channel
        rawdata_pmt{1,channel} = fread(pmt_file_ID(channel), ...
            analysis_params.datasize, 'float64=>double');
    end
    rawdata_time_pmt = fread(time_file_ID, analysis_params.datasize, ...
        'float64=>double');
  
    [seg_readout_pmt, progress_msg, pass_struct_pmt] = ...
        P1_peakanalysis_pmt(run_params, analysis_params, pass_struct_pmt, ...
        segment_loop, num_segments, rawdata_pmt, rawdata_time_pmt, disp_params);
    
    if ~isempty(seg_readout_pmt)
        if full_readout_initialized == 0
            full_readout_pmt = seg_readout_pmt;
            full_readout_initialized = 1;
        else        
            full_readout_pmt = vertcat(full_readout_pmt,seg_readout_pmt);
        end
        waitbar(segment_loop / num_segments, progress_bar, ...
            {progress_msg.line0, progress_msg.line1, ...
            progress_msg.line2, progress_msg.line3});
        pause(0.01)
    end
    
    segment_loop = segment_loop + 1;
    
    if length(rawdata_pmt{1,1}) < analysis_params.datasize
        waitbar(1, progress_bar, {'Finishing'});
        pause(0.5)
        flag = 1;
    end
end

%% Quality check to remove low-quality signals
% full_readout_pmt = full_readout_pmt([1:3300, 4.72e4:49386],:);
if fxm_mode == 1
    non_nan_ind = find(~isnan(full_readout_pmt.baseline(:,fxm_channel)));
    base_med = median(full_readout_pmt.baseline(non_nan_ind(1:round(length(non_nan_ind)*0.3)),fxm_channel));
    all_base_med_norm = abs(full_readout_pmt.baseline(:,fxm_channel)-base_med);
    base_amp_pass_ind = find(all_base_med_norm < base_med * analysis_params.thresh_base_height_range);
    all_cell_baselineDiff_over_sig = abs(full_readout_pmt.baseline_left_height(:,fxm_channel)-full_readout_pmt.baseline_right_height(:,fxm_channel))...
        ./abs(full_readout_pmt.amplitude(:,fxm_channel)-full_readout_pmt.baseline(:,fxm_channel));
    base_diff_pass_ind = find(all_cell_baselineDiff_over_sig<analysis_params.thresh_baselineDiff_over_sig);
    base_leftslope_pass_ind = find(abs(full_readout_pmt.baseline_left_slope(:,fxm_channel)) < analysis_params.thresh_base_slope);
    base_rightslope_pass_ind = find(abs(full_readout_pmt.baseline_right_slope(:,fxm_channel)) < analysis_params.thresh_base_slope);

    cell_pass_ind =intersect(base_amp_pass_ind,intersect(base_diff_pass_ind, intersect(base_leftslope_pass_ind,base_rightslope_pass_ind)));
    pass_rate = 100*length(cell_pass_ind)/height(full_readout_pmt.amplitude);
    QC_msg = sprintf('%% %0.2f of detected signals passed QC check',pass_rate);
else
    pass_rate = 100;
    cell_pass_ind = 1:1:height(full_readout_pmt);
    QC_msg = sprintf('QC check are passed');
end
waitbar(1,progress_bar,QC_msg);
pause(0.5)
% hist(all_cell_baselineDiff_over_sig,1000)
%  scatter(abs(full_readout_pmt.baseline_right_slope(:,fxm_channel)),abs(full_readout_pmt.baseline_left_slope(:,fxm_channel)))

%% Apply compensation to fxm channel if needed by user
if fxm_mode == 1
    fxm_compen_amp = full_readout_pmt.amplitude(:,fxm_channel);
    if analysis_params. upstream_compen == 1
        for i = 1:length(compen_factor)
            fxm_compen_amp = (abs(full_readout_pmt.amplitude(:,i)-full_readout_pmt.baseline(:,i)))*compen_factor(i)+fxm_compen_amp;
        end
        full_readout_pmt.amplitude(:,fxm_channel) = fxm_compen_amp;
        upComp_msg = sprintf('Fxm upstream compensation applied');
    else
        upComp_msg = sprintf('Fxm upstream compensation skipped');
    end
else
    upComp_msg = sprintf('Fxm upstream compensation skipped');
end

waitbar(1,progress_bar,{QC_msg,upComp_msg});
pause(0.5)

%% Apply compensation to fxm - downstream channel to remove effect from fxm spillover
full_readout_pmt.signal_V = abs(full_readout_pmt.amplitude-full_readout_pmt.baseline);

if fxm_mode == 1
    full_readout_pmt.signal_V(:,fxm_channel) = abs((full_readout_pmt.amplitude(:,fxm_channel)-full_readout_pmt.baseline(:,fxm_channel))./full_readout_pmt.baseline(:,fxm_channel));
    for i= fxm_channel+1:n_pmt_channel
        full_readout_pmt.signal_V(:,i) = abs(full_readout_pmt.amplitude(:,i)-full_readout_pmt.baseline(:,i).*...
            (full_readout_pmt.amplitude(:,fxm_channel)./full_readout_pmt.baseline(:,fxm_channel)));
    end
    downComp_msg = sprintf('Fxm downstream compensation applied');
else
    downComp_msg = sprintf('Fxm downstream compensation skipped');
end
waitbar(1, progress_bar, {QC_msg,upComp_msg,downComp_msg});
pause(0.5)

%% Generate PMT readout output file
%format follows: 
%for only positive labeling: [time of detection(computer real time), PacificBlue(mV),FITC(mV), PE(mV), APC(mV), Cy7(mV)]
%for Fxm, the fxm channel have raw volume signal as the unitless number, it
%is the dip in baseline normlized by the baseline height
output_msg = 'Generating output';
waitbar(1,progress_bar,{QC_msg,upComp_msg,downComp_msg,output_msg});
pause(0.5)

full_readout_pmt.signal = full_readout_pmt.signal_V*1000; %Convert to mV
output_pmt = [full_readout_pmt.time_of_detection(cell_pass_ind),full_readout_pmt.signal((cell_pass_ind),:),full_readout_pmt.baseline((cell_pass_ind),:)];
output_pmt_table = array2table(output_pmt);
output_pmt_table.Properties.VariableNames = {'real_time_sec','pmt1_mV','pmt2_mV','pmt3_mV','pmt4_mV','pmt5_mV',...
    'pmt1_baseline_mV','pmt2_baseline_mV','pmt3_baseline_mV','pmt4_baseline_mV','pmt5_baseline_mV'};
if fxm_mode == 1
    output_pmt_table.Properties.VariableNames{fxm_channel+1} = 'vol_au'; %% rename fxm channel with 1 offset colume of timestamp
    output_pmt_table.Properties.VariableNames{fxm_channel+6} = 'fxm_baseline_mV'; %% rename fxm channel with 6 offset colume of timestamp and amplitudes
end


out_file_name = 'pmt_peak_data.txt';

writetable(output_pmt_table, fullfile(save_abs_path, out_file_name), ...
    'delimiter', '\t');

output_msg = 'Generating output... done';
waitbar(1,progress_bar,{QC_msg,upComp_msg,downComp_msg,output_msg});
pause(0.5)
report_msg = 'Generating report...';
waitbar(1,progress_bar,{QC_msg,upComp_msg,downComp_msg,output_msg,report_msg});
pause(0.5)

% generate analysis report
PMT_readout_report_v1(save_abs_path, ...
    '', analysis_params, full_readout_pmt(cell_pass_ind,:), QC_msg);
report_msg = 'Generating report... done';
waitbar(1,progress_bar,{QC_msg,upComp_msg,downComp_msg,output_msg,report_msg});

%% generate analysis params txt files 
analysis_params_fpath = fullfile(save_abs_path, ...
    'readout_pmt_analysis_params.txt');
param_table = struct2table(analysis_params);

writetable(param_table, analysis_params_fpath, ...
    'Delimiter', ' ')
figure(1)
scatter(full_readout_pmt.time_of_detection(:), ...
    full_readout_pmt.baseline(:,fxm_channel),...
    5, 'filled', "MarkerFaceAlpha", 0.5)
hold on
scatter(full_readout_pmt.time_of_detection(cell_pass_ind), ...
    full_readout_pmt.baseline(cell_pass_ind,fxm_channel), ...
    5,'filled',"MarkerFaceAlpha",0.5)
xlabel('Time')
ylabel('FXM baseline (V)')
legend(["All particles","Pass QC"],'Location','southoutside','Orientation','horizontal')
print(gcf,fullfile(run_params.saving.save_abs_path, 'FXM baseline vs time QC check.png'),'-dpng','-r1200')

end

