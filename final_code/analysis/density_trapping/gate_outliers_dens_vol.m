function paired_data = gate_outliers_dens_vol(paired_data)
% Gate out density and volume from paired data summary table and slice out
% outlier rows
%
% Arguments:
%   paired_data (table): paired data, including volume and density
%       information
% Returns:
%   paired_data (table): paired data with removed outliers

vol_fig = figure;
histogram(paired_data.volume_fl, 'NumBins', 50)
xlabel('Volume (fl)', 'FontSize', 12)
ylabel('Count', 'FontSize', 12)

disp('Select left and right boundaries...')
[vol_gate, ~] = ginput(2);
if vol_gate(1) > vol_gate(2)
    vol_gate = vol_gate(end:-1:1);
end
close(vol_fig)

dens_fig = figure;
histogram(paired_data.density_gcm3, 'NumBins', 50)
xlabel('Density (g/cm^3)', 'FontSize', 12)
ylabel('Count', 'FontSize', 12)

disp('Select left and right boundaries...')
[dens_gate, ~] = ginput(2);
if dens_gate(1) > dens_gate(2)
    dens_gate = dens_gate(end:-1:1);
end
close(dens_fig)

gated_vol = volume_fl > vol_gate(1) & volume_fl < vol_gate(2);
gated_dens = density_gcm3 > dens_gate(1) & density_gcm3 < dens_gate(2);
paired_data = paired_data(gated_vol & gated_dens, :);

end

