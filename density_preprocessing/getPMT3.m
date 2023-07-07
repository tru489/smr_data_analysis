function getPMT3()

%% Read Recording from PMT

clear all
close all

global x1
global x2
global x3
global datafullpmt1
global datafullpmt2
global datafullpmt3
global elapsed_time
global elapsed_index

elapsed_time=0;
elapsed_index=0;


disp(' ')
disp('Getting PMT Channel 1 readout...')
[pmtfilepath1 pmtdir1 filind1] = uigetfile('../*.*','Select PMT Channel 1 Data File',' ');
if(filind1 == 0)
    disp('Quitting analysis program now...')
    return
else
    disp(' ')
    fprintf('%s selected for analysis', pmtfilepath1)
    disp(' ')
    pmtfile1 = fopen(strcat(pmtdir1, pmtfilepath1), 'r', 'b');
end

disp(' ')
disp('Getting PMT Channel 2 readout...')
[pmtfilepath2 pmtdir2 filind2] = uigetfile('../*.*','Select PMT Channel 1 Data File',' ');
if(filind2 == 0)
    disp('Quitting analysis program now...')
    return
else
    disp(' ')
    fprintf('%s selected for analysis', pmtfilepath2)
    disp(' ')
    pmtfile2 = fopen(strcat(pmtdir2, pmtfilepath2), 'r', 'b');
end

disp(' ')
disp('Getting PMT Channel 3 readout...')
[pmtfilepath3 pmtdir3 filind3] = uigetfile('../*.*','Select PMT Channel 1 Data File',' ');
if(filind3 == 0)
    disp('Quitting analysis program now...')
    return
else
    disp(' ')
    fprintf('%s selected for analysis', pmtfilepath3)
    disp(' ')
    pmtfile3 = fopen(strcat(pmtdir3, pmtfilepath3), 'r', 'b');
end

disp(' ')
disp('Getting time data...')
[timefilepath timedir filind4] = uigetfile('../*.*','Select time File',' ');
if(filind4 ~= 0)
    timefile = fopen(strcat(timedir, timefilepath), 'r', 'b');
else
    disp(' ')
    disp('Continuing analysis without time data...')
end
disp(' ')

n = 1;
datasize = 2e6;   % establish a segment size (~32Mbytes)
while(fseek(pmtfile1, n*8*datasize, 'bof') == 0)
    % flip forward 8*datasize bytes repeatedly until file ends
    n = n + 1;
end   

num_segments = n - 1; % total number of segments = length of file in segments



analysismode = input('Rapid analysis mode? (1 = Yes, 0 = No):    ');
if analysismode == 1
    dispprogress = input('Display progress? (1 = Yes, 0 = No):       ');
else
    dispprogress = 1;
end
analysisparams = [analysismode dispprogress];

disp(' ')
datafullpmt1 = zeros(4,1);
datafullpmt2 = zeros(4,1);
datafullpmt3 = zeros(4,1);

scrsize = get(0, 'Screensize');
figure('OuterPosition',[0 0.05*scrsize(4) scrsize(3) 0.95*scrsize(4)])

i=0;
while(1)
    
    fseek(pmtfile1, i*8*datasize, 'bof');
    fseek(pmtfile2, i*8*datasize, 'bof');
    fseek(pmtfile3, i*8*datasize, 'bof');
    
    if(filind2 ~= 0)
        % flip to the next valvestate segment, datasize bytes ahead
        fseek(timefile, i*8*datasize, 'bof'); % datatype int is 8bytes
    end
    
    x1=[]; x2=[]; x3=[];
    x1=fread(pmtfile1, datasize, 'float64=>double');
    x2=fread(pmtfile2, datasize, 'float64=>double');
    x3=fread(pmtfile3, datasize, 'float64=>double');
  
    
    if(filind4 ~= 0)
        fprintf('Processing %d / %d...\n', i, num_segments);
        s = fread(timefile, datasize, 'float64=>double');
        [data1, data2, data3] = Peakanalysis_pmt(x1, x2, x3, s, analysisparams);
    end
    datafullpmt1 = [datafullpmt1 data1];
    datafullpmt2 = [datafullpmt2 data2];
    datafullpmt3 = [datafullpmt3 data3];
    
%     ydata1=sgolayfilt(sgolayfilt(x,3,7), 3,7);
%     ydata2=medfilt1(x,7);
%     figure(1);
%     subplot(2,1,1);
%     plot(ydata1, '.');
%     subplot(2,1,2);
%     plot(ydata2, '.');
%     figure(2);
%     plot(x,'.');
%     input('go?');
    
    i=i+1;
    
     if length(x1) < datasize
         break
     end
end



