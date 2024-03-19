function analysis_name = get_analysis_type(run_params)
% Gets the name of the analysis type for the analysis being run
% 
% Arguments:
%   run_params (struct): running parameters for analysis
% Returns:
%   analysis_name (str): name of analysis being run

fields = fieldnames(run_params.analysis_type);
for i = 1:length(fields)
    if run_params.analysis_type.(fields{i})
        analysis_name = fields{i};
        break;
    end
end

end

