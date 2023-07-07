%%%=============== Code for fitting Coulter Volume ==========

minV = 200;
maxV = 4000;

idx = find(coulter(:,1)>minV & coulter(:,1)<maxV);
dataC = coulter(idx,:);

x = log(dataC(:,1)); y=dataC(:,2);
hold off; plot(x,y); hold on;
f = fit(x,y,'gauss1');
plot(f,x,y);
display(' ');
fprintf('fitted mean Volume is: %3.2f', exp(f.b1)); disp(' ');
%===============Code for fitting BM SMR measurement============

minlogBM = 2.5;
maxlogBM = 6.5;
numbin = 40;

bin = linspace(minlogBM, maxlogBM, numbin);
h = hist(log(bm), bin);


hold off; plot(bin,h); hold on;
f = fit(bin', h', 'gauss1');
plot(f,bin,h);
display(' ');
fprintf('fitted BM value is: %2.2f', exp(f.b1));display(' ');
fprintf('median BM value is: %2.2f', median(bm)); display(' ');
sigma = std(log(bm));
lowbound = exp(f.b1 - 2*sigma);
highbound = exp(f.b1 + 2*sigma);
fprintf('low bound is %2.2f and high bound is %2.2f', lowbound, highbound); display(' ');
