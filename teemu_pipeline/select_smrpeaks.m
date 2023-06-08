global samplepeak
global sampletime
global sidelength
global datasmr

idx=[]; dataidx=[];
idx0 = find(samplepeak==1e3);
Peak.count = length(idx0);


Peak.start = zeros(1,Peak.count);
Peak.process = zeros(1,Peak.count);
Peak.peakorder = zeros(1, Peak.count);
Peak.start(1)=1;
j=0;
display('-----------------------------------------------');
fprintf('Total Number Peaks : %d', length(idx0));

if length(idx0) ~= length(datasmr)
    display('WARNING. length of sample peaks does not match datasmr!');
    input('go?');
end

display(' ');
display('-----------------------------------------------');
display('press the following keys: ');

display('1) accept the peak = a');  display('2) go to the previous accepted peak = b'); 
 display('3) reject this peak = any keys ' ); 
display('4) exit this routine = x'); 
display('-----------------------------------------------');

for j=2:Peak.count
    Peak.start(j)=idx0(j-1)+3; %% samplepeak looks like [(..data...), 1000, pkorder, sectionnumber, (...data...) ,1000, pkorder, sectionnumber ...]
end

for j=1:Peak.count
    Peak.peakorder(j)=samplepeak(idx0(j)+1);
end

for j=1:Peak.count
    Peak.sectnum(j)=samplepeak(idx0(j)+2);
end

%below added 08/19/2016
%========== Peak pre-processing ==========
%discard peaks with weird node and peak height imbalance

%idx_discard = find(abs((datasmr(:,6)-datasmr(:,8))./datasmr(:,3)) > 0.1 | abs((datasmr(:,9)-datasmr(:,10))./datasmr(:,3)) >0.01 | abs(datasmr(:,11)./datasmr(:,3))>0.2);
idx_discard = find(abs((datasmr(:,6)-datasmr(:,8))./datasmr(:,3)) > 0.5 | abs((datasmr(:,9)-datasmr(:,10))./datasmr(:,3)) >0.5 | abs(datasmr(:,11)./datasmr(:,3))>0.4);


Peak.process(idx_discard) =2;
fprintf('#of peaks pre-discarded: %d', length(idx_discard));
display(' ');
display('-----------------------------------------------');





scrsize = get(0, 'Screensize');
figure('OuterPosition',[0 0.05*scrsize(4) scrsize(3) 0.95*scrsize(4)])

exit_flag = 0;
i=0;

while i<length(idx0);
    i=i+1;
    
    if exit_flag
        break
        
    end
    skip = 0;
    
    
    
    %% Initializing the peak values
    
    
    
    while ~skip && ~exit_flag
        
        if i==Peak.count %end peak
            peak = samplepeak(Peak.start(i):idx0(end)-1);
            time = sampletime(Peak.start(i):idx0(end)-1);
        elseif ismember(i, idx_discard) ==1
            display(' ');
            display('discarded peaks. jumping to next one');
            display(' '); peak=[]; time=[];
            skip =1; 
            break;
        else
        peak = samplepeak(Peak.start(i):Peak.start(i+1)-4);
        time = sampletime(Peak.start(i):Peak.start(i+1)-4);
        end
        
        peak=peak-median(peak); %%setting up to a baseline of 0;
%         
%         subplot(2,2,[1 2]);
%         plot(time, peak);
%         subplot(2,2,3)
%         plot(time(sidelength+1-1000:length(time)-sidelength+1000), peak(sidelength+1-1000:length(time)-sidelength+1000));
%         subplot(2,2,4)
%         plot(time, peak); ylim([-5 5]);
%         
          plot(time, peak);
          display(' ' ); fprintf('peak #%d. (%d more to go)', i, length(idx0)-i);
          
        evaluate_fit = getkey('non-ascii'); 
        if evaluate_fit == 'a'; % Accept the peak
            Peak.process(i) =  1;
            skip = 1;
            display(' ... ACCEPTED'); display(' ');
            display('------------------------------------------------------------');
            fprintf('                  # peaks accepted so far: %d / %d', length(find(Peak.process==1)),i); display(' ' );
            fprintf('                  # peaks rejected: %d / %d', length(find(Peak.process==2)),Peak.count); display(' ' );
            display('------------------------------------------------------------');
%             save=[sampletime(Peak.start(i):Peak.start(i+1)-4); samplepeak(Peak.start(i):Peak.start(i+1)-4)];
            tempidx=find(datasmr(:,14)==Peak.sectnum(i) & datasmr(:,17)==Peak.peakorder(i));
            if tempidx == i
                display('matches well!');
            end
            
            dataidx = [dataidx tempidx];
            
        elseif evaluate_fit == 'x' % Exit from the aligner routine
            exit_flag = 1; clc;
           
        elseif evaluate_fit == 'b' % Go to previous peak
            i = find(Peak.process(1:i-1) == 1, 1, 'last') - 1; Peak.process(i+1) = 0;
            display(' '); display('going back to previous peak...'); display(' ');
            dataidx(end)=[];
            skip = 1;
        else
            Peak.process(i) =2;  
             display(' ... REJECTED'); display(' '); display(' ');
            display('------------------------------------------------------------');
            fprintf('number of peaks selected so far: %d / %d', length(find(Peak.process)==1),i); display(' ' );
            fprintf('number of peaks rejected so far: %d / %d', length(find(Peak.process==2)),Peak.count); display(' ' );
            display('------------------------------------------------------------');
            skip = 1;
%              tempidx=find(datafull(12,:)==Peak.peakorder(i));
%              datafull(:,tempidx)=[];
        end
    end
end

datasmr_processed = datasmr(dataidx,:);

dir_path = uigetdir;
path_sep = strsplit(dir_path, filesep);
sample_name = path_sep{length(path_sep) - 1};
writematrix(datasmr_processed, [dir_path filesep sample_name '_datasmr_processed.csv']);

% openvar datasmr_processed

% figure;
% for i=1:length(idx0)
%     hold off;
%     if Peak.process(i)==1
%         section=samplepeak(Peak.start(i):Peak.start(i+1)-3)-median(samplepeak(Peak.start(i):Peak.start(i+1)-3));
%         plot(section, 'ok');
%         hold on
%         sectionsmooth=smooth(section,31);
%         plot(sectionsmooth, 'color', 'red', 'linewidth', 2);
%        
%         
%         
%         
%         
%         save=input('go');
%         if save==1
%             save=[sampletime(Peak.start(i):Peak.start(i+1)-3); samplepeak(Peak.start(i):Peak.start(i+1)-3)];
%         end
%     else
%         tempidx=find(datafull(12,:)==Peak.peakorder(i));
%         datafull(:,tempidx)=[];
%         
%     end
% end
