function [pairing_stats, readout_paired, paired_smr_ind] = ...
    readout_pairing(run_params, smr_input, pmt_input, analysis_params, ...
    save_abs_path)

scrsize = get(0, 'Screensize');

%% Loading SMR and PMT readout
pmt_timestamp = pmt_input.real_time_sec * 1000; % ms
smr_timestamp = smr_input.real_time_sec * 1000; % ms

%% Window of PMT detection with SMR time-cordinates as origins
trace=[];

window = 3000;

c =1;
hit = 0;
n = 1;
for j = 1:length(smr_timestamp)
    for i= 1:length(pmt_timestamp)
        run_trace_diff = smr_timestamp(j) - pmt_timestamp(i);
            if run_trace_diff<window && run_trace_diff>=-window
                trace(c) = smr_timestamp(j)-pmt_timestamp(i);
                c =c+1;
                hit = 1;
            end
    end
    if hit==0
        n =n+1;
    end
    hit = 0;
end

%% Surface plot for PMT-SMR time lag
figure('OuterPosition',[0.2*scrsize(3) 0.3*scrsize(4) 0.6*scrsize(3) 0.5*scrsize(4)]);
subplot(2,1,1)
%[counts,edges] = histcounts(trace,2*window);
[counts,edges] = histcounts(trace,500);
x = edges(1:end-1);
y = zeros(1,length(x));
col = counts;  % This is the color, vary with x in this case.

surface([x;x],[y;y],[col;col],...
        'facecol','no',...
        'edgecol','interp',...
        'linew',100);
xlim([-800,800])
xlabel('Delta T from PMT to SMR signals (ms)')
set(gca, 'YTick', [])
c=colorbar;
set(get(c,'title'),'string','PMT occurrence','Rotation',0);

subplot(2,1,2)
plot_trace_mode_offset = 15;
histogram(trace,'BinWidth',0.5)
xlim([mode(trace)-plot_trace_mode_offset,mode(trace)+plot_trace_mode_offset])
xlabel('Delta T from PMT to SMR signals (ms)')
ylabel('Counts')

%% Pairing

%set window limit for PMT-SMR pairing
min_time_threshold = input('\nLower threshold for PMT to SMR transit time:');
max_time_threshold = input('\nUpper threshold for PMT to SMR transit time:');


paired_pmt_ind = zeros(length(pmt_timestamp),1);
paired_smr_ind = zeros(length(pmt_timestamp),1);
paired_delta_t = zeros(length(pmt_timestamp),1);
multi_count =0;
n= 1;
for i= 1:length(smr_timestamp)
    for j = 1:length(pmt_timestamp)
        run_diff = pmt_timestamp(j)-smr_timestamp(i);
            if run_diff> -max_time_threshold && run_diff<-min_time_threshold   
                paired_smr_ind(n) = i;
                paired_pmt_ind(n) = j;     
                paired_delta_t(n) = smr_timestamp(i)- pmt_timestamp(j);
                n=n+1;   
            end
       
    end
end

%%================ HIGHLY CRITICAL STEP========================%% 
%%======doublets and multiplets removal from paired array======%%

% logging raw unfiltered paired array
pre_filt_paired_pmt_ind = paired_pmt_ind(1:n-1);
pre_filt_paired_smr_ind = paired_smr_ind(1:n-1);
pre_filt_paired_delta_t = paired_delta_t(1:n-1);

% Step 1: Grabing SMR indices that only appeared once in the raw paired array
[~,ia_smr,ic_smr] = unique(paired_smr_ind(1:n-1));
 a_counts_smr = accumarray(ic_smr,1);
 value_counts_smr = [ia_smr, a_counts_smr];
 uni_paried_ind_smr = ia_smr(a_counts_smr==1);
 
% Step 2: updateing paired array with unique-smr indices
uni_paired_pmt_ind = paired_pmt_ind(uni_paried_ind_smr);
uni_paired_smr_ind = paired_smr_ind(uni_paried_ind_smr);
uni_paired_delta_t = paired_delta_t(uni_paried_ind_smr);

% Step 3: Grabing pmt indices that only appeared once in unique-smr paired array
[~,ia_smr_pmt,ic_smr_pmt] = unique(uni_paired_pmt_ind);
 a_counts_smr_pmt = accumarray(ic_smr_pmt,1);
 value_counts_smr_pmt = [ia_smr_pmt, a_counts_smr_pmt];
 uni_paried_ind_smr_pmt = ia_smr_pmt(a_counts_smr_pmt==1);

% Step 4: updateing paired array with unique-smr-pmt indices
paired_pmt_ind = uni_paired_pmt_ind(uni_paried_ind_smr_pmt);
paired_smr_ind = uni_paired_smr_ind(uni_paried_ind_smr_pmt);
paired_delta_t = uni_paired_delta_t(uni_paried_ind_smr_pmt);
n = length(paired_pmt_ind);
multiplet_count = length(pre_filt_paired_pmt_ind)-n;

%% Generate output
prt_paired_smr = 100*length(paired_smr_ind)/height(smr_input);
prt_paired_pmt = 100*length(paired_pmt_ind)/height(pmt_input);
dropout_rate = 100*multiplet_count/length(pre_filt_paired_pmt_ind);

pairing_stats = [prt_paired_smr,prt_paired_pmt,dropout_rate,length(paired_smr_ind)];

%format follows: SMR input table merged with PMT input table, each row is a
%paired particle
readout_paired = [smr_input(paired_smr_ind,:),pmt_input(paired_pmt_ind,2:end)];
readout_paired.elapsed_time_min = (smr_input.real_time_sec(paired_smr_ind)-smr_input.real_time_sec(paired_smr_ind(1)))/60;
readout_paired.pmt2smr_transit_time_ms = paired_delta_t;

out_file_name = 'readout_paired.txt'; 
writetable(readout_paired, fullfile(save_abs_path, out_file_name), 'delimiter', '\t');




Readout_pairing_report_v1(save_abs_path, smr_input, pmt_input, ...
    analysis_params, trace, window, min_time_threshold, max_time_threshold, ...
    readout_paired, multiplet_count);

end
