

folder_name = uigetdir;
files = dir (fullfile(folder_name, '*.bmp'));
filename = {files.name};
filedate = [files.datenum];

[s,s] = sort(filedate);
filename = {files(s).name};
filedate = [files(s).datenum];


imagedata = {}; %store name and datenum relative to first image file
for i=1:numel(files)
    imagedata{i,1} = filename{i};
    imagedata{i,2} = (filedate(i) - filedate(1))*86400;
end

idx_f = find(datasmr(:,14)==9);
data_f = datasmr(idx_f,:);
data_f = [data_f zeros(size(data_f,1),2)];
pair_smrimage=num2cell(data_f);

t_cut = 20; %30s cutoff

for i=1:length(data_f)
    
    idxtemp = find(abs(cell2mat(imagedata(:,2)) - (data_f(i,1) - data_f(1,1))) < t_cut);
    if isempty(idxtemp) ~=1
    pair_smrimage{i,20} = imagedata{idxtemp,1};
    pair_smrimage{i,21} = imagedata{idxtemp,2};
    else
        pair_smrimage{i,20}= ' ';
        pair_smrimage{i,21}=0;
    end
    
end










% 
% disp(' ')
% disp('Getting image time stamp file...')
% [pmtfilepath1 pmtdir1 filind1] = uigetfile('../*.*','Select image log file',' ');
% if(filind1 == 0)
%     disp('Quitting analysis program now...')
%     return
% else
%     disp(' ')
%     fprintf('%s selected for analysis', pmtfilepath1)
%     disp(' ')
%     pmtfile1 = fopen(strcat(pmtdir1, pmtfilepath1), 'r', 'b');
% end
% i=0;
% 
% 
% n = 1;
% datasize = 1e6;   % establish a segment size (~32Mbytes)
% while(fseek(pmtfile1, n*8*datasize, 'bof') == 0)
%     % flip forward 8*datasize bytes repeatedly until file ends
%     n = n + 1;
% end   
% 
% num_segments = n - 1; % total number of seg
% 
% while(1)
%     
%     fseek(pmtfile1, i*8*datasize, 'bof');
%     
%     x1=[];
%     x1 = fread(pmtfile1, datasize, 'float64=>double');
%     
%     i=i+1;
%     
%      if length(x1) < datasize
%          break
%      end
% end
