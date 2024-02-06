function [curated, dataidx] = curation_handler(run_params, pass_struct, summary_pks, ...
    save_abs_path, file_name, save_file)
% Runs curation routine for multiple analysis types given output from
% peakset detection
%
% Arguments:
%   run_params (struct): running parameters for analysis
%   pass_struct (struct): peak attributes passed through iterations of peak
%       detection 
%   summary_pks (array(double)): peakset summary array
%   save_abs_path (str): absolute path for saving files
%   file_name (str): filename for peakset summary file
%   save_file (bool): whether or not to save peakset summary

disp('Performing data curation...')

samplepeak = pass_struct.samplepeak;
sampletime = pass_struct.sampletime;
sample_baseline_fits = pass_struct.sample_baseline_fits;

if run_params.prefs.manual_curation
    [curated, dataidx] = manual_pk_curation(run_params, samplepeak, ...
        sampletime, sample_baseline_fits, summary_pks);
else
    if run_params.curation.auto_rejection
        % Despite no manual curation, still auto-reject peaks
        idx_discard = auto_discard_peaks(run_params, run_params.curation, summary_pks);
        curated = summary_pks(setdiff(1:size(summary_pks, 1), idx_discard), :);
        dataidx = setdiff(1:size(summary_pks, 1), idx_discard);
    else
        curated = summary_pks;
        dataidx = 1:size(summary_pks, 1);
    end
end

if save_file
    writetable(curated, fullfile(save_abs_path, file_name))
end

end

