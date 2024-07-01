function run_gridsearch_full_new_dataset
close all;
addpath(genpath("..\..\helpers"))
addpath(genpath("..\..\final_code"))

warning('off')

poolobj = parpool; % delete(gcp('nocreate'))

%% Filepaths
drive_lett = "A";
save_path = drive_lett + ":\thomasu\raw_data\2024-06-28\dens_trap_fitting_gridsearch_5-15um";
log_path = drive_lett + ":\thomasu\raw_data\2024-06-17\5-15um_bead_trap\20240628.104421_density_trap_results\log.json";
fwd_unpaired_path = drive_lett + ":\thomasu\raw_data\2024-06-17\5-15um_bead_trap\20240628.104421_density_trap_results\peakset_summary_unpaired_fluid1.csv";
back_unpaired_path = drive_lett + ":\thomasu\raw_data\2024-06-17\5-15um_bead_trap\20240628.104421_density_trap_results\peakset_summary_unpaired_fluid2.csv";
bin_dir_path = drive_lett + ":\thomasu\raw_data\2024-06-17\5-15um_bead_trap";
fl1_ref_freq = 1158754;
fl2_ref_freq = 1142254;
rev_peaks_invert = 1;

%% Set parameters

% Read curation index matrix for forward peaks
fwd_unp = readtable(fwd_unpaired_path);
fwd_arr_t = fwd_unp.real_time_s;

% Read curation index matrix for backward peaks
back_unp = readtable(back_unpaired_path);
back_arr_t = back_unp.real_time_s;

% Set file selection bools for automatic file selection
file_selection.valve_state = 1;
file_selection.mass_cal = 1;
file_selection.dens_bl_cal = 1;
file_selection.pmt_data = 0;
file_selection.cc_data = 0;

%% Run gridsearch simulations

fitting_orders = 1:1:5; % order of polynomial fit of baseline
node_weights = 0:0.2:1; % weight of node points as a fraction of total peakset width
bl_fit_length = 0.5:1:7.5; % Length of baseline to fit as a fraction of 1/4 of the total peakset width
bl_fit_offset = -20:10:30; % Offset in datapoints between peak and baseline fitted area

% fitting_orders = [2]; % order of polynomial fit of baseline
% node_weights = 0; % weight of node points as a fract ion of total peakset width
% bl_fit_length = [0.5, 8]; % Length of baseline to fit as a fraction of 1/4 of the total peakset width
% bl_fit_offset = 25; % Offset in datapoints between peak and baseline fitted area

% Order (same as dimensions in compiled data) is: fitting poly order, node
% fitting weights, bl fit datapoint length
value_arr = {fitting_orders, node_weights, bl_fit_length, bl_fit_offset};
dff = fullfact([length(fitting_orders) length(node_weights) length(bl_fit_length) length(bl_fit_offset)]);
compiled_data = cell(length(fitting_orders)*length(node_weights)*length(bl_fit_length)*length(bl_fit_offset), 1);

dff_fit_ord_temp = dff(:, 1);
dff_nod_w_temp = dff(:, 2);
dff_bl_fit_len_temp = dff(:, 3);
dff_bl_offset = dff(:, 4);

D = parallel.pool.DataQueue;
h = waitbar(0, 'Performing gridsearch...');
afterEach(D, @nUpdateWaitbar);
p = 1;

% fileID = fopen(fullfile(save_path, 'log.txt'),'w');
tic
parfor i = 1:size(dff, 1)
%for i = 1:size(dff, 1)
    tic

    % dff_slice = dff(i, :);
    % fit_ord_temp = fitting_orders(dff(i, 1));
    % nod_w_temp = node_weights(dff(i, 2));
    % bl_fit_len_temp = bl_fit_length(dff(i, 3));
    % bl_offset = bl_fit_offset(dff(i, 4));
    fit_ord_temp = dff_fit_ord_temp(i);
    nod_w_temp = dff_nod_w_temp(i);
    bl_fit_len_temp = dff_bl_fit_len_temp(i);
    bl_offset = dff_bl_offset(i);

    
    % Get run parameters from parameter log
    run_params = get_json_struct("", log_path);
    run_params.vis.ppt_template_abs_path = "";
    run_params.dir_formatting.default_cal_path = "";
    run_params.saving.save_abs_path = "";
    run_params.analysis_params.verbose = 0;
    
    run_params.backend.baseline_fit_type = fit_ord_temp;
    run_params.backend.use_node_bl_fit = true;
    run_params.backend.node_bl_weight = nod_w_temp;
    run_params.backend.sidelength_coef = bl_fit_len_temp;
    run_params.backend.offset_length = bl_offset;

    paired_datasmr = run_single_search(run_params, file_selection, ...
        bin_dir_path, fl1_ref_freq, fl2_ref_freq, rev_peaks_invert, ...
        fwd_arr_t,  back_arr_t);

    % Save data to indices in cell arrays
    compiled_data{i} = paired_datasmr;
    send(D, i)
    % iter_time = toc;
    % fileID = fopen('log.txt','a');
    % fprintf(fileID, 'Iteration %i of %i | t(last iter) = %.3f seconds\n', i, size(dff, 1), iter_time);
    % fprintf('Iteration %i of %i | t(last iter) = %.3f seconds\n', i, size(dff, 1), iter_time);
end
save(fullfile(save_path, "data_paired.mat"), 'compiled_data', 'value_arr', 'dff')
t = toc;
fprintf('Elapsed: %.4f seconds\n', t)

delete(poolobj)

function nUpdateWaitbar(~)
    waitbar(p/size(dff, 1), h);
    p = p + 1;
    h.Name = sprintf('%i of %i...', p, size(dff, 1));
end
end