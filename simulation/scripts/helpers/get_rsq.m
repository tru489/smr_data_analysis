function Rsq = get_rsq(y, y_fit)
% Gets r-squared value from polyfit
SStot = sum((y-mean(y)).^2);
SSres = sum((y-y_fit).^2);
Rsq = 1-SSres/SStot;
end

