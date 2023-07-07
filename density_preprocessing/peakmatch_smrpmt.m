function [pair_data]=peakmatch_smrpmt(datasmr, datafullpmt1, datafullpmt2, datafullpmt3) %%% 

calJ=0.605688131; %in pg for G5W3 505-D6
datafullpmt1(:,1)=[];
datafullpmt2(:,1)=[];
datafullpmt3(:,1)=[];

%% ------------------ Pairing Begins ---------------------------
% Pair Parameters
pair_data=[];
tcut=(12000+4000+1000)/1000; %adding backwait+pre swtich delay+post-peak delay.
iPair=1;
i=1;
% idx_unpaired=[];


datapmt=datafullpmt1;


% selecting forward and backward peaks
runend = size(datasmr,1);
% calculating number of loops to run below

runend

defaultcut = 0.23; % rought time for a cell to reach pmt site to the base of the cantilever
updelta = 0.3;
j=0;
lowdelta = 0.17;% peak time difference tolerance
% Actual selection of peaks
while i<=runend
%     if datasmr(i,1) < 1100
%         defaultcut = 0.26;
%         updelta = 0.25;
%         lowdelta =0.1;
%     elseif datasmr(i,1) > 1100 & datasmr(i,1)<1880
%         defaultcut = 0.26;
%         updelta = 0.25;
%         lowdelta =0.1;
%     elseif datasmr(i,1) >1880 & datasmr(i,1)<2900
%         defaultcut = 0.19;
%         updelta = 0.2;
%         lowdelta = 0.08;
%     elseif datasmr(i,1) >2900 & datasmr(i,1)<3300
%         defaultcut = 0.28;
%         updelta = 0.25;
%         lowdelta = 0.08;
%     else
%         defaultcut = 0.19;
%         updelta = 0.2;
%         lowdelta = 0.08;
%     end
    
    idxtemp = find((datapmt(1,:) - datasmr(i,1) - datasmr(i,12)/(2*3051.8)) < defaultcut + updelta & (datapmt(1,:)-datasmr(i,1)-datasmr(i,12)/(2*3051.8)) > defaultcut - lowdelta);
    if numel(idxtemp)>1
        idxtemp1=find(min(abs(datapmt(1,idxtemp)-datasmr(i,1)-datasmr(i,12)/(2*3051.8)-0.27)));
        idxtemp(idxtemp1)
        idxtemp2 = setxor(idxtemp, idxtemp(idxtemp1))
       	pair_data(iPair, 1)=datasmr(i,1); % SMR time
        pair_data(iPair, 2)=datasmr(i,3); %smr height
        pair_data(iPair, 3)=datasmr(i,4); %smr baseline
      
        pair_data(iPair, 4)=datapmt(1,idxtemp(idxtemp1))-datasmr(i,1)-datasmr(i,12)/(2*3051.8); %time difference between two peaks
        
        pair_data(iPair, 5)=datapmt(2,idxtemp(idxtemp1)); % pmt1 peak height
        pair_data(iPair, 6)=datafullpmt2(2, idxtemp(idxtemp1)); % pmt2 peak height
        pair_data(iPair, 7)=datafullpmt3(2, idxtemp(idxtemp1)); % pmt3 peak height
        pair_data(iPair, 8)=datapmt(4,idxtemp(idxtemp1)); %pmt1 baseline
        pair_data(iPair, 9)=datafullpmt2(4, idxtemp(idxtemp1)); % pmt2 baseline
        pair_data(iPair, 10) = datafullpmt2(4, idxtemp(idxtemp1));%pmt3 baseline 
        pair_data(iPair, 11) = idxtemp(idxtemp1);
        pair_data(iPair, 12) = datasmr(i,3)*calJ; %peak height in 'pg'
        iPair=iPair+1;
        i=i+1;
        j=j+1; %this is something that we track of double counts.
        display(' '); display('double count detected');
        fprintf('pmt1 heigth 1:  %2.4f, pmt height 2: %2.4f', datapmt(2,idxtemp(idxtemp1)), datapmt(2, idxtemp2)); display(' ');
        fprintf('pmt2 height 2: %2.4f, pmt height 2: %2.4f', datafullpmt2(2,idxtemp(idxtemp1)), datafullpmt2(2, idxtemp2));
        display(' '); fprintf('number of pmt peaks in this range are: %2.0f ', length(idxtemp));
        
        
    elseif numel(idxtemp)==0; %when there isn't any match
        i=i+1;
        
    else
        pair_data(iPair, 1)=datasmr(i,1); %pair number
        pair_data(iPair, 2)=datasmr(i,3); %smr height
        pair_data(iPair, 3)=datasmr(i,4); %smr baseline
        
        pair_data(iPair, 4)=datapmt(1,idxtemp)-datasmr(i,1)-datasmr(i,12)/(2*3051.8); %time difference between two peaks
        
        pair_data(iPair, 5)=datapmt(2,idxtemp); %pmt height
        pair_data(iPair, 6)=datafullpmt2(2,idxtemp);
        pair_data(iPair, 7)=datafullpmt3(2, idxtemp);
        pair_data(iPair, 8)=datapmt(4,idxtemp);
        pair_data(iPair, 9)=datafullpmt2(4,idxtemp);
        pair_data(iPair, 10) = datafullpmt3(4,idxtemp);%pmt height 3
        pair_data(iPair, 11) = 0; %this is later to find double peaks.
        pair_data(iPair, 12)=datasmr(i,3)*calJ; %Peak in 'pg'
        iPair=iPair+1;
        i=i+1;
        
    end
        
%     


        
        
   
end
disp(' ')
fprintf('total number of double counts were: %2.0f', j);
disp(' ')

pair_data(:,13) = pair_data(:,1)/3600; %time in hours
pair_data(:,14) = pair_data(:,5)./pair_data(:,2); %TMRE/mass
end




% Columns should read (09/15/2016 edit)
% 1: smr time
% 2: smr height
% 3: smr baseline
% 4: time difference
% 5: pmt1 peak height
% 6: pmt2 peak height
% 7: pmt3 peak height
% 8: pmt1 baseline
% 9: pmt2 baseline
% 10: pmt3 baseline
% 11: index of closest pmt peak in case of dobule peak detected.

