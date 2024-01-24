close all;

st = load("C:\Users\Blue\Desktop\test\bl_noise_sample_final.mat");
f = st.full_data;

tgt_length = 39240000;
min_sg_sz = 1e3;

compiled_f = [];
flag = 0;
while ~flag
    start_sl = randi(length(f) - min_sg_sz);
    end_sl = randi([start_sl + min_sg_sz, length(f)]);

    compiled_f = [compiled_f; f(start_sl:end_sl)];
    
    if length(compiled_f) > tgt_length
        flag=1;
    end
end

figure; plot(compiled_f)
save("C:\Users\Blue\Desktop\test\bl_noise_compiled_final4.mat", "compiled_f")