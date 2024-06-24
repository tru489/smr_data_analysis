addpath(genpath("..\..\helpers"))
close all

pth = "A:\thomasu\simulations\baseline_data_for_sims";
fnames = ls(pth);

cell_sl = {...
    {1:10360000, 11000000:17000000, 20000000:76860000}, ...
    {1:8505200}, ...
    {1:36112000}, ...
    {1:11608000, 16618000:27312000, 27320000:34370000, 34500000:36500000}, ...
    {100:27058000}, ...
    {1:31707900}...
    };

emp_seg_cell = cell(11, 1); counter = 1;
for i = 1:length(fnames)
    cell_sl_i = cell_sl{i};
    f_handle = fopen(fnames{i}, 'r', 'b');
    freq = fread(f_handle, 'float64=>double');
    for j = 1:length(cell_sl_i)
        emp_seg_cell{counter} = freq(cell_sl_i{j});
        counter = counter + 1;
    end
end

save_pth = "A:\thomasu\simulations\baseline_segs_saved.mat";
save(save_pth, "emp_seg_cell")