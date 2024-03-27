close all;
addpath(genpath("..\..\helpers"));

drive_lett = "A";
search_path = drive_lett + ":\thomasu\raw_data\2024-03-19\dens_trap_fitting_gridsearch\data_cleaned.mat";
st = load(search_path);
data_cell = st.compiled_4d;

%% Calculation prefs
calc_fitting_order = 0;
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

%% Slice across axes and extract
% Dimension order: fitting_order, node_weight, bl_fit_length, bl_fit_offset

if calc_fitting_order
    disp('Slicing across fitting order...')
    % Fitting order search:
    fn_hand_dff = fullfact([length(collect_fn_cell), length(metric_fns_cell)]);
    fit_ord_search = zeros(length(collect_fn_cell) * length(metric_fns_cell), size(data_cell, 1));
    for i = 1:size(data_cell, 1)
        slice = squeeze(data_cell(i, :, :, :));
        for j = 1:size(fn_hand_dff, 1)
            collect_pick = collect_fn_cell(fn_hand_dff(j, 1));
            metric_pick = metric_fns_cell(fn_hand_dff(j, 2));
            fit_ord_search(j,i) = search_3d_slice(slice, collect_pick{1}, metric_pick{1});
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
end

% -------------------------------------------------
if calc_node_weight
    disp('Slicing across node weight...')
    % node_weight search:
    dimension_idx = 2;
    fn_hand_dff = fullfact([length(collect_fn_cell), length(metric_fns_cell)]);
    fit_ord_search = zeros(length(collect_fn_cell) * length(metric_fns_cell), size(data_cell, dimension_idx));
    for i = 1:size(data_cell, dimension_idx)
        slice = squeeze(data_cell(:, i, :, :));
        for j = 1:size(fn_hand_dff, 1)
            collect_pick = collect_fn_cell(fn_hand_dff(j, 1));
            metric_pick = metric_fns_cell(fn_hand_dff(j, 2));
            fit_ord_search(j,i) = search_3d_slice(slice, collect_pick{1}, metric_pick{1});
        end
    end
    
    % Plot results
    disp('  Plotting results...')
    for i = 1:(length(collect_fn_cell) * length(metric_fns_cell))
        fprintf('    %i of %i...\n', i, length(collect_fn_cell) * length(metric_fns_cell))
        fh = figure(Visible='off');
        s = scatter(node_weights, fit_ord_search(i, :), 25, 'blue', 'filled');
        s.MarkerFaceAlpha = 0.5;
        collect_fn_label = collect_fn_annot(fn_hand_dff(i, 1));
        metric_fn_label = metric_fns_annot(fn_hand_dff(i, 2));
        xlabel('Relative node weight'); ylabel(collect_fn_label + " | " + metric_fn_label);
        
        subfolder = regexp(collect_fn_label, '[a-z]*\s[a-zA-Z]*$', 'match');
        subfolder = regexprep(subfolder, '\s', '_');
    
        saveas(fh, "fig\node_weight\" + string(subfolder) + "\" + collect_fn_label + "_" + metric_fn_label + ".jpg")
    end
end

% -------------------------------------------------

if calc_bl_fit_length
    disp('Slicing across baseline fit length...')
    % node_weight search:
    dimension_idx = 3;
    fn_hand_dff = fullfact([length(collect_fn_cell), length(metric_fns_cell)]);
    fit_ord_search = zeros(length(collect_fn_cell) * length(metric_fns_cell), size(data_cell, dimension_idx));
    for i = 1:size(data_cell, dimension_idx)
        slice = squeeze(data_cell(:, :, i, :));
        for j = 1:size(fn_hand_dff, 1)
            collect_pick = collect_fn_cell(fn_hand_dff(j, 1));
            metric_pick = metric_fns_cell(fn_hand_dff(j, 2));
            fit_ord_search(j,i) = search_3d_slice(slice, collect_pick{1}, metric_pick{1});
        end
    end
    
    % Plot results
    disp('  Plotting results...')
    for i = 1:(length(collect_fn_cell) * length(metric_fns_cell))
        fprintf('    %i of %i...\n', i, length(collect_fn_cell) * length(metric_fns_cell))
        fh = figure(Visible='off');
        s = scatter(bl_fit_length, fit_ord_search(i, :), 25, 'blue', 'filled');
        s.MarkerFaceAlpha = 0.5;
        collect_fn_label = collect_fn_annot(fn_hand_dff(i, 1));
        metric_fn_label = metric_fns_annot(fn_hand_dff(i, 2));
        xlabel('Relative baseline fit length'); ylabel(collect_fn_label + " | " + metric_fn_label);
        
        subfolder = regexp(collect_fn_label, '[a-z]*\s[a-zA-Z]*$', 'match');
        subfolder = regexprep(subfolder, '\s', '_');
    
        saveas(fh, "fig\bl_fit_length\" + string(subfolder) + "\" + collect_fn_label + "_" + metric_fn_label + ".jpg")
    end
end

% -------------------------------------------------

if calc_bl_fit_offset
    disp('Slicing across baseline fit offset...')
    % bl_fit_offset search:
    dimension_idx = 4;
    fn_hand_dff = fullfact([length(collect_fn_cell), length(metric_fns_cell)]);
    fit_ord_search = zeros(length(collect_fn_cell) * length(metric_fns_cell), size(data_cell, dimension_idx));
    for i = 1:size(data_cell, dimension_idx)
        slice = squeeze(data_cell(:, :, :, i));
        for j = 1:size(fn_hand_dff, 1)
            collect_pick = collect_fn_cell(fn_hand_dff(j, 1));
            metric_pick = metric_fns_cell(fn_hand_dff(j, 2));
            fit_ord_search(j,i) = search_3d_slice(slice, collect_pick{1}, metric_pick{1});
        end
    end
    
    % Plot results
    disp('  Plotting results...')
    for i = 1:(length(collect_fn_cell) * length(metric_fns_cell))
        fprintf('    %i of %i...\n', i, length(collect_fn_cell) * length(metric_fns_cell))
        fh = figure(Visible='off');
        s = scatter(bl_fit_offset, fit_ord_search(i, :), 25, 'blue', 'filled');
        s.MarkerFaceAlpha = 0.5;
        collect_fn_label = collect_fn_annot(fn_hand_dff(i, 1));
        metric_fn_label = metric_fns_annot(fn_hand_dff(i, 2));
        xlabel('Relative baseline fit length'); ylabel(collect_fn_label + " | " + metric_fn_label);
        
        subfolder = regexp(collect_fn_label, '[a-z]*\s[a-zA-Z]*$', 'match');
        subfolder = regexprep(subfolder, '\s', '_');
    
        saveas(fh, "fig\bl_fit_offset\" + string(subfolder) + "\" + collect_fn_label + "_" + metric_fn_label + ".jpg")
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

% function 
% 
% end