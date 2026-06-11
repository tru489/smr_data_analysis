function [datasmr_processed, dataidx, curation_log] = manual_pk_curation(run_params, samplepeak, ...
    sampletime, sample_baseline_fits, left_bl_length, right_bl_length, datasmr)
% Manual peak curation using a paginated grid GUI.
%
% Arguments:
%   run_params (struct): run parameters (uses run_params.curation.grid_rows/cols)
%   samplepeak (array(double)): concatenated frequency peak data with NaN separators
%   sampletime (array(double)): corresponding time data
%   sample_baseline_fits (array(double)): baseline fit data
%   left_bl_length (array): left baseline length per peak
%   right_bl_length (array): right baseline length per peak
%   datasmr (table): peak summary table
% Returns:
%   datasmr_processed (table): summary table filtered to accepted peaks
%   dataidx (array): row indices of accepted peaks in datasmr
%   curation_log (struct array): per-peak decision record

%% Setup — parse NaN separators to find peak boundaries
dataidx = [];
idx0 = find(isnan(samplepeak));
n_peaks = length(idx0);

Peak.count     = n_peaks;
Peak.start     = zeros(1, n_peaks);
Peak.process   = zeros(1, n_peaks); % 0=pending, 1=accepted, 2=rejected
Peak.peakorder = zeros(1, n_peaks);
Peak.start(1)  = 1;

disp('-----------------Manual Peak Curation-----------------');
fprintf('Total number of peaks: %d\n', n_peaks);

if n_peaks ~= height(datasmr)
    disp('Length of sample peaks does not match peak detection summary');
    input('Go?');
end

for j = 2:n_peaks
    Peak.start(j) = idx0(j-1) + 3;
end
for j = 1:n_peaks
    Peak.peakorder(j) = samplepeak(idx0(j) + 1);
end
for j = 1:n_peaks
    Peak.sectnum(j) = samplepeak(idx0(j) + 2);
end

%% Auto-discard
if run_params.curation.auto_rejection
    idx_discard = auto_discard_peaks(run_params, run_params.curation, datasmr);
else
    idx_discard = [];
end
Peak.process(idx_discard) = 2;
fprintf('# of peaks automatically discarded: %d\n', length(idx_discard));
disp('-----------------------------------------------');

%% Extract individual peak waveforms into struct array
peaks_data = struct('freq', cell(1, n_peaks), 'time', cell(1, n_peaks), ...
    'bl_fit', cell(1, n_peaks), 'left_bl', cell(1, n_peaks), ...
    'right_bl', cell(1, n_peaks), 'auto_rejected', cell(1, n_peaks));

for i = 1:n_peaks
    if i == n_peaks
        raw_peak = samplepeak(Peak.start(i) : idx0(end)-1);
        raw_time = sampletime(Peak.start(i) : idx0(end)-1);
        raw_bl   = sample_baseline_fits(Peak.start(i) : idx0(end)-1);
    else
        raw_peak = samplepeak(Peak.start(i) : Peak.start(i+1)-4);
        raw_time = sampletime(Peak.start(i) : Peak.start(i+1)-4);
        raw_bl   = sample_baseline_fits(Peak.start(i) : Peak.start(i+1)-4);
    end
    pk_median = median(raw_peak);
    peaks_data(i).freq         = raw_peak - pk_median;
    peaks_data(i).time         = raw_time;
    peaks_data(i).bl_fit       = raw_bl - pk_median;
    peaks_data(i).left_bl      = peaks_data(i).freq(1 : 1 + left_bl_length(i));
    peaks_data(i).right_bl     = peaks_data(i).freq(end - right_bl_length(i) : end);
    peaks_data(i).auto_rejected = ismember(i, idx_discard);
end

%% Launch grid GUI (blocks until user clicks Done)
rejection_mask = false(1, n_peaks);
rejection_mask(idx_discard) = true;

rejection_mask = run_grid_gui(peaks_data, rejection_mask, run_params);

%% Build outputs — same logic and curation_log structure as original
manual_idx = find(~ismember(1:n_peaks, idx_discard));

curation_log = [];
for i = manual_idx
    tempidx = find(datasmr.segment_num == Peak.sectnum(i) & ...
                   datasmr.pk_order    == Peak.peakorder(i));

    temp_st.freq = peaks_data(i).freq;
    if run_params.curation.disp_bl_fit
        temp_st.bl_fit = peaks_data(i).bl_fit;
    end
    temp_st.left_baseline  = peaks_data(i).left_bl;
    temp_st.right_baseline = peaks_data(i).right_bl;

    if ~rejection_mask(i)
        dataidx        = [dataidx, tempidx]; %#ok<AGROW>
        temp_st.status = 1;
    else
        temp_st.status = 0;
    end
    curation_log = [curation_log, temp_st]; %#ok<AGROW>
end

datasmr_processed = datasmr(dataidx, :);

fprintf('\nCuration complete: %d / %d peaks accepted.\n', ...
    numel(dataidx), numel(manual_idx));

end


% =========================================================================
%  Grid GUI (sub-function)
% =========================================================================

function rejection_mask = run_grid_gui(peaks_data, rejection_mask, run_params)

grid_rows    = run_params.curation.grid_rows;
grid_cols    = run_params.curation.grid_cols;
peaks_per_pg = grid_rows * grid_cols;
manual_idx   = find(~[peaks_data.auto_rejected]);
n_manual     = numel(manual_idx);
n_pages      = ceil(n_manual / peaks_per_pg);

%% Create figure
scrsize = get(0, 'ScreenSize');
fig = figure('OuterPosition', [0, 0.05*scrsize(4), scrsize(3), 0.95*scrsize(4)], ...
    'Name', 'Manual Peak Curation', ...
    'NumberTitle', 'off', ...
    'KeyPressFcn', @on_key_press, ...
    'CloseRequestFcn', @on_close);

% Navigation buttons at the bottom
btn_h   = 0.05;
btn_y   = 0.01;
btn_w   = 0.12;

uicontrol(fig, 'Style', 'pushbutton', 'String', '← Prev  (p)', ...
    'Units', 'normalized', 'Position', [0.02, btn_y, btn_w, btn_h], ...
    'FontSize', 11, 'Callback', @on_prev);

uicontrol(fig, 'Style', 'pushbutton', 'String', 'Next →  (n)', ...
    'Units', 'normalized', 'Position', [0.86, btn_y, btn_w, btn_h], ...
    'FontSize', 11, 'Callback', @on_next);

uicontrol(fig, 'Style', 'pushbutton', 'String', 'Done  (d)', ...
    'Units', 'normalized', 'Position', [0.44, btn_y, btn_w, btn_h], ...
    'FontSize', 12, 'FontWeight', 'bold', 'Callback', @on_done);

status_txt = uicontrol(fig, 'Style', 'text', 'String', '', ...
    'Units', 'normalized', 'Position', [0.15, btn_y, 0.28, btn_h], ...
    'FontSize', 10, 'HorizontalAlignment', 'center');

page_txt = uicontrol(fig, 'Style', 'text', 'String', '', ...
    'Units', 'normalized', 'Position', [0.57, btn_y, 0.28, btn_h], ...
    'FontSize', 10, 'HorizontalAlignment', 'center');

%% Store shared state in figure appdata
setappdata(fig, 'rejection_mask', rejection_mask);
setappdata(fig, 'current_page',   1);
setappdata(fig, 'peaks_data',     peaks_data);
setappdata(fig, 'manual_idx',     manual_idx);
setappdata(fig, 'n_pages',        n_pages);
setappdata(fig, 'grid_rows',      grid_rows);
setappdata(fig, 'grid_cols',      grid_cols);
setappdata(fig, 'peaks_per_pg',   peaks_per_pg);
setappdata(fig, 'run_params',     run_params);
setappdata(fig, 'status_txt',     status_txt);
setappdata(fig, 'page_txt',       page_txt);
setappdata(fig, 'axes_handles',   []);

render_page(fig);

uiwait(fig);

if isvalid(fig)
    rejection_mask = getappdata(fig, 'rejection_mask');
    close(fig);
end

end


% -------------------------------------------------------------------------
%  Render current page
% -------------------------------------------------------------------------

function render_page(fig)
peaks_data   = getappdata(fig, 'peaks_data');
manual_idx   = getappdata(fig, 'manual_idx');
rejection_mask = getappdata(fig, 'rejection_mask');
current_page = getappdata(fig, 'current_page');
n_pages      = getappdata(fig, 'n_pages');
grid_rows    = getappdata(fig, 'grid_rows');
grid_cols    = getappdata(fig, 'grid_cols');
peaks_per_pg = getappdata(fig, 'peaks_per_pg');
run_params   = getappdata(fig, 'run_params');
status_txt   = getappdata(fig, 'status_txt');
page_txt     = getappdata(fig, 'page_txt');

% Delete previous subplot axes
old_axes = getappdata(fig, 'axes_handles');
for k = 1:numel(old_axes)
    if isvalid(old_axes(k)), delete(old_axes(k)); end
end

% Indices into manual_idx for this page
page_start = (current_page - 1) * peaks_per_pg + 1;
page_end   = min(current_page * peaks_per_pg, numel(manual_idx));
page_manual_pos = page_start:page_end;   % positions within manual_idx
n_on_page  = numel(page_manual_pos);

% Reserve bottom strip for buttons (plot area = top 93%)
plot_top    = 0.07;
plot_height = 0.93;

axes_handles = gobjects(1, n_on_page);
for k = 1:n_on_page
    global_idx = manual_idx(page_manual_pos(k));
    pk = peaks_data(global_idx);

    % Compute subplot position manually to stay within plot area
    col = mod(k-1, grid_cols);
    row = floor((k-1) / grid_cols);
    ax_w = 1 / grid_cols;
    ax_h = plot_height / grid_rows;
    ax_x = col * ax_w;
    ax_y = plot_top + (grid_rows - 1 - row) * ax_h;

    ax = axes('Parent', fig, ...
        'Position', [ax_x + 0.005, ax_y + 0.005, ax_w - 0.01, ax_h - 0.02], ...
        'XTick', [], 'YTick', [], ...
        'UserData', global_idx, ...
        'ButtonDownFcn', @on_peak_click);
    hold(ax, 'on');

    lh = plot(ax, pk.time, pk.freq, 'b', 'LineWidth', 0.8);
    lh.ButtonDownFcn = @on_peak_click;

    if run_params.curation.disp_bl_fit
        lh2 = plot(ax, pk.time, pk.bl_fit, 'r--', 'LineWidth', 0.8);
        lh2.ButtonDownFcn = @on_peak_click;
    end

    lh3 = plot(ax, pk.time(1:numel(pk.left_bl)),         pk.left_bl,  'g', 'LineWidth', 1);
    lh4 = plot(ax, pk.time(end-numel(pk.right_bl)+1:end), pk.right_bl, 'g', 'LineWidth', 1);
    lh3.ButtonDownFcn = @on_peak_click;
    lh4.ButtonDownFcn = @on_peak_click;

    % Peak number label (relative to all peaks, not manual_idx)
    t = title(ax, sprintf('%d', global_idx), 'FontSize', 7, 'Interpreter', 'none');
    t.ButtonDownFcn = @on_peak_click;

    set_subplot_color(ax, rejection_mask(global_idx));
    axes_handles(k) = ax;
end

setappdata(fig, 'axes_handles', axes_handles);

% Update text labels
n_kept = sum(~rejection_mask(manual_idx));
status_txt.String = sprintf('Kept: %d / %d', n_kept, numel(manual_idx));
page_txt.String   = sprintf('Page %d / %d', current_page, n_pages);

end


% -------------------------------------------------------------------------
%  Set subplot border color based on rejection state
% -------------------------------------------------------------------------

function set_subplot_color(ax, is_rejected)
if is_rejected
    ax.XColor = [0.85, 0.1, 0.1];
    ax.YColor = [0.85, 0.1, 0.1];
    ax.Color  = [1.0, 0.92, 0.92];
    ax.Title.Color = [0.85, 0.1, 0.1];
else
    ax.XColor = [0.1, 0.6, 0.1];
    ax.YColor = [0.1, 0.6, 0.1];
    ax.Color  = 'w';
    ax.Title.Color = [0.1, 0.6, 0.1];
end
end


% -------------------------------------------------------------------------
%  Callbacks
% -------------------------------------------------------------------------

function on_peak_click(src, ~)
if isa(src, 'matlab.graphics.axis.Axes')
    ax = src;
else
    ax = ancestor(src, 'axes');
end
if isempty(ax), return; end

fig        = ax.Parent;
peak_idx   = ax.UserData;
rejection_mask = getappdata(fig, 'rejection_mask');
rejection_mask(peak_idx) = ~rejection_mask(peak_idx);
setappdata(fig, 'rejection_mask', rejection_mask);

set_subplot_color(ax, rejection_mask(peak_idx));

% Update kept count
manual_idx = getappdata(fig, 'manual_idx');
status_txt = getappdata(fig, 'status_txt');
n_kept = sum(~rejection_mask(manual_idx));
status_txt.String = sprintf('Kept: %d / %d', n_kept, numel(manual_idx));
end


function on_next(src, ~)
fig  = src.Parent;
page = getappdata(fig, 'current_page');
npp  = getappdata(fig, 'n_pages');
if page < npp
    setappdata(fig, 'current_page', page + 1);
    render_page(fig);
end
end


function on_prev(src, ~)
fig  = src.Parent;
page = getappdata(fig, 'current_page');
if page > 1
    setappdata(fig, 'current_page', page - 1);
    render_page(fig);
end
end


function on_done(src, ~)
uiresume(src.Parent);
end


function on_key_press(fig, event)
switch lower(event.Key)
    case {'rightarrow', 'n'}
        page = getappdata(fig, 'current_page');
        npp  = getappdata(fig, 'n_pages');
        if page < npp
            setappdata(fig, 'current_page', page + 1);
            render_page(fig);
        end
    case {'leftarrow', 'p'}
        page = getappdata(fig, 'current_page');
        if page > 1
            setappdata(fig, 'current_page', page - 1);
            render_page(fig);
        end
    case 'd'
        uiresume(fig);
end
end


function on_close(fig, ~)
% Treat window close the same as Done
uiresume(fig);
end
