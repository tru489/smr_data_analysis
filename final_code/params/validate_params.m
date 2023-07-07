function validate_params(run_params)
% Validate input parameters into 
% 
% Arguments: 
%   run_params (struct): all parameters necessary for running
%       preprocessing scripts

%% Validate analysis type parameters
analysis_type_fields = fieldnames(run_params.analysis_type);
logical_sum = 0;
for i = 1:length(analysis_type_fields)
    fld = run_params.analysis_type.(analysis_type_fields{i});
    logical_sum = logical_sum + fld;
end
if fld ~= 1
    error("ValueError: More than one analysis type selected.")
end

end

