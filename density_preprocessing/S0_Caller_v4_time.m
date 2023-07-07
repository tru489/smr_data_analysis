function S0_Caller_v4

%%% Original by Sungmin Son
%%% Most recent edit by Nikita Khlystov 12/16

% INPUTS
%       Requires at least a frequency datafile; valvestates datafile is
%       optional
%       Requires the S1_FindPeaks.m function in the same directory
%
% OUTPUTS
%       Calls further peak analysis functions
format long;
% clear all
close all

global datafull
global x
global elapsed_time;
global samplepeak;
global sampletime;
elapsed_time = 0;
samplepeak=[];
sampletime=[];



disp(' ')
disp('Getting frequency data...')
[freqfilepath freqdir filind1] = uigetfile('../*.*','Select Frequency Data File',' ');
if(filind1 == 0)
    disp('Quitting analysis program now...')
    return
else
    fprintf('%s selected for analysis', freqfilepath)
    disp(' ')
    freqfile = fopen(strcat(freqdir, freqfilepath), 'r', 'b');
end

disp(' ')
disp('Getting time data...')
[timefilepath timedir filind2] = uigetfile('../*.*','Select time File',' ');
if(filind2 ~= 0)
    timefile = fopen(strcat(timedir, timefilepath), 'r', 'b');
    fprintf('%s selected for analysis', timefilepath)
    disp(' ')
else
    disp(' ')
    disp('Continuing analysis without time data...')
end

disp(' ')
disp('Getting valvestat data...')
[valvestatefilepath valvestatedir filind3] = uigetfile('../*.*','Select Valve State File',' ');
if(filind3 ~= 0)
    valvestatesfile = fopen(strcat(valvestatedir, valvestatefilepath), 'r', 'b');
    fprintf('%s selected for analysis', valvestatefilepath)
    disp(' ')
else
    disp(' ')
    disp('Continuing analysis without valvestates data...')
end
disp(' ')

% Determine the number of increments into which the main file can be divided
% in order to accelerate analysis by lowering memory usage

n = 0;
datasize = 2e6;   % establish a segment size (~32Mbytes)
while(fseek(freqfile, n*8*datasize, 'bof') == 0)
    % flip forward 8*datasize bytes repeatedly until file ends
    n = n + 1;
end     

% Analyze each segment with the external S1_FindPeaks function
num_segments = n - 1; % total number of segments = length of file in segments

% Define analysis mode - yes = rapid analysis; no = peak by peak processing
% with user input

analysismode = input('Rapid analysis mode? (1 = Yes, 0 = No):    ');
if analysismode == 1
    dispprogress = input('Display progress? (1 = Yes, 0 = No):       ');
else
    dispprogress = 1;
end
analysisparams = [analysismode dispprogress];

disp(' ')

scrsize = get(0, 'Screensize');
figure('OuterPosition',[0 0.05*scrsize(4) scrsize(3) 0.95*scrsize(4)])

datafull = zeros(13,1);

i = 0;
while(1)
    
    % flip to the next segment data piece 8*datasize bytes ahead
    fseek(freqfile, i*8*datasize, 'bof');   % datatype double is 8bytes

    if(filind2 ~= 0)
        % flip to the next valvestate segment, datasize bytes ahead
        fseek(timefile, i*8*datasize, 'bof'); % datatype int is 8bytes
    end
    
    if(filind3 ~= 0)
        % flip to the next valvestate segment, datasize bytes ahead
        fseek(valvestatesfile, i*datasize, 'bof'); % datatype int is 1byte
    end
    
    % read data starting at i*8*datasize
    x = []; % clear x from previous segment analysis
    x = fread(freqfile, datasize, 'float64=>double');
    
    
    % variable x is now a column vector of the frequency data in the
    % current segment being analyzed
        
    if(filind2 ~= 0 & filind3 ~= 0)                    % if time file specified
%         if(i ~= 28)
            fprintf('Processing %d/%d...\n', i, num_segments)
            s = fread(timefile, datasize, 'float64=>double');
             vv = fread(valvestatesfile, datasize);
             
             %%=======CHANGE sign in front of x for density analysis=======
            datalast = S1_PeakAnalysis_time(-x, s, vv, datafull, i, analysisparams);
%            %%============================================================
%         end
    elseif (filind2 ~= 0 & filind3 == 0)                                 % else = valvestates file not specified
        s = fread(timefile, datasize, 'float64=>double');
        vv = zeros(length(x),1);
        fprintf('Processing %d/%d...\n', i, num_segments)
        disp(' ')
        datalast = S1_PeakAnalysis_time(x, s, vv, datafull, i, analysisparams);
    else
        s = [1:1:length(x)]';
        vv = zeros(length(x),1);
        fprintf('Processing %d/%d...\n', i, num_segments)
        disp(' ')
        datalast = S1_PeakAnalysis_time(x, s, vv, datafull, i, analysisparams);
    end
    
    datafull = [datafull datalast];
    
    i = i + 1;                          % move to next segment

    if length(x) < datasize             % if loop reaches end of main file, stop
        figure('OuterPosition',[0 0.05*scrsize(4) scrsize(3) 0.95*scrsize(4)])
        plot(datafull(1,:),datafull(2,:),'.b')
        title(strcat('Frequency Data for: ', freqfilepath));
        xlabel('Time (s)')
        ylabel('Frequency (Hz)')
        break
%     elseif i>20
%         figure('OuterPosition',[0 0.05*scrsize(4) scrsize(3) 0.95*scrsize(4)])
%         plot(datafull(1,:),datafull(2,:),'.b')
%         title(strcat('Frequency Data for: ', freqfilepath));
%         xlabel('Time (s)')
%         ylabel('Frequency (Hz)')
%         break
    end
    
end

disp(' ')
    fprintf('%s finished analysis', freqfilepath)
disp(' ')
% once finished with analysis, clear enormous datafiles from memory
fclose(freqfile);
if(filind2 ~= 0)
    disp(' ')
    fprintf('%s finished analysis', timefilepath)
    disp(' ')
    fclose(timefile);
end
% if(filind3 ~= 0)
%     fclose(valvestatesfile);
% end

end
