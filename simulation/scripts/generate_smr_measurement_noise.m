function noise_term = generate_smr_measurement_noise(total_datapoints)
% Compiles segments of empirical data to simulate SMR baseline noise
% 
% Arguments:
%   total_datapoints (int): total number of datapoints to be
%       simulated/number of datapoints of baseline required to be simulated
% Returns:
%   noise_term (array): array of compiled noise

%% Constants
min_sg_sz = 1e3;
max_seg_sz = 1e4;
baseline_dir_data = "A:\thomasu\simulations\baseline_data_for_sims";

%% Assemble baseline from empirical data segments
files = dir(baseline_dir_data);
contents = {files(~[files.isdir]).name};
contents = contents(~ismember(contents ,{'.','..'}));

collected_bl_data = cell(size(contents));
for i = 1:length(contents)
    st = load(fullfile(baseline_dir_data, contents{i}));
    collected_bl_data{i} = st.data;
end

noise_term = zeros(total_datapoints + max_seg_sz, 1);
flag = 0;
stored_idx = 1;
while ~flag
    f = collected_bl_data{randi(length(collected_bl_data))};

    start_sl = randi(length(f) - max_seg_sz);
    end_sl = randi([start_sl + min_sg_sz, start_sl + max_seg_sz]);

    noise_term(stored_idx:stored_idx + end_sl - start_sl) = f(start_sl:end_sl);
    stored_idx = stored_idx + end_sl - start_sl + 1;
    
    if stored_idx - 1 > total_datapoints
        flag = 1;
    end
end

noise_term = noise_term(1:total_datapoints);
end