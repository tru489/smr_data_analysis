

edges = [25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 115, 120, 125, 130, 135, 140, 150, 250];

data_summary(:,4) = data_summary(:,3)./data_summary(:,2);
idx = find(data_summary(:,4)>0.0012);
data_summary = data_summary(idx,:);

[B, I] = sort(data_summary(:,2));
data_sort = data_summary(I, :);

h= histogram(data_sort(:,2), edges);
data_hist = zeros(length(edges), 4);

edges = [0 edges];
for i=1:length(edges)-1
    tempidx = find(data_sort(:,2)>edges(i) & data_sort(:,2)<edges(i+1));
    data_hist(i,1) = edges(i+1);
    data_hist(i,2) = numel(tempidx);
    
    if isempty(tempidx) ~=1 %not empty
        data_hist(i,3) = median(data_sort([tempidx],4));
        data_hist(i,4) = mean(data_sort([tempidx],4));
        data_hist(i,5) = std(data_sort([tempidx], 4));
    else
        data_hist(i,3) = 0;
        data_hist(i,4) = 0;
        data_hist(i,5) = 0;
    end
end



