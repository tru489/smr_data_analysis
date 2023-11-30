function [ab_corr] = ab_value(f, rs, dyn_visc, density_bead, density_water)
% Calculates ab value for SMR signal simulation
%
% Arguments:
%   f (double): frequency baseline value
%   rs (double): particle radius
%   dyn_visc (double): fluid dynamic viscosity
%   density_bead (double): bead density
%   density_water (double): fluid density
% Returns:
%   ab_corr (double): ab correction value

Reynolds_water=density_water*2*pi*f*rs^2/dyn_visc;
gamma=density_bead/density_water;
lambda=(1-1i)*sqrt(Reynolds_water/2);

ab_corr=real((1+lambda+(1/3)*lambda^2)/(1+lambda+(2*gamma+1)/9*lambda^2));

end