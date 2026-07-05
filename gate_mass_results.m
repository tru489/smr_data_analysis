%% gate_mass_results.m
% Interactive GUI for gating buoyant-mass (SMR) data across an experiment.
%
% Walks a superdirectory whose immediate subfolders are individual samples,
% each containing a "<timestamp>_mass_results" folder with a peak-summary CSV
% (the newest is used if several exist). Lets you draw flow-cytometry-style
% gates across four plots and writes a gated CSV back into each sample folder.
%
% Expected layout:
%   <superdir>/<sample>/<yyyyMMdd.HHmmss>_mass_results/<...>.csv
%
% Output (per gated sample):
%   <superdir>/<sample>/<yyyyMMdd.HHmmss>_gated_mass_results.csv
%
% Controls (selection window): Select all, Set gate, Browse, Undo, Done.
% Gating window: draw one draggable rectangle per plot (optional per plot);
% the accepted set is the logical AND across the plots that have a gate.
%
% DEPENDENCY: Image Processing Toolbox (drawrectangle / images.roi.Rectangle).
%
% Runs cross-platform (Windows/macOS) and is monitor-size agnostic (figures
% are centered with movegui and laid out in normalized units).

script_dir = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(script_dir, 'helpers')));

%% ===== CONFIG (optional): paste a superdirectory to skip the folder picker =====
superdir = "";   % leave "" (default) to be prompted with uigetdir
% ================================================================================

if strlength(string(superdir)) == 0
    sel = uigetdir(pwd, 'Select the superdirectory containing sample folders');
    if isequal(sel, 0)
        return
    end
    superdir = sel;
end

run_app(char(superdir));


% =========================================================================
%  App entry
% =========================================================================
function run_app(superdir)
if isempty(which('drawrectangle'))
    error('gate_mass_results:noIPT', ['This tool requires the Image ' ...
        'Processing Toolbox (function "drawrectangle" was not found).']);
end

samples = discover_mass_results(superdir);
if isempty(samples)
    errordlg(['No samples with a mass_pg CSV were found under:' newline ...
        superdir], 'No data found');
    return
end
fprintf('Discovered %d sample(s) with mass results.\n', numel(samples));

build_selection_window(samples);
end


% =========================================================================
%  Data discovery
% =========================================================================
function samples = discover_mass_results(superdir)
% Walk <superdir>/<sample>/<*_mass_results>/<csv> and load each sample table.
samples = struct('name', {}, 'subdir', {}, 'csv_path', {}, 'tbl', {});
req_cols = {'mass_pg', 'avg_baseline', 'bl_slope', 'node_dev_mean', 'peak_time_m'};

entries = dir(superdir);
subdirs = entries([entries.isdir]);
subdirs = subdirs(~ismember({subdirs.name}, {'.', '..'}));

for i = 1:numel(subdirs)
    sname = subdirs(i).name;
    spath = fullfile(superdir, sname);

    % Find "*_mass_results" folders within this sample directory
    rd = dir(spath);
    rd = rd([rd.isdir]);
    is_mr = ~cellfun('isempty', regexp({rd.name}, '_mass_results$', 'once'));
    mr = rd(is_mr);
    if isempty(mr)
        fprintf('  Skipping "%s": no _mass_results folder.\n', sname);
        continue
    end

    % Pick the most recent by the leading yyyyMMdd.HHmmss token (else datenum)
    ts = regexp({mr.name}, '^\d{8}\.\d{6}', 'match', 'once');
    if all(~cellfun('isempty', ts))
        [~, order] = sort(ts);
    else
        [~, order] = sort([mr.datenum]);
    end
    mr_name = mr(order(end)).name;
    mr_dir = fullfile(spath, mr_name);

    % Find the summary CSV (skip AppleDouble and curation_index files)
    csvs = dir(fullfile(mr_dir, '*.csv'));
    csv_path = '';
    tbl = [];
    for j = 1:numel(csvs)
        fn = csvs(j).name;
        if startsWith(fn, '._') || startsWith(fn, 'curation_index')
            continue
        end
        try
            t = readtable(fullfile(mr_dir, fn));
        catch
            continue
        end
        if ismember('mass_pg', t.Properties.VariableNames)
            csv_path = fullfile(mr_dir, fn);
            tbl = t;
            break
        end
    end
    if isempty(csv_path)
        fprintf('  Skipping "%s": no mass_pg CSV in %s.\n', sname, mr_name);
        continue
    end

    missing = req_cols(~ismember(req_cols, tbl.Properties.VariableNames));
    if ~isempty(missing)
        fprintf('  Skipping "%s": CSV missing column(s): %s\n', sname, ...
            strjoin(missing, ', '));
        continue
    end

    s.name = sname;
    s.subdir = spath;
    s.csv_path = csv_path;
    s.tbl = tbl;
    samples(end+1) = s; %#ok<AGROW>
end
end


% =========================================================================
%  Selection window (main figure)
% =========================================================================
function build_selection_window(samples)
fig = figure('Name', 'Gate mass results — sample selection', ...
    'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
    'Color', 'w', 'Resize', 'on', 'Units', 'pixels', ...
    'Position', [0 0 520 640], 'CloseRequestFcn', @(s,e) delete(s));
movegui(fig, 'center');

% State
setappdata(fig, 'samples', samples);
setappdata(fig, 'ungated_idx', 1:numel(samples));
setappdata(fig, 'gated_tbls', cell(1, numel(samples)));
setappdata(fig, 'history', {});

uicontrol(fig, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.05 0.92 0.9 0.06], 'String', 'Select samples to gate', ...
    'FontSize', 13, 'FontWeight', 'bold', 'BackgroundColor', 'w', ...
    'HorizontalAlignment', 'left');

lb = uicontrol(fig, 'Style', 'listbox', 'Units', 'normalized', ...
    'Position', [0.05 0.18 0.9 0.72], 'Max', 2, 'Min', 0, 'FontSize', 11);
setappdata(fig, 'listbox', lb);

st = uicontrol(fig, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.05 0.11 0.9 0.05], 'String', '', 'FontSize', 10, ...
    'BackgroundColor', 'w', 'HorizontalAlignment', 'left');
setappdata(fig, 'status_txt', st);

% Button row (normalized so it scales on any screen)
bw = 0.16; gap = 0.02; y = 0.03; h = 0.06; xs = 0.05;
uicontrol(fig, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [xs y bw h], 'String', 'Select all', 'FontSize', 10, ...
    'Callback', @(s,e) on_select_all(fig));
btn_gate = uicontrol(fig, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [xs+(bw+gap) y bw h], 'String', 'Set gate', 'FontSize', 10, ...
    'FontWeight', 'bold', 'Callback', @(s,e) on_set_gate(fig));
btn_browse = uicontrol(fig, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [xs+2*(bw+gap) y bw h], 'String', 'Browse', 'FontSize', 10, ...
    'Callback', @(s,e) on_browse(fig));
uicontrol(fig, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [xs+3*(bw+gap) y bw h], 'String', 'Undo', 'FontSize', 10, ...
    'Callback', @(s,e) on_undo(fig));
btn_done = uicontrol(fig, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [xs+4*(bw+gap) y bw h], 'String', 'Done', 'FontSize', 10, ...
    'Callback', @(s,e) on_done(fig));
setappdata(fig, 'btn_gate', btn_gate);
setappdata(fig, 'btn_browse', btn_browse);
setappdata(fig, 'btn_done', btn_done);

refresh_list(fig);
end


function refresh_list(fig)
samples = getappdata(fig, 'samples');
ungated = getappdata(fig, 'ungated_idx');
lb = getappdata(fig, 'listbox');

names = {samples(ungated).name};
lb.String = names;
if isempty(names)
    lb.Value = [];
else
    lb.Value = 1;
end

n_gated = sum(~cellfun('isempty', getappdata(fig, 'gated_tbls')));
st = getappdata(fig, 'status_txt');
st.String = sprintf('Ungated: %d / %d     Gated: %d', numel(ungated), ...
    numel(samples), n_gated);
end


function sel_global = get_selected(fig)
lb = getappdata(fig, 'listbox');
ungated = getappdata(fig, 'ungated_idx');
v = lb.Value;
v = v(v >= 1 & v <= numel(ungated));
sel_global = ungated(v);
end


function push_history(fig)
h = getappdata(fig, 'history');
snap.ungated_idx = getappdata(fig, 'ungated_idx');
snap.gated_tbls = getappdata(fig, 'gated_tbls');
h{end+1} = snap;
setappdata(fig, 'history', h);
end


% ---- Selection-window callbacks ----------------------------------------
function on_select_all(fig)
lb = getappdata(fig, 'listbox');
n = numel(lb.String);
if n > 0
    lb.Value = 1:n;
end
end


function on_set_gate(fig)
sel_global = get_selected(fig);
if isempty(sel_global)
    warndlg('Select at least one sample first.', 'No selection');
    return
end
samples = getappdata(fig, 'samples');

set_main_buttons(fig, 'off');
result = gating_window(samples(sel_global));
figure(fig);
set_main_buttons(fig, 'on');

if ~result.applied
    return
end

push_history(fig);
gated = getappdata(fig, 'gated_tbls');
for k = 1:numel(sel_global)
    gi = sel_global(k);
    gated{gi} = samples(gi).tbl(result.masks{k}, :);
end
setappdata(fig, 'gated_tbls', gated);

ungated = getappdata(fig, 'ungated_idx');
setappdata(fig, 'ungated_idx', setdiff(ungated, sel_global));
refresh_list(fig);
end


function on_browse(fig)
samples = getappdata(fig, 'samples');
ungated = getappdata(fig, 'ungated_idx');
if isempty(ungated)
    warndlg('No ungated samples to browse.', 'Browse');
    return
end
set_main_buttons(fig, 'off');
browse_window(samples(ungated));
figure(fig);
set_main_buttons(fig, 'on');
end


function on_undo(fig)
h = getappdata(fig, 'history');
if isempty(h)
    warndlg('Nothing to undo.', 'Undo');
    return
end
snap = h{end};
h(end) = [];
setappdata(fig, 'history', h);
setappdata(fig, 'ungated_idx', snap.ungated_idx);
setappdata(fig, 'gated_tbls', snap.gated_tbls);
refresh_list(fig);
end


function on_done(fig)
set_main_buttons(fig, 'off');   % prevent double-click while dialog is open
samples = getappdata(fig, 'samples');
gated = getappdata(fig, 'gated_tbls');
gi = find(~cellfun('isempty', gated));

if isempty(gi)
    q = questdlg('No samples have been gated. Close without writing anything?', ...
        'Done', 'Close', 'Cancel', 'Cancel');
    if strcmp(q, 'Close')
        delete(fig);
    else
        set_main_buttons(fig, 'on');
    end
    return
end

ts = char(string(datetime('now', 'TimeZone', 'local', 'Format', 'yyyyMMdd.HHmmss')));
folder_name = [ts '_gated_mass_results'];
summary = {'Gated files written:'};
for k = 1:numel(gi)
    i = gi(k);
    out_dir = fullfile(samples(i).subdir, folder_name);
    mkdir(out_dir);
    out = fullfile(out_dir, [samples(i).name '_bm_gated.csv']);
    writetable(gated{i}, out);
    summary{end+1} = sprintf('%s:  %d -> %d rows', samples(i).name, ...
        height(samples(i).tbl), height(gated{i})); %#ok<AGROW>
    fprintf('Wrote %s  (%d -> %d rows)\n', out, height(samples(i).tbl), ...
        height(gated{i}));
end

msgbox(summary, 'Done');
delete(fig);
end


function set_main_buttons(fig, state)
if ~isvalid(fig), return; end
for f = {'btn_gate', 'btn_browse', 'btn_done'}
    b = getappdata(fig, f{1});
    if ~isempty(b) && isvalid(b)
        b.Enable = state;
    end
end
drawnow;
end


% =========================================================================
%  Plot specifications (shared by gating + browse windows)
% =========================================================================
function specs = make_plotspecs()
specs = {
    struct('type', 'hist', 'col', 'mass_pg', ...
        'xlabel', 'Buoyant mass (pg)', 'title', 'Buoyant mass')
    struct('type', 'scatter', 'xcol', 'peak_time_m', 'ycol', 'avg_baseline', ...
        'xlabel', 'Relative peak time (min)', 'ylabel', 'Average baseline (Hz)', ...
        'title', 'Average baseline vs time')
    struct('type', 'hist', 'col', 'bl_slope', ...
        'xlabel', 'Baseline slope', 'title', 'Baseline slope')
    struct('type', 'hist', 'col', 'node_dev_mean', ...
        'xlabel', 'Avg node deviation', 'title', 'Average node deviation')
    };
end


function hg = render_overlays(axs, samples, specs, colors)
% Draw per-sample overlays into the four axes; returns a numel(samples)x4
% cell of graphics handles (used by the browse window to toggle visibility).
n = numel(samples);
hg = cell(n, 4);
names = {samples.name};

for p = 1:4
    ax = axs(p);
    cla(ax, 'reset');
    hold(ax, 'on');
    box(ax, 'on');
    ax.FontSize = 10;
    spec = specs{p};

    if strcmp(spec.type, 'hist')
        % Shared bin edges over pooled finite data
        pooled = [];
        for si = 1:n
            v = samples(si).tbl.(spec.col);
            pooled = [pooled; v(isfinite(v))]; %#ok<AGROW>
        end
        if isempty(pooled)
            edges = [0 1];
        else
            lo = min(pooled); hi = max(pooled);
            if hi <= lo, hi = lo + 1; end
            edges = linspace(lo, hi, 101);
        end
        for si = 1:n
            v = samples(si).tbl.(spec.col);
            v = v(isfinite(v));
            N = histcounts(v, edges);
            if sum(N) > 0, N = N / sum(N); end
            hg{si, p} = histogram(ax, 'BinEdges', edges, 'BinCounts', N, ...
                'FaceColor', colors(si, :), 'FaceAlpha', 0.35, ...
                'EdgeAlpha', 0.2, 'DisplayName', names{si});
        end
        ylabel(ax, 'Fraction', 'FontSize', 11);
    else
        for si = 1:n
            t = samples(si).tbl;
            hg{si, p} = scatter(ax, t.(spec.xcol), t.(spec.ycol), 8, ...
                colors(si, :), 'filled', 'MarkerFaceAlpha', 0.5, ...
                'DisplayName', names{si});
        end
        ylabel(ax, spec.ylabel, 'FontSize', 11);
    end

    xlabel(ax, spec.xlabel, 'FontSize', 11);
    title(ax, spec.title, 'FontSize', 12);
    if p == 1 && n > 1
        lg = legend(ax, 'show', 'Location', 'northeast', 'FontSize', 8);
        lg.AutoUpdate = 'off';
        lg.Interpreter = 'none';
    end
end
end


% =========================================================================
%  Gating window
% =========================================================================
function result = gating_window(sel_samples)
specs = make_plotspecs();
n = numel(sel_samples);
colors = lines(max(n, 1));

gf = figure('Name', 'Set gate', 'NumberTitle', 'off', 'MenuBar', 'none', ...
    'ToolBar', 'none', 'Color', 'w', 'Resize', 'on', 'Units', 'pixels', ...
    'Position', [0 0 1100 800], 'CloseRequestFcn', @(s,e) gate_close(s));
movegui(gf, 'center');

plot_panel = uipanel('Parent', gf, 'Units', 'normalized', ...
    'Position', [0 0.13 1 0.87], 'BorderType', 'none', 'BackgroundColor', 'w');
tl = tiledlayout(plot_panel, 2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
axs = gobjects(1, 4);
for p = 1:4
    axs(p) = nexttile(tl);
end
render_overlays(axs, sel_samples, specs, colors);

st = uicontrol(gf, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.02 0.065 0.6 0.05], 'String', '', 'FontSize', 10, ...
    'BackgroundColor', 'w', 'HorizontalAlignment', 'left');

% State in appdata
setappdata(gf, 'specs', specs);
setappdata(gf, 'sel_samples', sel_samples);
setappdata(gf, 'axs', axs);
setappdata(gf, 'rois', cell(1, 4));
setappdata(gf, 'st_handle', st);
setappdata(gf, 'applied', false);
setappdata(gf, 'masks', {});
setappdata(gf, 'done', false);

labels = {'Gate: mass', 'Gate: baseline', 'Gate: slope', 'Gate: node dev'};
bw = 0.145;
for p = 1:4
    uicontrol(gf, 'Style', 'pushbutton', 'Units', 'normalized', ...
        'Position', [0.02+(p-1)*(bw+0.008) 0.005 bw 0.05], ...
        'String', labels{p}, 'FontSize', 9, 'Callback', @(s,e) gate_draw(gf, p));
end
uicontrol(gf, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [0.635 0.005 0.10 0.05], 'String', 'Reset gates', ...
    'FontSize', 9, 'Callback', @(s,e) gate_reset(gf));
uicontrol(gf, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [0.745 0.005 0.10 0.05], 'String', 'Back', ...
    'FontSize', 9, 'Callback', @(s,e) gate_close(gf));
uicontrol(gf, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [0.855 0.005 0.125 0.05], 'String', 'Apply', ...
    'FontSize', 10, 'FontWeight', 'bold', 'Callback', @(s,e) gate_apply(gf));

gate_update_status(gf);
% Loop because drawrectangle internally calls uiresume on the same figure,
% which would prematurely exit a single uiwait. Only exit when 'done' is
% explicitly set by Apply, Back, or the window close button.
while isvalid(gf) && ~getappdata(gf, 'done')
    uiwait(gf);
end

if isvalid(gf)
    result.applied = getappdata(gf, 'applied');
    result.masks = getappdata(gf, 'masks');
    delete(gf);
else
    result.applied = false;
    result.masks = {};
end
end


% ---- ROI helpers (work for both drawrectangle objects and hist range structs) ----

function tf = roi_is_set(r)
if isempty(r), tf = false; return; end
if isstruct(r), tf = strcmp(r.type, 'range'); return; end
tf = isvalid(r);
end

function clear_roi(r)
if isempty(r), return; end
if isstruct(r)
    for k = 1:numel(r.lines)
        if ~isempty(r.lines{k}) && isvalid(r.lines{k}), delete(r.lines{k}); end
    end
    if ~isempty(r.patch) && isvalid(r.patch), delete(r.patch); end
else
    if isvalid(r), delete(r); end
end
end

% -------------------------------------------------------------------------

function gate_draw(gf, p)
specs = getappdata(gf, 'specs');
axs  = getappdata(gf, 'axs');
rois = getappdata(gf, 'rois');

% Cancel any pending histogram click mode and clear existing gate for this plot
setappdata(gf, 'hist_state', []);
set(gf, 'WindowButtonDownFcn', '');
clear_roi(rois{p});
rois{p} = [];
setappdata(gf, 'rois', rois);

spec = specs{p};
if strcmp(spec.type, 'hist')
    % Click-based: first click = lower cutoff, second click = upper cutoff
    setappdata(gf, 'hist_state', struct('p', p, 'state', 0, 'lo', NaN, ...
        'lines', {{}}, 'patch', []));
    set(gf, 'WindowButtonDownFcn', @(s,e) gate_hist_click(gf, p));
    st = getappdata(gf, 'st_handle');
    st.String = sprintf('[%s]  Click to set lower cutoff', spec.title);
else
    % Scatter: interactive rectangle
    roi = drawrectangle(axs(p), 'Color', [0.15 0.15 0.15], 'LineWidth', 1);
    rois = getappdata(gf, 'rois');
    rois{p} = roi;
    setappdata(gf, 'rois', rois);
    addlistener(roi, 'MovingROI', @(s,e) gate_update_status(gf));
    addlistener(roi, 'ROIMoved', @(s,e) gate_update_status(gf));
    gate_update_status(gf);
end
end


function gate_hist_click(gf, p)
if ~isvalid(gf), return; end
hs = getappdata(gf, 'hist_state');
if isempty(hs) || hs.p ~= p, return; end

% Only respond to clicks within the target axes
axs = getappdata(gf, 'axs');
ax  = axs(p);
clicked_ax = ancestor(gf.CurrentObject, 'axes');
if isempty(clicked_ax) || ~isequal(clicked_ax, ax), return; end

x  = ax.CurrentPoint(1, 1);
xl = ax.XLim;
if x < xl(1) || x > xl(2), return; end

st    = getappdata(gf, 'st_handle');
specs = getappdata(gf, 'specs');
title = specs{p}.title;

if hs.state == 0
    hs.lo = x;
    hs.state = 1;
    hs.lines{1} = xline(ax, x, '--r', sprintf('%.3g', x), ...
        'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'right', ...
        'FontSize', 8, 'HandleVisibility', 'off');
    st.String = sprintf('[%s]  Lower: %.4g  —  click to set upper cutoff', title, x);

elseif hs.state == 1
    if x <= hs.lo
        st.String = sprintf('[%s]  Upper must be > lower (%.4g) — click again', title, hs.lo);
        setappdata(gf, 'hist_state', hs);
        drawnow; return
    end
    hs.hi = x;
    hs.state = 2;
    hs.lines{2} = xline(ax, x, '--b', sprintf('%.3g', x), ...
        'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'left', ...
        'FontSize', 8, 'HandleVisibility', 'off');
    yl = ax.YLim;
    hs.patch = patch(ax, [hs.lo hs.hi hs.hi hs.lo], [yl(1) yl(1) yl(2) yl(2)], ...
        'g', 'FaceAlpha', 0.12, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    uistack(hs.patch, 'bottom');

    rois = getappdata(gf, 'rois');
    rois{p} = struct('type', 'range', 'lo', hs.lo, 'hi', hs.hi, ...
        'lines', {hs.lines}, 'patch', hs.patch);
    setappdata(gf, 'rois', rois);
    setappdata(gf, 'hist_state', []);
    set(gf, 'WindowButtonDownFcn', '');
    gate_update_status(gf);
    drawnow;
    return
end
setappdata(gf, 'hist_state', hs);
drawnow;
end


function gate_reset(gf)
rois = getappdata(gf, 'rois');
for p = 1:4
    clear_roi(rois{p});
    rois{p} = [];
end
setappdata(gf, 'rois', rois);
setappdata(gf, 'hist_state', []);
set(gf, 'WindowButtonDownFcn', '');
gate_update_status(gf);
end


function m = gate_compute_masks(gf)
specs = getappdata(gf, 'specs');
sel   = getappdata(gf, 'sel_samples');
rois  = getappdata(gf, 'rois');
n = numel(sel);
m = cell(1, n);
for si = 1:n
    t = sel(si).tbl;
    mask = true(height(t), 1);
    for p = 1:4
        r = rois{p};
        if ~roi_is_set(r), continue; end
        spec = specs{p};
        if strcmp(spec.type, 'hist')
            v = t.(spec.col);
            mask = mask & v >= r.lo & v <= r.hi;
        else
            pos = r.Position;   % [x y w h]
            xr = sort([pos(1), pos(1) + pos(3)]);
            yr = sort([pos(2), pos(2) + pos(4)]);
            xv = t.(spec.xcol); yv = t.(spec.ycol);
            mask = mask & xv >= xr(1) & xv <= xr(2) & yv >= yr(1) & yv <= yr(2);
        end
    end
    m{si} = mask;
end
end


function gate_update_status(gf)
% Don't overwrite status text while histogram click mode is active
hs = getappdata(gf, 'hist_state');
if ~isempty(hs) && hs.state < 2, return; end
st   = getappdata(gf, 'st_handle');
rois = getappdata(gf, 'rois');
m = gate_compute_masks(gf);
acc = 0; tot = 0;
for si = 1:numel(m)
    acc = acc + sum(m{si});
    tot = tot + numel(m{si});
end
ngates = sum(cellfun(@roi_is_set, rois));
st.String = sprintf('Gates set: %d / 4     Accepted (pooled): %d / %d', ...
    ngates, acc, tot);
end


function gate_apply(gf)
rois = getappdata(gf, 'rois');
ngates = sum(cellfun(@roi_is_set, rois));
if ngates == 0
    q = questdlg('No gates drawn. Accept all points for the selected samples?', ...
        'No gates', 'Accept all', 'Cancel', 'Cancel');
    if ~strcmp(q, 'Accept all')
        return
    end
end
setappdata(gf, 'masks', gate_compute_masks(gf));
setappdata(gf, 'applied', true);
setappdata(gf, 'done', true);
uiresume(gf);
end


function gate_close(gf)
if isvalid(gf) && isappdata(gf, 'done')
    setappdata(gf, 'done', true);
end
uiresume(gf);
end


% =========================================================================
%  Browse window (read-only overlay + per-sample show/hide sidebar)
% =========================================================================
function browse_window(samples)
specs = make_plotspecs();
n = numel(samples);
colors = lines(max(n, 1));

bf = figure('Name', 'Browse samples', 'NumberTitle', 'off', 'MenuBar', 'none', ...
    'ToolBar', 'none', 'Color', 'w', 'Resize', 'on', 'Units', 'pixels', ...
    'Position', [0 0 1200 800], 'CloseRequestFcn', @(s,e) uiresume(s));
movegui(bf, 'center');

side = uipanel('Parent', bf, 'Units', 'normalized', 'Position', [0 0 0.16 1], ...
    'Title', 'Samples (show/hide)', 'BackgroundColor', 'w', 'FontSize', 9);
plot_panel = uipanel('Parent', bf, 'Units', 'normalized', ...
    'Position', [0.16 0.07 0.84 0.93], 'BorderType', 'none', 'BackgroundColor', 'w');
tl = tiledlayout(plot_panel, 2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
axs = gobjects(1, 4);
for p = 1:4
    axs(p) = nexttile(tl);
end
hg = render_overlays(axs, samples, specs, colors);
setappdata(bf, 'hg', hg);

% Per-sample checkboxes stacked top-down (normalized within the sidebar)
row_h = min(0.05, 0.92 / max(n, 1));
for si = 1:n
    uicontrol(side, 'Style', 'checkbox', 'Units', 'normalized', ...
        'Position', [0.05, 0.96 - si*row_h, 0.9, row_h*0.9], ...
        'String', samples(si).name, 'Value', 1, 'BackgroundColor', 'w', ...
        'FontSize', 8, 'ForegroundColor', colors(si, :), ...
        'Callback', @(s,e) browse_toggle(bf, si, s));
end

uicontrol(bf, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [0.16 0.005 0.1 0.05], 'String', 'Back', 'FontSize', 10, ...
    'Callback', @(s,e) uiresume(bf));

uiwait(bf);
if isvalid(bf)
    delete(bf);
end
end


function browse_toggle(bf, si, src)
hg = getappdata(bf, 'hg');
if src.Value
    vis = 'on';
else
    vis = 'off';
end
for p = 1:4
    h = hg{si, p};
    if ~isempty(h) && isvalid(h)
        h.Visible = vis;
    end
end
end
