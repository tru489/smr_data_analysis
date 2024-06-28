close all;
addpath(genpath("..\..\helpers"));

drive_lett = "A";
search_path = drive_lett + ":\thomasu\raw_data\2024-03-19\dens_trap_fitting_gridsearch\data_cleaned.mat";
st = load(search_path);
data_cell = st.compiled_4d;

%% Calculation prefs
calc_fitting_order = 1;
calc_node_weight = 1;
calc_bl_fit_length = 1;
calc_bl_fit_offset = 1;

%% Setup
%-------------------------------------------
% Collect fns: dens error, dens cv, vol error, vol cv,
% (repeat each for avg+large-small, in that order), skew

collect_fn_cell = {...
    @(st) mean(st.dens_pct_err), ...
    @(st) st.dens_pct_err(1), ...
    @(st) st.dens_pct_err(2), ...
    @(st) st.dens_pct_err(3), ...
    @(st) mean(abs(st.dens_pct_err)), ...
    @(st) abs(st.dens_pct_err(1)), ...
    @(st) abs(st.dens_pct_err(2)), ...
    @(st) abs(st.dens_pct_err(3)), ...
    @(st) mean(st.dens_cv), ...
    @(st) st.dens_cv(1),...
    @(st) st.dens_cv(2),...
    @(st) st.dens_cv(3),...
    @(st) mean(st.vol_pct_err), ...
    @(st) st.vol_pct_err(1), ...
    @(st) st.vol_pct_err(2), ...
    @(st) st.vol_pct_err(3), ...
    @(st) mean(abs(st.vol_pct_err)), ...
    @(st) abs(st.vol_pct_err(1)), ...
    @(st) abs(st.vol_pct_err(2)), ...
    @(st) abs(st.vol_pct_err(3)), ...
    @(st) mean(st.vol_cv), ...
    @(st) st.vol_cv(1),...
    @(st) st.vol_cv(2),...
    @(st) st.vol_cv(3),...
    @(st) get_skew_slope(st.vol_mean, st.dens_mean)};
collect_fn_annot = [...
    "Average density error", ...
    "10um density error", "8um density error", "6um density error",...
    "Average density errorABS", ...
    "10um density errorABS", "8um density errorABS", "6um density errorABS",...
    "Average density CV", ...
    "10um density CV", "8um density CV", "6um density CV",...
    "Average volume error", ...
    "10um volume error", "8um volume error", "6um volume error",...
    "Average volume errorABS", ...
    "10um volume errorABS", "8um volume errorABS", "6um volume errorABS",...
    "Average volume CV", ...
    "10um volume CV", "8um volume CV", "6um volume CV",...
    "DV slope skew"];

metric_fns_cell = {...
    @(m) min(m,[],"all"),
    @(m) mean(m,"all")};
metric_fns_annot = ["slice min", "slice mean"];
%-------------------------------------------
% Parameter values
fitting_orders = 2:1:6; % order of polynomial fit of baseline
node_weights = 0:0.2:1; % weight of node points as a fraction of total peakset width
bl_fit_length = 0.25 * (0.5:1:7.5); % Length of baseline to fit as a fraction of 1/4 of the total peakset width
bl_fit_offset = 0:10:30; % Offset in datapoints between peak and baseline fitted area

%% Fitting order analysis
% Dimension order: fitting_order, node_weight, bl_fit_length, bl_fit_offset

if calc_fitting_order
    disp('Slicing across fitting order...')

    num_datapoints = size(data_cell, 1); % CHANGE ME!!!
    
    num_arranged_plots = floor(length(collect_fn_annot) / 4) * length(metric_fns_cell);
    arranged_arr = cellfun(@(x) zeros(4, num_datapoints), cell(num_arranged_plots,1), 'UniformOutput', false);
    test_arr = cell(12,4);

    % Fitting order search:
    fn_hand_dff = fullfact([length(collect_fn_cell), length(metric_fns_cell)]);
    fit_ord_search = zeros(length(collect_fn_cell) * length(metric_fns_cell), size(data_cell, 1));
    for i = 1:size(data_cell, 1)
        slice = squeeze(data_cell(i, :, :, :));
        for j = 1:size(fn_hand_dff, 1)
            collect_pick = collect_fn_cell(fn_hand_dff(j, 1));
            metric_pick = metric_fns_cell(fn_hand_dff(j, 2));
            fit_ord_search(j,i) = search_3d_slice(slice, collect_pick{1}, metric_pick{1});
            
            if j == 25 || j == 50
                continue
            end
            if j >= 25
                j_mod = j-1;
            else
                j_mod = j;
            end
            seg_idx = 1 + floor((j_mod-1)/4);
            sub_idx = 1 + mod(j_mod-1, 4);

            arranged_arr{seg_idx}(sub_idx, i) = fit_ord_search(j,i);
            test_arr{seg_idx, sub_idx} = collect_fn_annot(fn_hand_dff(j, 1)) + " | " + metric_fns_annot(fn_hand_dff(j, 2));
        end
    end
    
    % Plot results
    disp('  Plotting results...')
    for i = 1:(length(collect_fn_cell) * length(metric_fns_cell))
        fprintf('    %i of %i...\n', i, length(collect_fn_cell) * length(metric_fns_cell))
        
        fh = figure(Visible='off');
        s = scatter(fitting_orders, fit_ord_search(i, :), 30, 'blue', 'filled');
        s.MarkerFaceAlpha = 0.5;
        hold on; plot(fitting_orders, fit_ord_search(i, :), LineWidth=1.5, Color='blue')
        collect_fn_label = collect_fn_annot(fn_hand_dff(i, 1));
        metric_fn_label = metric_fns_annot(fn_hand_dff(i, 2));
        xlabel('Baseline fitting order'); ylabel(collect_fn_label + " | " + metric_fn_label);
        
        subfolder = regexp(collect_fn_label, '[a-z]*\s[a-zA-Z]*$', 'match');
        subfolder = regexprep(subfolder, '\s', '_');
    
        saveas(fh, "fig\fitting_order\" + string(subfolder) + "\" + collect_fn_label + "_" + metric_fn_label + ".jpg")
    end

    % Plot combined graph results
    collect_tags = ["density error", "density errorABS", "density CV", "volume error", "volume errorABS", "volume CV"];
    metr_tags = ["slice min", "slice mean"];
    legend_labels = ["Average of bead populations", "10 um beads", "8 um beads", "6 um beads"];
    colors_ = ["red", "blue", "magenta", "black"];

    for i = 1:length(arranged_arr)
        % Assign axis label
        if i <= 6
            ylabel_ = collect_tags(i) + " | " + metr_tags(1);
            fname = collect_tags(i) + "_" + metr_tags(1);
        else
            ylabel_ = collect_tags(i-6) + " | " + metr_tags(2);
            fname = collect_tags(i-6) + "_" + metr_tags(2);
        end
        
        data = arranged_arr{i};
        % fh = figure(Visible='off', Position=[2547 361 811 420]); hold on;
        fh = figure(Visible='off'); hold on;
        for j = 1:size(data, 1)
            s = scatter(fitting_orders, data(j, :), 30, colors_(j), 'filled', HandleVisibility='off');
            s.MarkerFaceAlpha = 0.5;
            plot(fitting_orders, data(j, :), LineWidth=1.5, Color=colors_(j), DisplayName=legend_labels(j))
        end
        xlabel('Baseline fitting order'); ylabel(ylabel_);
        % legend(Location='eastoutside')
        saveas(fh, "fig\fitting_order\" + fname + '_combined.jpg');
    end
end

%% Fitting order analysis
% Dimension order: fitting_order, node_weight, bl_fit_length, bl_fit_offset

if calc_node_weight
    disp('Slicing across fitting order...')

    num_datapoints = size(data_cell, 2); % CHANGE ME!!!
    
    num_arranged_plots = floor(length(collect_fn_annot) / 4) * length(metric_fns_cell);
    arranged_arr = cellfun(@(x) zeros(4, num_datapoints), cell(num_arranged_plots,1), 'UniformOutput', false);
    test_arr = cell(12,4);

    % Fitting order search:
    fn_hand_dff = fullfact([length(collect_fn_cell), length(metric_fns_cell)]);
    fit_ord_search = zeros(length(collect_fn_cell) * length(metric_fns_cell), num_datapoints);
    for i = 1:num_datapoints
        slice = squeeze(data_cell(:, i, :, :));
        for j = 1:size(fn_hand_dff, 1)
            collect_pick = collect_fn_cell(fn_hand_dff(j, 1));
            metric_pick = metric_fns_cell(fn_hand_dff(j, 2));
            fit_ord_search(j,i) = search_3d_slice(slice, collect_pick{1}, metric_pick{1});
            
            if j == 25 || j == 50
                continue
            end
            if j >= 25
                j_mod = j-1;
            else
                j_mod = j;
            end
            seg_idx = 1 + floor((j_mod-1)/4);
            sub_idx = 1 + mod(j_mod-1, 4);

            arranged_arr{seg_idx}(sub_idx, i) = fit_ord_search(j,i);
            test_arr{seg_idx, sub_idx} = collect_fn_annot(fn_hand_dff(j, 1)) + " | " + metric_fns_annot(fn_hand_dff(j, 2));
        end
    end
    
    % Plot results
    disp('  Plotting results...')
    for i = 1:(length(collect_fn_cell) * length(metric_fns_cell))
        fprintf('    %i of %i...\n', i, length(collect_fn_cell) * length(metric_fns_cell))
        
        fh = figure(Visible='off');
        s = scatter(node_weights, fit_ord_search(i, :), 30, 'blue', 'filled');
        s.MarkerFaceAlpha = 0.5;
        hold on; plot(node_weights, fit_ord_search(i, :), LineWidth=1.5, Color='blue')
        collect_fn_label = collect_fn_annot(fn_hand_dff(i, 1));
        metric_fn_label = metric_fns_annot(fn_hand_dff(i, 2));
        xlabel('Relative node point weight'); ylabel(collect_fn_label + " | " + metric_fn_label);
        
        subfolder = regexp(collect_fn_label, '[a-z]*\s[a-zA-Z]*$', 'match');
        subfolder = regexprep(subfolder, '\s', '_');
    
        saveas(fh, "fig\node_weight\" + string(subfolder) + "\" + collect_fn_label + "_" + metric_fn_label + ".jpg")
    end

    % Plot combined graph results
    collect_tags = ["density error", "density errorABS", "density CV", "volume error", "volume errorABS", "volume CV"];
    metr_tags = ["slice min", "slice mean"];
    legend_labels = ["Average of bead populations", "10 um beads", "8 um beads", "6 um beads"];
    colors_ = ["red", "blue", "magenta", "black"];

    for i = 1:length(arranged_arr)
        % Assign axis label
        if i <= 6
            ylabel_ = collect_tags(i) + " | " + metr_tags(1);
            fname = collect_tags(i) + "_" + metr_tags(1);
        else
            ylabel_ = collect_tags(i-6) + " | " + metr_tags(2);
            fname = collect_tags(i-6) + "_" + metr_tags(2);
        end
        
        data = arranged_arr{i};
        % fh = figure(Visible='off', Position=[2547 361 811 420]); hold on;
        fh = figure(Visible='off'); hold on;
        for j = 1:size(data, 1)
            s = scatter(node_weights, data(j, :), 30, colors_(j), 'filled', HandleVisibility='off');
            s.MarkerFaceAlpha = 0.5;
            plot(node_weights, data(j, :), LineWidth=1.5, Color=colors_(j), DisplayName=legend_labels(j))
        end
        xlabel('Relative node point weight'); ylabel(ylabel_);
        % legend(Location='eastoutside')
        saveas(fh, "fig\node_weight\" + fname + '_combined.jpg');
    end
end

%% Baseline fit length
if calc_bl_fit_length
    disp('Slicing across fitting order...')

    num_datapoints = size(data_cell, 3); % CHANGE ME!!!
    
    num_arranged_plots = floor(length(collect_fn_annot) / 4) * length(metric_fns_cell);
    arranged_arr = cellfun(@(x) zeros(4, num_datapoints), cell(num_arranged_plots,1), 'UniformOutput', false);
    test_arr = cell(12,4);

    % Fitting order search:
    fn_hand_dff = fullfact([length(collect_fn_cell), length(metric_fns_cell)]);
    fit_ord_search = zeros(length(collect_fn_cell) * length(metric_fns_cell), num_datapoints);
    for i = 1:num_datapoints
        slice = squeeze(data_cell(:, :, i, :));
        for j = 1:size(fn_hand_dff, 1)
            collect_pick = collect_fn_cell(fn_hand_dff(j, 1));
            metric_pick = metric_fns_cell(fn_hand_dff(j, 2));
            fit_ord_search(j,i) = search_3d_slice(slice, collect_pick{1}, metric_pick{1});
            
            if j == 25 || j == 50
                continue
            end
            if j >= 25
                j_mod = j-1;
            else
                j_mod = j;
            end
            seg_idx = 1 + floor((j_mod-1)/4);
            sub_idx = 1 + mod(j_mod-1, 4);

            arranged_arr{seg_idx}(sub_idx, i) = fit_ord_search(j,i);
            test_arr{seg_idx, sub_idx} = collect_fn_annot(fn_hand_dff(j, 1)) + " | " + metric_fns_annot(fn_hand_dff(j, 2));
        end
    end
    
    % Plot results
    disp('  Plotting results...')
    for i = 1:(length(collect_fn_cell) * length(metric_fns_cell))
        fprintf('    %i of %i...\n', i, length(collect_fn_cell) * length(metric_fns_cell))
        
        fh = figure(Visible='off');
        s = scatter(bl_fit_length, fit_ord_search(i, :), 60, 'blue', 'filled');
        s.MarkerFaceAlpha = 0.5;
        hold on; plot(bl_fit_length, fit_ord_search(i, :), LineWidth=4, Color='blue')
        collect_fn_label = collect_fn_annot(fn_hand_dff(i, 1));
        metric_fn_label = metric_fns_annot(fn_hand_dff(i, 2));
        ax=gca; ax.FontSize=14;
        xlabel('Relative baseline fit length', FontSize=20); ylabel(collect_fn_label + " | " + metric_fn_label, FontSize=20);
        
        subfolder = regexp(collect_fn_label, '[a-z]*\s[a-zA-Z]*$', 'match');
        subfolder = regexprep(subfolder, '\s', '_');
        
    
        saveas(fh, "fig\bl_fit_length\" + string(subfolder) + "\" + collect_fn_label + "_" + metric_fn_label + ".jpg")
        saveas(fh, "fig\bl_fit_length\" + string(subfolder) + "\" + collect_fn_label + "_" + metric_fn_label + ".fig")
    end

    % Plot combined graph results
    collect_tags = ["density error", "density errorABS", "density CV", "volume error", "volume errorABS", "volume CV"];
    metr_tags = ["slice min", "slice mean"];
    legend_labels = ["Average of populations", "10 um beads", "8 um beads", "6 um beads"];
    colors_ = ["red", "blue", "magenta", "black"];

    for i = 1:length(arranged_arr)
        % Assign axis label
        if i <= 6
            ylabel_ = collect_tags(i) + " | " + metr_tags(1);
            fname = collect_tags(i) + "_" + metr_tags(1);
        else
            ylabel_ = collect_tags(i-6) + " | " + metr_tags(2);
            fname = collect_tags(i-6) + "_" + metr_tags(2);
        end
        
        data = arranged_arr{i};
        % fh = figure(Visible='off', Position=[2547 361 811 420]); hold on;
        fh = figure(Visible='off'); hold on;
        for j = 1:size(data, 1)
            s = scatter(bl_fit_length, data(j, :), 60, colors_(j), 'filled', HandleVisibility='off');
            s.MarkerFaceAlpha = 0.5;
            plot(bl_fit_length, data(j, :), LineWidth=4, Color=colors_(j), DisplayName=legend_labels(j))
        end
        ax=gca; ax.FontSize=14;
        xlabel('Relative baseline fit length', FontSize=20); ylabel(ylabel_, FontSize=20);
        % legend(Location='eastoutside', FontSize=15)
        saveas(fh, "fig\bl_fit_length\" + fname + '_combined.eps');
        saveas(fh, "fig\bl_fit_length\" + fname + '_combined.eps');
    end
end

%% Baseline fit length
if calc_bl_fit_offset
    disp('Slicing across fitting order...')

    num_datapoints = size(data_cell, 4); % CHANGE ME!!!
    
    num_arranged_plots = floor(length(collect_fn_annot) / 4) * length(metric_fns_cell);
    arranged_arr = cellfun(@(x) zeros(4, num_datapoints), cell(num_arranged_plots,1), 'UniformOutput', false);
    test_arr = cell(12,4);

    % Fitting order search:
    fn_hand_dff = fullfact([length(collect_fn_cell), length(metric_fns_cell)]);
    fit_ord_search = zeros(length(collect_fn_cell) * length(metric_fns_cell), num_datapoints);
    for i = 1:num_datapoints
        slice = squeeze(data_cell(:, :, :, i));
        for j = 1:size(fn_hand_dff, 1)
            collect_pick = collect_fn_cell(fn_hand_dff(j, 1));
            metric_pick = metric_fns_cell(fn_hand_dff(j, 2));
            fit_ord_search(j,i) = search_3d_slice(slice, collect_pick{1}, metric_pick{1});
            
            if j == 25 || j == 50
                continue
            end
            if j >= 25
                j_mod = j-1;
            else
                j_mod = j;
            end
            seg_idx = 1 + floor((j_mod-1)/4);
            sub_idx = 1 + mod(j_mod-1, 4);

            arranged_arr{seg_idx}(sub_idx, i) = fit_ord_search(j,i);
            test_arr{seg_idx, sub_idx} = collect_fn_annot(fn_hand_dff(j, 1)) + " | " + metric_fns_annot(fn_hand_dff(j, 2));
        end
    end
    
    % Plot results
    disp('  Plotting results...')
    for i = 1:(length(collect_fn_cell) * length(metric_fns_cell))
        fprintf('    %i of %i...\n', i, length(collect_fn_cell) * length(metric_fns_cell))
        
        fh = figure(Visible='off');
        s = scatter(bl_fit_offset, fit_ord_search(i, :), 60, 'blue', 'filled');
        s.MarkerFaceAlpha = 0.5;
        hold on; plot(bl_fit_offset, fit_ord_search(i, :), LineWidth=4, Color='blue')
        collect_fn_label = collect_fn_annot(fn_hand_dff(i, 1));
        metric_fn_label = metric_fns_annot(fn_hand_dff(i, 2));
        xlabel('Baseline fit offset'); ylabel(collect_fn_label + " | " + metric_fn_label);
        
        subfolder = regexp(collect_fn_label, '[a-z]*\s[a-zA-Z]*$', 'match');
        subfolder = regexprep(subfolder, '\s', '_');
    
        saveas(fh, "fig\bl_fit_offset\" + string(subfolder) + "\" + collect_fn_label + "_" + metric_fn_label + ".jpg")
    end

    % Plot combined graph results
    collect_tags = ["density error", "density errorABS", "density CV", "volume error", "volume errorABS", "volume CV"];
    metr_tags = ["slice min", "slice mean"];
    legend_labels = ["Average of bead populations", "10 um beads", "8 um beads", "6 um beads"];
    colors_ = ["red", "blue", "magenta", "black"];

    for i = 1:length(arranged_arr)
        % Assign axis label
        if i <= 6
            ylabel_ = collect_tags(i) + " | " + metr_tags(1);
            fname = collect_tags(i) + "_" + metr_tags(1);
        else
            ylabel_ = collect_tags(i-6) + " | " + metr_tags(2);
            fname = collect_tags(i-6) + "_" + metr_tags(2);
        end
        
        data = arranged_arr{i};
        % fh = figure(Visible='off', Position=[2547 361 811 420]); hold on;
        fh = figure(Visible='off'); hold on;
        for j = 1:size(data, 1)
            s = scatter(bl_fit_offset, data(j, :), 60, colors_(j), 'filled', HandleVisibility='off');
            s.MarkerFaceAlpha = 0.5;
            plot(bl_fit_offset, data(j, :), LineWidth=4, Color=colors_(j), DisplayName=legend_labels(j))
        end
        xlabel('Baseline fit offset'); ylabel(ylabel_);
        % legend(Location='eastoutside')
        saveas(fh, "fig\bl_fit_offset\" + fname + '_combined.jpg');
    end
end
%% HELPERS
function value = search_3d_slice(slice, collect_fn, metric_fn)
    ret_arr = zeros(size(slice));
    for i = 1:size(slice,1)
        for j = 1:size(slice,2)
            for k = 1:size(slice,3)
                ret_arr(i,j,k) = collect_fn(slice{i,j,k});
            end
        end
    end
    value = metric_fn(ret_arr);
end

function slope = get_skew_slope(vol_mean, dens_mean)
    p = polyfit(vol_mean, dens_mean, 1);
    slope = p(1);
end