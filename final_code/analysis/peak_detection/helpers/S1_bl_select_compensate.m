function run_params = S1_bl_select_compensate(run_params, estimated_noise, ...
    estimated_datapoints)
% Given input run parameters for baseline filtering, compensates for the
% estimated transit time (in datapoints) of a particle and the estimated
% level (roughly) of baseline noise
%
% Arguments:
%   run_params (struct): running parameters for analysis
%   estimated_noise (double): rough level of baseline noise
%   estimated_datapoints (double): estimated number of datapoints taken for
%       a particle to transit
% Returns:
%   run_params (struct): running parameters for analysis, with baseline
%       filtering parameters modified to compensate for noise/transit time

diff_threshold = run_params.bl_select.diff_threshold;
med_filt_wd = run_params.bl_select.med_filt_wd;
bs_dev_thres = run_params.bl_select.bs_dev_thres;
unqPeakDist = run_params.bl_select.unqPeakDist;
offset_input = run_params.bl_select.offset_input;

diff_threshold = diff_threshold * ((estimated_noise / 0.1)^(1/2)) / ...
    (estimated_datapoints / 400);
med_filt_wd = round(med_filt_wd * estimated_datapoints / 400);
bs_dev_thres = bs_dev_thres * ((estimated_noise / 0.1)^(1/2));
unqPeakDist = round(unqPeakDist * estimated_datapoints / 400);

run_params.bl_select.diff_threshold = diff_threshold;
run_params.bl_select.med_filt_wd = med_filt_wd;
run_params.bl_select.bs_dev_thres = bs_dev_thres;
run_params.bl_select.unqPeakDist = unqPeakDist;
run_params.bl_select.offset_input = offset_input;

end

