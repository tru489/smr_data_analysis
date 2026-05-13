function [u, x, dudx] = U_n(L_cant, n, number_points, type_of_resonator)
% Calculates psi function for given cantilever
%
% Arguments:
%   L_cant (double): cantilever length (m)
%   n (int): mode number (currently works for 1-9)
%   number_points (int): number of points to simulate
%   type_of_resonator (str): either set to "single-clamped" or
%       "double-clamped" specifying clamping of cantilever.
%       "single-clamped" for SMR
% Returns:
%   u (array(double)): frequency values for simulated signal
%   x (array(double)): x values for simulated signal
%   dudx (array(double)): derivative of frequency signal


if strcmp(type_of_resonator,'double-clamped')==1
    lambda_vector = [4.73004, 7.8532, 10.9952, 14.1372, 17.278759657399480, 20.420352245626059,23.561944902040455,26.703537555508188,29.845130209103253]; % eigenvalues 
    lambda=lambda_vector(n);
    %
    ab=(cosh(lambda)-cos(lambda))/(sin(lambda)+sinh(lambda));
    a=1;
    b=1/ab;
    lambda_s=lambda/L_cant;
    %
    x=linspace(0,L_cant,number_points);
    %
    for i=1:length(x)
    u(i)=a*(cosh(lambda_s*x(i))-cos(lambda_s*x(i)))+b*(sin(lambda_s*x(i))-sinh(lambda_s*x(i)));
    dudx(i)=a*(lambda_s*sinh(lambda_s*x(i))+lambda_s*sin(lambda_s*x(i)))+b*(lambda_s*cos(lambda_s*x(i))-lambda_s*cosh(lambda_s*x(i)));
    end
    %
    norm_u=max(u);
    u=u/norm_u;
    dudx=dudx/norm_u;
elseif strcmp(type_of_resonator,'single-clamped')==1
    %
    lambda_vector = [1.875, 4.694, 7.855, 10.996]; % eigenvalues 
    lambda=lambda_vector(n);
    L=L_cant;
    x=[linspace(0,L_cant,number_points/2) flip(linspace(0,L_cant,number_points/2))];
    u_func = @(x,L,lambda) ( (cosh(lambda*x/L) - cos(lambda*x/L)) - ((cosh(lambda)+cos(lambda))/(sinh(lambda)+sin(lambda))) * ...
    (sinh(lambda*x/L) - sin(lambda*x/L)))/(( (cosh(lambda) - cos(lambda)) - ((cosh(lambda)+cos(lambda))/(sinh(lambda)+sin(lambda))) * ...
    (sinh(lambda) - sin(lambda)))); % mode shape
    dudx_func=@(x,L,lambda) ((((lambda*cos((lambda*x)/L))/L - (lambda*cosh((lambda*x)/L))/L)*(cos(lambda) + cosh(lambda)))/(sin(lambda) + sinh(lambda)) + (lambda*sin((lambda*x)/L))/L + (lambda*sinh((lambda*x)/L))/L)/(cosh(lambda) - cos(lambda) + ((sin(lambda) - sinh(lambda))*(cos(lambda) + cosh(lambda)))/(sin(lambda) + sinh(lambda)));
    
    % Hack to fix stdev difference. FIX LATER
    L = L*1.05; disp('HALF PEAKWIDTH MANUALLY SCALED, FIX ME!!!!');
    
    for i=1:length(x)
        u(i)=u_func(x(i),L,lambda);
        dudx(i)=dudx_func(x(i),L,lambda);
        end
    x=linspace(0,L_cant,number_points);
else
    disp('type of resonator should be singled-clamped or double-clamped')
    return
end
