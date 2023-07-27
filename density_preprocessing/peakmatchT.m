function peakmatchT()
%Last edit in 11/17/2016

% disp('Select file for buoyant masses in less dense fluid...')
% datasmr1_file = uigetfile;
% datasmr1 = readmatrix(datasmr1_file);
% 
% disp('Select file for buoyant masses in more dense fluid...')
% datasmr2_file = uigetfile;
% datasmr2 = readmatrix(datasmr2_file);

% data = [datasmr1; datasmr2];
disp('Select combined datasmr file...')
[data_fname, data_path] = uigetfile('*.csv');
data = readmatrix([data_path data_fname]);

[b ix] = sort(data(:,1));
data=data(ix,:); %sort data by time

%%Teemu's system 02/24/2020
v1=11; %BM1; in media
v2=7; %BM2; in optiprep
calT = 0.8326; %pg/hz

%%baseline check

scrsize = get(0, 'Screensize');
figure('OuterPosition',[0.3 0.05*scrsize(4) 0.7*scrsize(3) 0.95*scrsize(4)])
tempidx1=find(data(:,14)==v1);
b1base=data(tempidx1(:),4);
subplot(2,1,1); plot(b1base, 'o')


tempidx2=find(data(:,14)==v2);
b2base=data(tempidx2(:),4);
subplot(2,1,2); plot(b2base, 'o')

input('GO?');

close all;

% idxf=find(data(:,14)==v1 & data(:,11)./data(:,3)<=0.1 & abs(data(:,6)-data(:,8))./data(:,3)<0.2);%node deviation 10% of peak value
idxf=find(data(:,14)==v1);
idxb=find(data(:,14)==v2);

i=1;
pair_data=[];
iPair=1;
tcut=15;
tcutfw = -999999999999;  % 40

%values for long term dry density tracking
%tcut=40;
%tcutfw = 26;

%values for typical end point assay
%tcut=14;
%tcutfw = 10;

multiplefwcount=0;
multiplebwcount=0;
nobwcount = 0;
singlefwcount=0;

if data(end,14)==v1
    runend=length(idxf)-1;
else
    runend=length(idxf);
end

% runend

while i<=runend
    idxtemp_fw=[];
    idxtemp_fw = find(abs(data(setxor(idxf, idxf(i)),1) - data(idxf(i),1)) < tcutfw);
    if numel(idxtemp_fw)>0
        multiplefwcount = multiplefwcount+1;
        i=i+1;
    else 
        singlefwcount = singlefwcount +1;
        %numel=0 and thus no forward peak within the time limit
        idxtemp_bw = find(data(:,1) - data(idxf(i),1) >0 & data(:,1)-data(idxf(i),1)<=tcut & data(:,14)==v2);
        if numel(idxtemp_bw) ==0
            nobwcount = nobwcount+1;
            i=i+1;
        elseif numel(idxtemp_bw)>1
            multiplebwcount = multiplebwcount+1;
            i=i+1;
        else
%             disp(' ')
%             fprintf('number of backward peak within tcut is %1.0f', numel(idxtemp_bw));
%             disp(' ');
            pair_data(iPair, 1)=iPair;
            pair_data(iPair, 2:4)=data(idxf(i),2:4);
            pair_data(iPair, 7:9)=data(idxf(i),6:8);
            pair_data(iPair, 5)=data(idxf(i),5); %baseline slope for linear baseline fitting
            pair_data(iPair, 10:12)=data(idxtemp_bw,2:4);
            pair_data(iPair, 15:17)=data(idxtemp_bw,6:8);
            pair_data(iPair, 13)=data(idxtemp_bw,5); %baseline slope for linear baseline fitting
            iPair=iPair+1;
            i=i+1;
        end
    end
end
disp(' ')
fprintf('# of multiple FW, BW and noBW was %2.0f, %2.0f and %2.0f, respecttively', multiplefwcount, multiplebwcount, nobwcount);    
disp(' ' );

input('Move Forward?');


reffreq1 = input('Type in reference freq for BM1:    ');     % 1162704
reffreq2 = input('Type in reference freq for BM2:    ');    % 1149042



%resfreql15=reffreq1+mean(pair_data([1:15],4))
% resfreql15=1307300+2700;


% if sysnum==1 %%system 1
%     pair_data(:,6)= ((reffreq1+pair_data(:,4))-1683398.5)/(-237556.0);
%     pair_data(:,14)=((reffreq2-pair_data(:,12))-1683398.5)/(-237556.0);
%     pair_data(:,18)=(pair_data(:,14).*pair_data(:,3)+pair_data(:,6).*pair_data(:,11))./(pair_data(:,3)+pair_data(:,11));
%     pair_data(:,19)=cal1*(pair_data(:,3)+pair_data(:,11))./(pair_data(:,14)-pair_data(:,6));
%     
%     
% else %%system 2
% 
%     pair_data(:,6)=1.008+(resfreql15-(reffreq1+pair_data(:,4)))./(200279.424);
%     pair_data(:,14)=1.008+(resfreql15-(reffreq2-pair_data(:,12)))./200279.424;
%     
%     pair_data(:,18)=(pair_data(:,14).*pair_data(:,3)+pair_data(:,6).*pair_data(:,11))./(pair_data(:,3)+pair_data(:,11));
%     pair_data(:,19)=calA*(pair_data(:,3)+pair_data(:,11))./(pair_data(:,14)-pair_data(:,6));
%     pair_data(:,20)=pair_data(:,2)./60;
% 
%     

% here adjust the slow but consistent baseline drop
intercept = 1311864.6829;
slope = -148677.2764; 
    
    pair_data(:,6)=(reffreq1-pair_data(:,4)-intercept)./slope; %baseline_1 density
    pair_data(:,14)=(reffreq2-pair_data(:,12)-intercept)./slope; %baseline_2 density
    
    pair_data(:,18)=(pair_data(:,14).*pair_data(:,3)+pair_data(:,6).*-pair_data(:,11))./(pair_data(:,3)-pair_data(:,11)); %convert - sign in front of pairdata11 to + for total density measurements
    pair_data(:,19)=calT*(pair_data(:,3)-pair_data(:,11))./(pair_data(:,14)-pair_data(:,6));    %convert - sign in front of pairdata11 to + for total density measurements
    pair_data(:,20)=pair_data(:,2)./60;

    writematrix(pair_data, [data_path 'paired_peak_data.csv']);
end

% COLUMNS of pair_data variable explained here:
% 1: cell number
% 2: BM1 time(min), 
% 3: BM1 average antinode (Hz), 
% 4: baseline1 freq, Hz 
% 5: baseline1 slope (for linear baseline fitting); 
% 6: baseline1 density; 
% 7-9: BM1 peaks 1-3; 
% 10: BM2 time(min); 
% 11: BM2 average antinode (Hz); 
% 12: baseline2 freq (Hz)
% 13 baseline2 slope (for linear baseline fitting); 
% 14: baseline2 density:
% 15-17: BM2 peaks 1-3;
% 18: density (g/cm^3)
% 19: volume (fL)
% 20: time (hr)