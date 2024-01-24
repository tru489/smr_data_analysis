function noise_term = generate_smr_measurement_noise(total_datapoints)

baseline_dir_data = "C:\thomasu\smr_data_analysis\simulation\baseline_data";


min_sg_sz = 1e3;
max_seg_sz = 1e4;

noise_term = [];
flag = 0;
while ~flag
    


    start_sl = randi(length(f) - max_seg_sz);
    end_sl = randi([start_sl + min_sg_sz, start_sl + max_seg_sz]);

    noise_term = [noise_term; f(start_sl:end_sl)];
    
    if length(noise_term) > total_datapoints
        flag=1;
    end
end

end

