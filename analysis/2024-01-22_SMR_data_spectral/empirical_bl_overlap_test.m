close all;

save_path = "C:\thomasu\smr_data_analysis\analysis\2024-01-22_SMR_data_spectral\fig";

% Simulates reconstructing baseline from empirical results for simulations.
% Assumes that we are reconstructing baseline segments of size x from a
% bank of empirical baseline data of size bank_sz. From the bank, segments
% of data are randomly picked (a random starting index is picked, and the
% length is randomly picked from the interval [s_low, s_high]) and
% assembled to create the total array of size x. I calculate the average
% amount of overlap of these segments within each dataset, and the average
% amount of overlap between different datasets.

% fs = 1e4;
% bank_sz = 20 * fs * 3600;
% x = fs * 3600;
% s_low = 1e3; s_high = 1e4;
% iters = 100;

fs = 1e4;
bank_sz = 20 * fs * 3600;
% bank_sz_arr = (1:30) * fs * 3600;
x = fs * 3600;
s_low = 1e3; 
s_high = 1e4; 
% s_high_arr = linspace(1.1e3, 1e4, 30);
iters = 200;

n_pts = 30;
frac_inter_overlap = zeros(n_pts, 1);
frac_intra_overlap = zeros(n_pts, 1);
for i = 1:n_pts
    fprintf("Iter %i of %i...\n", i, n_pts)
    [inter_overlap, intra_overlap] = compute_overlap(bank_sz, x, s_low, s_high, iters, true);
    frac_inter_overlap(i) = mean(inter_overlap) / x;
    frac_intra_overlap(i) = mean(intra_overlap) / x;
end

f1 = figure; sc = scatter(bank_sz_arr / (fs * 3600), frac_inter_overlap * 100, 'filled'); 
sc.MarkerFaceAlpha = 0.6;
xlabel('Hours of reference baseline'); ylabel('Average percent overlap between datasets')
saveas(f1, fullfile(save_path, "vary_bank_length_inter.jpg"))

f2 = figure; sc = scatter(bank_sz_arr / (fs * 3600), frac_intra_overlap * 100, 'filled'); 
sc.MarkerFaceAlpha = 0.6;
xlabel('Hours of reference baseline'); ylabel('Average percent overlap within datasets')
saveas(f1, fullfile(save_path, "vary_bank_length_intra.jpg"))

%%
function [inter_overlap, intra_overlap] = compute_overlap(bank_sz, x, s_low, s_high, iters, verbose)
    segment_cell = cell(iters,1);
    intra_overlap = zeros(iters,1);
    for i = 1:iters
        if verbose
            fprintf("    Iter %i of %i...\n", i, iters)
        end
        [segments, dp_overlap] = sim_one_expt(bank_sz, x, s_low, s_high);
        segment_cell{i} = segments;
        intra_overlap(i) = dp_overlap;
    end
    
    inter_overlap = zeros(iters * (iters-1) / 2, 1);
    final_idx = 1;
    for j = 1:iters-1
        segment_1 = segment_cell{j};
        for k = j+1:iters
            segment_2 = segment_cell{k};
            seg_compiled = [segment_1; segment_2];
    
            [~, sort_idx] = sort(seg_compiled, 1);
            segments = seg_compiled(sort_idx(:, 1), :);
            dp_overlap = 0;
            for i = 1:size(segments, 1)-1
                if segments(i, 2) > segments(i+1, 1)
                    dp_overlap = dp_overlap + segments(i, 2) - segments(i+1, 1);
                end
            end
            inter_overlap(final_idx) = dp_overlap;
            final_idx = final_idx + 1;
        end
    end
    
    if verbose
        fprintf("Average overlap within datasets: %.04e / %.04e\n", mean(intra_overlap), x)
        fprintf("    Percent of data: %.04f%%\n", 100 * mean(intra_overlap) / x)
        fprintf("Average overlap between datasets: %.04e / %.04e\n", mean(inter_overlap), x)
        fprintf("    Percent of data: %.04f%%\n", 100 * mean(inter_overlap) / x)
    end
end


function [segments_compiled, dp_overlap] = sim_one_expt(bank_sz, x, s_low, s_high)
    flag = false;
    int_len_total = 0;
    segments = [];
    while ~flag
        start_idx = randi(bank_sz - s_high);
        int_len_temp = randi([s_low, s_high]);
        end_idx = start_idx + int_len_temp;
        segments = [segments; start_idx, end_idx];
        int_len_total  = int_len_total + int_len_temp;

        if int_len_total >= x
            flag = true;
        end
    end

    [~, sort_idx] = sort(segments, 1);
    segments = segments(sort_idx(:, 1), :);
    dp_overlap = 0;
    segments_compiled = segments;
    for i = 1:size(segments, 1)-1
        if segments(i, 2) > segments(i+1, 1)
            dp_overlap = dp_overlap + segments(i, 2) - segments(i+1, 1);
            segments_compiled(i+1, 1) = 0; segments_compiled(i, 2) = 0;
        end
    end

    segments_compiled(sum(segments_compiled, 2) == 0, :) = [];
    for j = 1:size(segments_compiled, 1)-1
        if segments_compiled(j, 2) == 0
            segments_compiled(j, 2) = segments_compiled(j+1, 2);
        end
    end
    segments_compiled(segments_compiled(:, 1) == 0, :) = [];
end