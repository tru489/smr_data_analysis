bm = test(:,3);
minlogBM = 2.5;
maxlogBM = 6;
numbin = 40;

bin = linspace(minlogBM, maxlogBM, numbin);
h = hist(log(bm), bin);

% 
% hold off; plot(bin,h); hold on;

% plot(f,bin,h);
% display(' ');
f = fit(bin', h', 'gauss1');
fprintf('fitted BM value is: %2.2f', exp(f.b1));display(' ');
fprintf('median BM value is: %2.2f', median(bm)); display(' ');
sigma = std(log(bm));
lowbound = exp(f.b1 - 2*sigma);
highbound = exp(f.b1 + 2*sigma);
fprintf('low bound is %2.2f and high bound is %2.2f', lowbound, highbound); display(' ');
idx = find(test(:,3)>lowbound & test(:,3)<highbound);
test2 = test(idx,:);

