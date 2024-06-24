function bl_gen = generate_bl_for_sims(bl_length, block_size)
%GENERATE_BL_FOR_SIMS Summary of this function goes here
%   Detailed explanation goes here

st = load("A:\thomasu\simulations\baseline_segs_saved.mat");
emp_seg_cell = st.emp_seg_cell;

bl_gen = zeros(ceil(bl_length / block_size) * block_size, 1);
for i = 1:ceil(bl_length / block_size)
    chosen_bl = emp_seg_cell{randi(length(emp_seg_cell))};
    bl_start = randi(length(chosen_bl)-block_size-1);
    bl_gen(block_size*(i-1)+1:block_size*(i)) = chosen_bl(bl_start:bl_start+block_size-1);
end
bl_gen = bl_gen(1:bl_length);

end

