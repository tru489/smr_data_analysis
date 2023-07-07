

global samplepeak
global sampletime
global sidelength
global datasmr

idx=[]; dataidx=[];
idx0 = find(samplepeak==1e3);
Peak.count = length(idx0);


Peak.start = zeros(1,Peak.count);

Peak.start(1)=1;
j=0;
display(' ');
display('            REVIEW accepted peaks!        ' )


for j=2:Peak.count
    Peak.start(j)=idx0(j-1)+3; %% samplepeak looks like [(..data...), 1000, pkorder, sectionnumber, (...data...) ,1000, pkorder, sectionnumber ...]
end

for j=1:Peak.count
    Peak.peakorder(j)=samplepeak(idx0(j)+1);
end

for j=1:Peak.count
    Peak.sectnum(j)=samplepeak(idx0(j)+2);
end

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
    
    
    while ~skip && ~exit_flag
        
        if i==Peak.count %end peak
            peak = samplepeak(Peak.start(i):idx0(end)-1);
            time = sampletime(Peak.start(i):idx0(end)-1);
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
          if Peak.process(i)==1
          plot(time, peak); display(' ');fprintf('peak #%d:   peak order:%d     section number:%d', i, Peak.peakorder(i), Peak.sectnum(i)); 
          display(' ' ); 
          skip = 1; input('go?');
          else
              skip=1;
          end
          
    end
end;
