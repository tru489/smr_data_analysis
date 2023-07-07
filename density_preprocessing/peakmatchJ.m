function [pair_data]=peakmatchJ(data)
%Last edit in 11/17/2016

[b ix] = sort(data(:,2));
data=data(ix,:); %sort data by time


v1=11; %BM1; in media
v2=7; %BM2; in optiprep
calJ=0.596; %pg/hz



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
tcut=20;

if data(end,14)==v1
    runend=length(idxf)-1;
else
    runend=length(idxf);
end

runend

while i<=runend
    idxtemp_fw = find(abs(data(:,1) - data(idxf(i),1)) < tcut)
    if isempty(idxtemp_fw)
    
%     if data(idxf(i)+1,14)==v2 && data(idxf(i)+1,1)-data(idxf(i),1)<=tcut;
%         idxtemp=find(data(:,1)-data(idxf(i),1)>=0 & data(:,1)-data(idxf(i),1)<=tcut & data(:,13)==v2);
%         
%              idxp=i;
%             pair_data(iPair, 1)=iPair;
%             pair_data(iPair, 2:4)=data(idxf(i),2:4);
%             pair_data(iPair, 7:9)=data(idxf(i),6:8);
%             pair_data(iPair, 8)=data(idxf(i),5);
%             pair_data(iPair, 10:12)=data(idxf(i)+1,2:4);
%             pair_data(iPair, 15:17)=data(idxf(i)+1,6:8);
%             pair_data(iPair, 16)=data(idxf(i)+1,5);
%             iPair=iPair+1;
%             i=i+1;
% 
%             
%         else                  %%if there exist another valve 2 state within tcut
%             for j=1:length(idxtemp)
%                 if data(idxf(i)-length(idxtemp)+j,13)==v1 && data(idxf(i)+length(idxtemp)+1-j,1)-data(idxf(i)-length(idxtemp)+j,1)<=tcut
%                     
%                     pair_data(iPair, 1)=iPair;
%                     pair_data(iPair, 2:4)=data(idxf(i)-length(idxtemp)+j,2:4);
%                     pair_data(iPair, 7:9)=data(idxf(i)-length(idxtemp)+j,5:7);
%                     pair_data(iPair, 8)=data(idxf(i)-length(idxtemp)+j,8);
%                     pair_data(iPair, 10:12)=data(idxf(i)+length(idxtemp)-j+1,2:4);
%                     pair_data(iPair, 15:17)=data(idxf(i)+length(idxtemp)-j+1,5:7);
%                     pair_data(iPair, 16)=data(idxf(i)+length(idxtemp)-j+1,8);
%                     iPair=iPair+1;
%                      
% 
% 
% pair_data(iPair, 1)=iPair;
%                 pair_data(iPair, 2:4)=data(idxf(i),2:4);
%                 pair_data(iPair, 7:9)=data(idxf(i),5:7);
%                 pair_data(iPair, 8)=data(idxf(i),8);
%                 pair_data(iPair, 10:12)=data(idxf(i)+1,2:4);
%                 pair_data(iPair, 15:17)=data(idxf(i)+1,5:7);
%                 pair_data(iPair, 16)=data(idxf(i)+1,8);
%                 iPair=iPair+1;
%                 else
%                 end
%                 
%             end
%             i=i+1;
%         else
           
        
        
    else
        i=i+1;
    end
    
   
    
    
end

% sysnum = input('System Number? (sys1=1 , sys2=2):    ');
% disp(' ')


reffreq1 = input('Type in reference freq for BM1:    ');
disp(' ')
reffreq2 = input('Type in reference freq for BM2:     ');
disp(' ')

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

%here adjust the slow but consistent baseline drop
intercept = 1363096.3584;
slope = -192779.6601;
    
    pair_data(:,6)=(reffreq1+pair_data(:,4)-intercept)./slope; %baseline_1 density
    pair_data(:,14)=(reffreq2+pair_data(:,12)-intercept)./slope; %baseline_2 density
    
    pair_data(:,18)=(pair_data(:,14).*pair_data(:,3)+pair_data(:,6).*pair_data(:,11))./(pair_data(:,3)+pair_data(:,11));
    pair_data(:,19)=calJ*(pair_data(:,3)+pair_data(:,11))./(pair_data(:,14)-pair_data(:,6));
    pair_data(:,20)=pair_data(:,2)./60;


    
    
   openvar('pair_data');

end


   
        