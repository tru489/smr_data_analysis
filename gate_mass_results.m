%% gate_mass_results.m
% Interactive GUI for gating buoyant-mass (SMR) data across an experiment.
%
% Walks a superdirectory whose immediate subfolders are individual samples,
% each containing a "<timestamp>_mass_results" folder with a peak-summary CSV
% (the newest is used if several exist). Overlays the selected samples across
% four histograms and lets you keep only the cells you want, writing a gated
% CSV per sample.
%
% Expected layout:
%   <superdir>/<sample>/<yyyyMMdd.HHmmss>_mass_results/<...>.csv
%
% Output (per gated sample): a "<yyyyMMdd.HHmmss>_gated_mass_results" folder
% inside the sample folder, containing "<sample>_bm_gated.csv".
%
% Controls (selection window): Select all, Set gate, Browse, Undo, Done.
% Gating window: for any histogram, click a Gate button then click a lower and
% an upper cutoff on that plot (optional per plot); the accepted set is the
% logical AND across the plots that have a cutoff. Each histogram has x-limit
% boxes to zoom/re-bin for visibility when data span a large range.
%
% The four histograms are: buoyant mass, normalized baseline (avg_baseline
% divided by the mean baseline over the first 10% of the run), baseline slope,
% and average node deviation.
%
% Runs cross-platform (Windows/macOS) and is monitor-size agnostic (figures
% are centered with movegui and laid out in normalized units). No extra
% toolboxes are required.

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
% All four plots are histograms. Plot 2 is a derived quantity: avg_baseline
% normalized to the mean baseline over the first 10% of the run.
specs = {
    struct('type', 'hist', 'col', 'mass_pg', ...
        'xlabel', 'Buoyant mass (pg)', 'title', 'Buoyant mass')
    struct('type', 'hist', 'derived', 'baseline_norm', ...
        'xlabel', 'Normalized baseline (frac. of first-10% mean)', ...
        'title', 'Normalized baseline')
    struct('type', 'hist', 'col', 'bl_slope', ...
        'xlabel', 'Baseline slope', 'title', 'Baseline slope')
    struct('type', 'hist', 'col', 'node_dev_mean', ...
        'xlabel', 'Avg node deviation', 'title', 'Average node deviation')
    };
end


function v = values_for_spec(t, spec)
% Return the vector of values a plot/gate operates on for one sample table.
if isfield(spec, 'derived') && strcmp(spec.derived, 'baseline_norm')
    bl = t.avg_baseline;
    tm = t.peak_time_m;
    good = isfinite(bl) & isfinite(tm);
    ref = NaN;
    if any(good)
        tmin = min(tm(good));
        tmax = max(tm(good));
        thr = tmin + 0.10 * (tmax - tmin);         % first 10% of the run
        ref_mask = good & (tm <= thr);
        if ~any(ref_mask), ref_mask = good; end     % fallback: whole run
        ref = mean(bl(ref_mask));
    end
    if ~isfinite(ref) || ref == 0
        v = bl;                                     % fallback: no normalization
    else
        v = bl / ref;
    end
else
    v = t.(spec.col);
end
end


function hg = render_overlays(axs, samples, specs, colors)
% Draw per-sample histogram overlays into the four axes (used by the browse
% window). Returns a numel(samples)x4 cell of graphics handles for toggling.
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

    % Shared bin edges over pooled finite data
    pooled = [];
    for si = 1:n
        v = values_for_spec(samples(si).tbl, spec);
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
        v = values_for_spec(samples(si).tbl, spec);
        v = v(isfinite(v));
        N = histcounts(v, edges);
        if sum(N) > 0, N = N / sum(N); end
        hg{si, p} = histogram(ax, 'BinEdges', edges, 'BinCounts', N, ...
            'FaceColor', colors(si, :), 'FaceAlpha', 0.35, ...
            'EdgeAlpha', 0.2, 'DisplayName', names{si});
    end

    xlabel(ax, spec.xlabel, 'FontSize', 11);
    ylabel(ax, 'Fraction', 'FontSize', 11);
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
    'Position', [0 0 1100 820], 'CloseRequestFcn', @(s,e) gate_close(s));
movegui(gf, 'center');

% Manual 2x2 axes + per-plot x-limit boxes (normalized so they scale)
axs = gobjects(1, 4);
xlim_edits = cell(4, 2);
for p = 1:4
    [axpos, lblpos, minpos, maxpos] = cell_layout(p);
    ax = axes('Parent', gf, 'Units', 'normalized', 'Position', axpos);
    hold(ax, 'on'); box(ax, 'on'); ax.FontSize = 10;
    axs(p) = ax;

    uicontrol(gf, 'Style', 'text', 'Units', 'normalized', 'Position', lblpos, ...
        'String', 'x-lims:', 'BackgroundColor', 'w', 'FontSize', 8, ...
        'HorizontalAlignment', 'left');
    xlim_edits{p, 1} = uicontrol(gf, 'Style', 'edit', 'Units', 'normalized', ...
        'Position', minpos, 'String', '', 'FontSize', 8, ...
        'Tooltip', 'x min (blank = auto)', 'Callback', @(s,e) on_xlim_edit(gf, p));
    xlim_edits{p, 2} = uicontrol(gf, 'Style', 'edit', 'Units', 'normalized', ...
        'Position', maxpos, 'String', '', 'FontSize', 8, ...
        'Tooltip', 'x max (blank = auto)', 'Callback', @(s,e) on_xlim_edit(gf, p));
end

st = uicontrol(gf, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.02 0.065 0.6 0.05], 'String', '', 'FontSize', 10, ...
    'BackgroundColor', 'w', 'HorizontalAlignment', 'left');

% State in appdata
setappdata(gf, 'specs', specs);
setappdata(gf, 'sel_samples', sel_samples);
setappdata(gf, 'colors', colors);
setappdata(gf, 'axs', axs);
setappdata(gf, 'xlim_edits', xlim_edits);
setappdata(gf, 'xlims', cell(1, 4));      % per-plot [min max] (NaN = auto side)
setappdata(gf, 'hg_gate', cell(n, 4));    % per-sample histogram handles
setappdata(gf, 'rois', cell(1, 4));       % per-plot range gates
setappdata(gf, 'hist_state', []);
setappdata(gf, 'st_handle', st);
setappdata(gf, 'applied', false);
setappdata(gf, 'masks', {});
setappdata(gf, 'done', false);

for p = 1:4
    render_plot(gf, p);
end

% Per-plot gate buttons
labels = {'Gate: mass', 'Gate: norm baseline', 'Gate: slope', 'Gate: node dev'};
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
uiwait(gf);

if isvalid(gf)
    result.applied = getappdata(gf, 'applied');
    result.masks = getappdata(gf, 'masks');
    delete(gf);
else
    result.applied = false;
    result.masks = {};
end
end


function [axpos, lblpos, minpos, maxpos] = cell_layout(p)
% Normalized positions for one 2x2 cell: axes + x-limit control strip below.
if any(p == [1 3]), x = 0.07; else, x = 0.55; end   % left / right column
if any(p == [1 2]), yb = 0.58; else, yb = 0.17; end % top / bottom row
w = 0.40;
lblpos = [x,         yb, 0.095, 0.032];
minpos = [x+0.105,   yb, 0.13,  0.035];
maxpos = [x+0.255,   yb, 0.13,  0.035];
axpos  = [x,         yb+0.065, w, 0.30];
end


function render_plot(gf, p)
% (Re)draw the per-sample histogram overlays for one plot, re-binning within
% the current x-limits and preserving any gate drawn on it.
specs  = getappdata(gf, 'specs');
sel    = getappdata(gf, 'sel_samples');
colors = getappdata(gf, 'colors');
axs    = getappdata(gf, 'axs');
xlims  = getappdata(gf, 'xlims');
hgg    = getappdata(gf, 'hg_gate');
rois   = getappdata(gf, 'rois');
ax = axs(p);
spec = specs{p};
n = numel(sel);

% Delete old histogram handles for this plot (keep gate visuals)
for si = 1:n
    hstale = hgg{si, p};
    if ~isempty(hstale) && isvalid(hstale)
        delete(hstale);
    end
end

% Per-sample finite values + pooled range
vals = cell(1, n);
pooled = [];
for si = 1:n
    v = values_for_spec(sel(si).tbl, spec);
    v = v(isfinite(v));
    vals{si} = v;
    pooled = [pooled; v]; %#ok<AGROW>
end
if isempty(pooled)
    dlo = 0; dhi = 1;
else
    dlo = min(pooled); dhi = max(pooled);
    if dhi <= dlo, dhi = dlo + 1; end
end

% Resolve x-range (user override per side; NaN => data bound)
lo = dlo; hi = dhi;
if ~isempty(xlims{p})
    if isfinite(xlims{p}(1)), lo = xlims{p}(1); end
    if isfinite(xlims{p}(2)), hi = xlims{p}(2); end
end
if hi <= lo, hi = lo + 1; end
edges = linspace(lo, hi, 101);

for si = 1:n
    N = histcounts(vals{si}, edges);
    if sum(N) > 0, N = N / sum(N); end
    hgg{si, p} = histogram(ax, 'BinEdges', edges, 'BinCounts', N, ...
        'FaceColor', colors(si, :), 'FaceAlpha', 0.35, 'EdgeAlpha', 0.2, ...
        'DisplayName', sel(si).name);
end
setappdata(gf, 'hg_gate', hgg);

xlim(ax, [lo hi]);
xlabel(ax, spec.xlabel, 'FontSize', 11);
ylabel(ax, 'Fraction', 'FontSize', 11);
title(ax, spec.title, 'FontSize', 12);
if p == 1 && n > 1
    lg = legend(ax, 'show', 'Location', 'northeast', 'FontSize', 8);
    lg.AutoUpdate = 'off';
    lg.Interpreter = 'none';
end

% Redraw the gate visual (if any) so it tracks the new y-limits/bins
r = rois{p};
if roi_is_set(r)
    clear_roi(r);
    g = draw_gate_visual(ax, r.lo, r.hi);
    r.patch = g.patch;
    r.lines = g.lines;
    rois{p} = r;
    setappdata(gf, 'rois', rois);
end
end


function on_xlim_edit(gf, p)
eds = getappdata(gf, 'xlim_edits');
mn = str2double(eds{p, 1}.String);
mx = str2double(eds{p, 2}.String);

if isnan(mn) && isnan(mx)
    new = [];                       % both blank => auto
else
    new = [mn mx];                  % NaN on either side => auto that side
    if all(isfinite(new)) && new(2) <= new(1)
        warndlg('x-max must be greater than x-min.', 'Invalid range');
        return
    end
end

xlims = getappdata(gf, 'xlims');
xlims{p} = new;
setappdata(gf, 'xlims', xlims);
render_plot(gf, p);
gate_update_status(gf);
end


% ---- Gate helpers -------------------------------------------------------

function tf = roi_is_set(r)
tf = ~isempty(r) && isstruct(r) && isfield(r, 'type') && strcmp(r.type, 'range');
end


function clear_roi(r)
if isempty(r) || ~isstruct(r), return; end
if isfield(r, 'lines')
    for k = 1:numel(r.lines)
        if ~isempty(r.lines{k}) && isvalid(r.lines{k}), delete(r.lines{k}); end
    end
end
if isfield(r, 'patch') && ~isempty(r.patch) && isvalid(r.patch)
    delete(r.patch);
end
end


function g = draw_gate_visual(ax, lo, hi)
l1 = xline(ax, lo, '--r', sprintf('%.3g', lo), 'FontSize', 8, ...
    'HandleVisibility', 'off', 'LabelVerticalAlignment', 'bottom', ...
    'LabelHorizontalAlignment', 'right');
l2 = xline(ax, hi, '--b', sprintf('%.3g', hi), 'FontSize', 8, ...
    'HandleVisibility', 'off', 'LabelVerticalAlignment', 'bottom', ...
    'LabelHorizontalAlignment', 'left');
yl = ax.YLim;
pt = patch(ax, [lo hi hi lo], [yl(1) yl(1) yl(2) yl(2)], 'g', ...
    'FaceAlpha', 0.12, 'EdgeColor', 'none', 'HandleVisibility', 'off');
uistack(pt, 'bottom');
g = struct('patch', pt);
g.lines = {l1, l2};   % assign after construction to store the cell as-is
end


function gate_draw(gf, p)
specs = getappdata(gf, 'specs');
rois = getappdata(gf, 'rois');

% Reset any in-progress click mode and clear an existing gate on this plot
set(gf, 'WindowButtonDownFcn', '');
clear_roi(rois{p});
rois{p} = [];
setappdata(gf, 'rois', rois);

setappdata(gf, 'hist_state', struct('p', p, 'state', 0, 'lo', NaN, 'templine', []));
set(gf, 'WindowButtonDownFcn', @(s,e) gate_hist_click(gf, p));
st = getappdata(gf, 'st_handle');
st.String = sprintf('[%s]  Click to set lower cutoff', specs{p}.title);
end


function gate_hist_click(gf, p)
if ~isvalid(gf), return; end
hs = getappdata(gf, 'hist_state');
if isempty(hs) || hs.p ~= p, return; end

axs = getappdata(gf, 'axs');
ax  = axs(p);
clicked_ax = ancestor(gf.CurrentObject, 'axes');
if isempty(clicked_ax) || ~isequal(clicked_ax, ax), return; end

x  = ax.CurrentPoint(1, 1);
xl = ax.XLim;
if x < xl(1) || x > xl(2), return; end

st    = getappdata(gf, 'st_handle');
specs = getappdata(gf, 'specs');
ttl   = specs{p}.title;

if hs.state == 0
    hs.lo = x;
    hs.state = 1;
    hs.templine = xline(ax, x, '--r', sprintf('%.3g', x), 'FontSize', 8, ...
        'HandleVisibility', 'off', 'LabelVerticalAlignment', 'bottom', ...
        'LabelHorizontalAlignment', 'right');
    st.String = sprintf('[%s]  Lower: %.4g  —  click to set upper cutoff', ttl, x);
    setappdata(gf, 'hist_state', hs);
    drawnow;
    return
end

% state == 1: second click sets the upper cutoff
if x <= hs.lo
    st.String = sprintf('[%s]  Upper must be > lower (%.4g) — click again', ttl, hs.lo);
    setappdata(gf, 'hist_state', hs);
    drawnow;
    return
end
if ~isempty(hs.templine) && isvalid(hs.templine)
    delete(hs.templine);
end
g = draw_gate_visual(ax, hs.lo, x);
r = struct('type', 'range', 'lo', hs.lo, 'hi', x, 'patch', g.patch);
r.lines = g.lines;
rois = getappdata(gf, 'rois');
rois{p} = r;
setappdata(gf, 'rois', rois);
setappdata(gf, 'hist_state', []);
set(gf, 'WindowButtonDownFcn', '');
gate_update_status(gf);
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
        v = values_for_spec(t, specs{p});
        mask = mask & (v >= r.lo) & (v <= r.hi);
    end
    m{si} = mask;
end
end


function gate_update_status(gf)
% Don't overwrite status text while a histogram click sequence is active
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
if isvalid(gf)
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
