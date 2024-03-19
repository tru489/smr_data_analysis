function paired_dv = ...
    calc_particle_dens_vol(paired_data, fl1_ref_freq, fl2_ref_freq, ...
    intercept, slope, mass_cal_factor)
% From relevant information, calculates particle density and volume and
% adds them to the paired particle summary table
%
% Arguments:
%   paired_data (table): paired data comprising data from paired particles
%   fl1_ref_freq (double): reference frequency for fluid 1
%   fl2_ref_freq (double): reference frequency for fluid 2
%   intercept (double): intercept for linear regression of density baseline
%       calibration
%   slope (double): slope for linear regression of density baseline calibration
%   mass_cal_factor (double): mass calibration factor (pg/Hz)
% Returns:
%   paired_dv (table): paired data containing single-cell density and
%       volume information

bl1_avg = paired_data.fl1_bl_avg_hz;
paired_data.fl1_bl_dens_gcm3 = (fl1_ref_freq - bl1_avg - intercept) / slope; 
bl1_density = paired_data.fl1_bl_dens_gcm3;

bl2_avg = paired_data.fl2_bl_avg_hz;
paired_data.fl2_bl_dens_gcm3 = (fl2_ref_freq - bl2_avg - intercept) / slope; 
bl2_density = paired_data.fl2_bl_dens_gcm3;

fl1_avg_freq = paired_data.fl1_avg_pk_ht_hz;
fl2_avg_freq = paired_data.fl2_avg_pk_ht_hz;

paired_data.density_gcm3 = ...
    (bl2_density .* fl1_avg_freq + bl1_density .* -fl2_avg_freq) ./ ...
    (fl1_avg_freq - fl2_avg_freq);
paired_data.volume_fl = ...
    mass_cal_factor * (fl1_avg_freq - fl2_avg_freq) ./ ...
    (bl2_density - bl1_density); 

paired_dv = paired_data;
end
