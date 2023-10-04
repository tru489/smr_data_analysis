function [ad_corr, Reynolds_water_height] = ad_value(f, rs, dyn_visc, ...
    channel_height, density_water)
% Calculates ad value (correction value for node deviation)
%
% Arguments:
%   f (double): frequency baseline value
%   rs (double): particle radius
%   dyn_visc (double): fluid dynamic viscosity
%   channel_height (double): height of channel (m)
%   density_water (double): density of fluid (kg/m^3)
% Returns:
%   ad_corr (double): ad correction value
%   Reynolds_water_height (double): Reynolds number

Reynolds_water=density_water*2*pi*f*(1*rs)^2/dyn_visc;
Reynolds_water_height=density_water*2*pi*f*(1*channel_height)^2/dyn_visc;
lambda=(1-1i)*sqrt(Reynolds_water/2);
lambda_f=(1-1i)*sqrt(Reynolds_water_height/2);

ad_corr=real((15+15*lambda+6*lambda^2+lambda^3)/(3*lambda^2+3*lambda^3)*(2-1*lambda_f*cosh(0.0*lambda_f)/sinh(lambda_f/2)))/(2/3);

end