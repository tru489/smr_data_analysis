function rsquare(x, y)

p = polyfit(x,y, 1)
yfit = polyval(p,x);

yresid = y - yfit;

SSresid = sum(yresid.^2);
SStotal = (length(y)-1) * var(y);
rsq = 1 - SSresid/SStotal
figure;
plot(x,y,'o');
hold on; plot(x, p(1)*x+p(2), 'r');


end