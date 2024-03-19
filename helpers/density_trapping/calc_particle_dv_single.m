function [density_gcm3, volume_fl] = calc_particle_dv_single(fwd_cand_data, back_cand_data, ...
    fl1_ref_freq, fl2_ref_freq, intercept, slope, mass_cal_factor)

bl1_avg = fwd_cand_data.avg_baseline;
fwd_cand_data.bl_dens_gcm3 = (fl1_ref_freq - bl1_avg - intercept) / slope; 
bl1_density = fwd_cand_data.bl_dens_gcm3;

bl2_avg = back_cand_data.avg_baseline;
back_cand_data.bl_dens_gcm3 = (fl2_ref_freq - bl2_avg - intercept) / slope; 
bl2_density = back_cand_data.bl_dens_gcm3;

fl1_avg_freq = fwd_cand_data.avg_pk_ht_hz;
fl2_avg_freq = back_cand_data.avg_pk_ht_hz;

density_gcm3 = ...
    (bl2_density .* fl1_avg_freq + bl1_density .* -fl2_avg_freq) ./ ...
    (fl1_avg_freq - fl2_avg_freq);
volume_fl = ...
    mass_cal_factor * (fl1_avg_freq - fl2_avg_freq) ./ ...
    (bl2_density - bl1_density); 
end