%
%                           Simulation code v17
%
% Description: This code calculates the resonance frequency change induced
% by a single particle (cell or organoid) being repeatedly measured in
% H2O, 35%Optiprep and D20.
%
% Last edited by: Georgios 'Yorgos' Katsikis, katsikis.g@gmail.com
% Last edited on: Friday September 1st, 2023
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                       Inputs to simulations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
clear all;
clc;
close all;
format long;
%
% 1. Define input parameters
CIC=8000;           % CIC rate
Fs=10^8/CIC;        % sampling rate
bw_Hz_vector=80; bw=bw_Hz_vector; f_lowpass=bw_Hz_vector; %define bandwidth
rng(1);             % define random number generator (fixed value, yields same stochastic numbers)
noise_level=0.022; % standard deviation sigma of noise in (Hz)
alpha_factor=1;     % decay factor of noise (alpha_factor=0 for white noise, 1 for pink, 2 for brown and 1-2 colored)
%
% 2. Define type of simulation
type_of_computer='PC';             % either you put 'mac' or 'PC'
type_of_resonator='single-clamped'; % either you put 'double-clamped' (steel tube) or 'single-clamped' (steel tube)
include_slopescurves=1;             % includes slope and curvature on baseline
include_peaks=1;                    % includes peaks
apply_low_pass=1;                   % applies bandwith as low-pass filter on signal (Hz)
do_plot_simulated_signal=1;         % pause in between simulated experiments to show result
plotting_step=100;                  % define plotting step for visualization
%
% 3. Define Cantilever properties
channel_height_m=600*10^-6;
fo_Hz=3*10^4;
dc_o=800*10^-6;
dc_i=600*10^-6;
L_cant=60*10^-3;
density_s_kgm3=7850;
mode_number=2; %(up to mode #4 for single-clamped, up to mode #9 for double-clamped, )
% 
% 4. Define fluid properties
f_baseline=[3.01112 2.99622 2.99857]*10^4;
density_fluid_kgm3=[1037.8 1141.8 1131.3];
dyn_visc=8.891*10^-4;
%
% 5. Define duration of given peaks and intervals between peaks
Dt_before=2;
Dt_after=2;
Dt_sec_vector=1.5;
%
% 6 Define number of peaks for every one of three fluids
N_peaks=[40 40 40];
%
% 7. Define number of simulations and different radii
N_radii=11;
ds_um_min=450;
ds_um_max=480;
rs_m_vector=linspace(ds_um_min/2,ds_um_max/2,N_radii)*10^-6;
%
% 8. Define slopes and curvatures of baselines
mean_slope=3.4;
std_slope=18.7;
mean_curvature=111.5;
std_curvature=343.3;
%
% 9. Define cell properties
%
density_dry_kgm3=1409;      
rw_vv=0.8963;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                       Intermediate calculations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
Dt_sec=Dt_sec_vector;
number_points=round(Dt_sec*Fs);                  % number of points per peak
Dt_ABC=Dt_before+Dt_sec_vector+Dt_after;
N_peaks_add=[sum(N_peaks(1)) sum(N_peaks(1:2)) sum(N_peaks(1:3))];
N_total=sum(N_peaks);
Dt_total=N_total*Dt_ABC;
N_points=Dt_total*Fs;
pg_to_kg=10^-15;
if strcmp(type_of_computer,'Mac')==1
    slash_symbol='/';
elseif strcmp(type_of_computer,'PC')==1
    slash_symbol='\';
else
    disp('type of computer symbol should be Mac or PC')
    return
end
if strcmp(type_of_resonator,'double-clamped')==1
    m_eff_fraction=0.437188981509407;
elseif strcmp(type_of_resonator,'single-clamped')==1
    m_eff_fraction=0.25;
else
    disp('type of resonator needs to be either single-clamped or double-clamped')
    return
end
curvature = normrnd(mean_curvature,std_curvature,[1,N_total]);
slope = normrnd(mean_slope,std_slope,[1,N_total]);
current_path_full = matlab.desktop.editor.getActiveFilename; % finds folder where file is
idcs = strfind(current_path_full, filesep);
working_folder = current_path_full(1:idcs(end));
cd(working_folder)  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                       Simulations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
for k=1:length(rs_m_vector);
    disp(strcat('Progress (%)=',num2str(k/length(rs_m_vector)*100)))
%
    Colornoise_2=dsp.ColoredNoise(alpha_factor,N_points,'OutputDataType','double');
    target_noise_Hz=noise_level;
    noise_term=Colornoise_2()'/std(Colornoise_2()')*noise_level;
    %
    % assign frequencies
    Df=zeros(1,N_points);
    Dt=linspace(0,Dt_total,N_points);
    %
    for j=1:length(f_baseline)
        t_start=Dt_ABC*sum(N_peaks(1:j-1)); compare=abs(Dt-t_start); i_start=find(compare==min(compare));
        t_end=Dt_ABC*sum(N_peaks(1:j));   compare=abs(Dt-t_end);     i_end=find(compare==min(compare));
        Df(i_start:i_end)=f_baseline(j);
    end

    for i=1:N_total
        disp(strcat('Current simulation:',num2str(round(100*i/N_total)),'% complete'))
    
        t_start=Dt_after+(i-1)*Dt_ABC; compare=abs(Dt-t_start); i_start=find(compare==min(compare));
        t_end=t_start+Dt_sec_vector;   compare=abs(Dt-t_end);     i_end=find(compare==min(compare));
        t_start_baseline=t_start-0.250000000000000*3; compare=abs(Dt-t_start_baseline); i_start_baseline=find(compare==min(compare));
        t_end_baseline=t_end+0.250000000000000*5; compare=abs(Dt-t_end_baseline); i_end_baseline=find(compare==min(compare));
        t_start_bs_vector(i)=t_start_baseline;
        t_end_bs_vector(i)=t_end_baseline;
        
        % curvature values
        curvature_peak(i)=curvature(i);
        slope_peak(i)=slope(i)-2*curvature(i)*t_start_baseline/60;
        intercept_peak(i)=0*Df(i_start)-(curvature_peak(i)*(t_start_baseline/60)^2+slope_peak(i)*(t_start_baseline/60))*1;
        %
        rs_m=rs_m_vector(k);
        particle_volume_m3=(1/6*pi*(2*rs_m)^3);
        %
        density_w_kgm3=density_fluid_kgm3(1);
        particle_water_volume_m3=rw_vv*particle_volume_m3;
        particle_dry_volume_m3=particle_volume_m3-particle_water_volume_m3;
        r_dry_m=(3*particle_dry_volume_m3/4/pi)^(1/3);
        particle_dry_mass_pg=density_dry_kgm3*particle_dry_volume_m3/pg_to_kg;
        density_t_kgm3=density_dry_kgm3*(1-rw_vv)+density_w_kgm3*rw_vv;
        density_b_kgm3=density_t_kgm3;
        %
        %
        if i<=N_peaks_add(1)
            density_w_kgm3=density_fluid_kgm3(1);
            Dm_pg=(density_b_kgm3-density_w_kgm3)*particle_volume_m3/pg_to_kg;
            fo_Hz=f_baseline(1);
            density_current_kgm3=density_b_kgm3;
            r_active_m=rs_m;
        elseif i>N_peaks_add(1) && i<=N_peaks_add(2)
            density_w_kgm3=density_fluid_kgm3(2) ;  
            Dm_pg=(density_b_kgm3-density_w_kgm3)*particle_volume_m3/pg_to_kg;
            fo_Hz=f_baseline(2);
            density_current_kgm3=density_b_kgm3;
            r_active_m=rs_m;
        elseif i>N_peaks_add(2) && i<=N_peaks_add(3)
            density_w_kgm3=density_fluid_kgm3(3);
            density_b3_kgm3=density_dry_kgm3*(1-rw_vv)+density_w_kgm3*rw_vv;
            Dm_pg=(density_b3_kgm3-density_w_kgm3)*particle_volume_m3/pg_to_kg;
            fo_Hz=f_baseline(3);
            density_current_kgm3=density_b3_kgm3;
            r_active_m=r_dry_m;
        else
            disp('error')
            return
        end
        
        % effective mass
        m_capillary_kg=density_s_kgm3*L_cant*0.25*pi*(dc_o^2-dc_i^2)+density_w_kgm3*L_cant*pi*0.25*dc_i^2;
        m_eff_theoretical_kg=m_eff_fraction*m_capillary_kg;
        meff_kg=m_eff_theoretical_kg;
        meff_pg=m_eff_theoretical_kg/pg_to_kg;
        
        particle_volume_m3=(1/6*pi*(2*rs_m)^3);
        ab=ab_value(fo_Hz,r_active_m,dyn_visc,density_current_kgm3,density_w_kgm3);
        [ad,Reynolds_water_height]=ad_value(fo_Hz,rs_m,dyn_visc,channel_height_m,density_w_kgm3);
        [u,x,dudx] = U_n(1,mode_number,number_points,type_of_resonator);
        x_calc=x;
        Dt_point=Dt_sec/number_points;
    
        Dt_peak=t_start+x_calc*Dt_point*number_points;
        Dt_baseline=Dt(i_start_baseline:i_end_baseline);
    
    
        Df_disp=-0.5*ab*u.^2*Dm_pg/meff_pg*fo_Hz;
        Df_anti(i)=max(abs(Df_disp));
        % if i==100
        % min(Df_disp)
        % max(Df_disp)
        % return
        % end
        V_dimensionless=(density_w_kgm3*particle_volume_m3^(5/3))/(2*((6*pi^2)^(1/3))*meff_pg*pg_to_kg);
        Df_rot=-fo_Hz*ad*V_dimensionless*dudx.^2/L_cant^2;
        Df_peak=Df_disp+0.2*Df_rot;
        Df_cs=curvature_peak(i)*(Dt_baseline/60).^2+slope_peak(i)*(Dt_baseline/60)+intercept_peak(i);
        Df(i_start_baseline:i_end_baseline)=Df(i_start_baseline:i_end_baseline)+include_slopescurves*Df_cs;
        % Df_end_slope=2*curvature_peak(i)*(Dt_baseline(end)/60)+slope_peak(i)/60;
        % Df_end_curvature=2*curvature_peak(i)/60;
        %return
        Df(i_start:length(Df_peak)+i_start-1)=Df(i_start:length(Df_peak)+i_start-1)+include_peaks*Df_peak;
        Dt(i_start:length(Df_peak)+i_start-1)=Dt_peak;
        % Correct baseline before
        if i>1
            %
            % assign time points
            t1=t_end_bs_vector(i-1)-0.25;  compare=abs(Dt-t1); i_t1=find(compare==min(compare));   
            t2=t_end_bs_vector(i-1);       compare=abs(Dt-t2); i_t2=find(compare==min(compare));
            t3=t_start_bs_vector(i);       compare=abs(Dt-t3); i_t3=find(compare==min(compare));
            t4=t_start_bs_vector(i)+0.25;  compare=abs(Dt-t4); i_t4=find(compare==min(compare));  
            %
            % assign p
            Dt_fit=Dt(i_t1:i_t4);
            x_cs=[Dt(i_t1) Dt(i_t2) Dt(i_t3) Dt(i_t4)];
            y_cs=[Df(i_t1) Df(i_t2) Df(i_t3) Df(i_t4)];
            [p,S] = polyfit(x_cs,y_cs,3);
            Df_fit= polyval(p,Dt_fit);
            %plot(Dt_fit,y_fit,'-r'); hold on;
            Df(i_t1:i_t4)=Df_fit;
        end
        if do_plot_simulated_signal==1
            plot(Dt(i_start:length(Df_peak)+i_start-1),Df(i_start:length(Df_peak)+i_start-1),'-r'); hold on
        end
    end
    % add noise term
    Df=Df+noise_term;
    if apply_low_pass==1
        Df = lowpass(Df,f_lowpass,Fs);
    end

    if apply_low_pass==1
        if include_slopescurves==1
            traces_folder=strcat(working_folder,'Simulated Frequency signals_noise_std',num2str(target_noise_Hz));
        else
            traces_folder=strcat(working_folder,'Simulated Frequency signals_noise_std',num2str(target_noise_Hz),'no_slopecurvature');    
        end
    else   
        if include_slopescurves==1
            traces_folder=strcat(working_folder,'Simulated Frequency signals_noise_std',num2str(target_noise_Hz),'no_lowpass');
        else
            traces_folder=strcat(working_folder,'Simulated Frequency signals_noise_std',num2str(target_noise_Hz),'no_lowpass,no_slopecurvature');    
        end    
    end
    mkdir(traces_folder)
    save(strcat(traces_folder,slash_symbol,'DfDt_',num2str(k),'.mat'),'Dt','Df','rs_m','density_b_kgm3','rw_vv','density_dry_kgm3','Df_anti')
    
    if do_plot_simulated_signal==1
        plot(Dt(1:plotting_step:end),Df(1:plotting_step:end),'-b'); hold on
        xlabel('time (sec)')
        ylabel('frequency (Hz)')
        title(strcat('Press ENTER to continue | diameter=',num2str(2*10^6*rs_m_vector(k)),'\mum'))
        set(gca,'ylim',[0.9*min(f_baseline) 1.1*max(f_baseline)])
        pause
        close
    end
end
return
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                       functions inside code
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [u,x,dudx] = U_n(L_cant,n,number_points,type_of_resonator)
% n is the mode number (currently works for 1-9)

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
        for i=1:length(x)
        u(i)=u_func(x(i),L,lambda);
        dudx(i)=dudx_func(x(i),L,lambda);
        end
        x=linspace(0,L_cant,number_points);
    else
        disp('type of resonator should be singled-clamped or double-clamped')
        return
    end
end

function [ad_corr,Reynolds_water_height]=ad_value(f,rs,dyn_visc,channel_height,density_water)
    Reynolds_water=density_water*2*pi*f*(1*rs)^2/dyn_visc;
    Reynolds_water_height=density_water*2*pi*f*(1*channel_height)^2/dyn_visc;
    lambda=(1-1i)*sqrt(Reynolds_water/2);
    lambda_f=(1-1i)*sqrt(Reynolds_water_height/2);
    %
    ad_corr=real((15+15*lambda+6*lambda^2+lambda^3)/(3*lambda^2+3*lambda^3)*(2-1*lambda_f*cosh(0.0*lambda_f)/sinh(lambda_f/2)))/(2/3);
end

function [ab_corr]=ab_value(f,rs,dyn_visc,density_bead,density_water)
    Reynolds_water=density_water*2*pi*f*rs^2/dyn_visc;
    gamma=density_bead/density_water;
    lambda=(1-1i)*sqrt(Reynolds_water/2);
    %
    ab_corr=real((1+lambda+(1/3)*lambda^2)/(1+lambda+(2*gamma+1)/9*lambda^2));
end

