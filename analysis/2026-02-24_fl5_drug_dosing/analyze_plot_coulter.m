close all;
addpath(genpath("..\..\helpers"));

%% ================= USER SETTINGS =================
dataDir = "C:\Users\Blue\MIT Dropbox\Thomas Usherwood\Shared FL5 data-T&T\Processed data\2026-02-18to23_drug_concentrations\summary_stats";

%% ================= OUTPUT FOLDERS (next to THIS SCRIPT) =================
scriptDir = fileparts(mfilename('fullpath'));

figDir = fullfile(scriptDir, "fig");
if ~exist(figDir, 'dir'); mkdir(figDir); end

outCsvDir = fullfile(scriptDir, "processed_data");
if ~exist(outCsvDir, 'dir'); mkdir(outCsvDir); end

%% ================= LOAD FILES =================
files = dir(fullfile(dataDir, "*_stats.csv"));
if isempty(files)
    error("No *_stats.csv files found in: %s", dataDir);
end

Data = struct();

%% ================= LOAD + ORGANIZE =================
for f = 1:numel(files)

    fname = files(f).name;
    fpath = fullfile(dataDir, fname);

    % Parse: <drug>_<time>_stats.csv  (drug may contain hyphens)
    tok = regexp(fname, '^(.*)_(.*)_stats\.csv$', 'tokens', 'once');
    if isempty(tok), continue; end

    drugRaw = tok{1};
    drugKey = matlab.lang.makeValidName(strrep(drugRaw, '-', ''));  % valid field
    timeStr = tok{2};
    tHours  = parseTime(timeStr);

    T = readtable(fpath, 'VariableNamingRule','preserve');

    meanRow = strcmp(string(T{:,1}), "Mean");
    nRow    = strcmp(string(T{:,1}), "SampleSize");
    if ~any(meanRow) || ~any(nRow)
        warning("Skipping %s (missing Mean or SampleSize rows)", fname);
        continue
    end

    meanValsByCol = T{meanRow, 2:end};  % 1 x nCols
    nValsByCol    = T{nRow,    2:end};  % 1 x nCols
    colNames      = T.Properties.VariableNames(2:end);

    % Maps: canonical conc label -> vector of replicate mean values / replicate Ns
    mMean = containers.Map('KeyType','char','ValueType','any');
    mN    = containers.Map('KeyType','char','ValueType','any');

    for c = 1:numel(colNames)
        vn = colNames{c};

        % concentration token is between '_' and '_rep#'
        % e.g. ..._26h_1uM-STOCK2S_rep1  -> token "1uM-STOCK2S"
        ctok = regexp(vn, '_([^_]+)_rep\d+', 'tokens', 'once');
        if isempty(ctok), continue; end

        rawToken = string(ctok{1}); % e.g. "1uM-STOCK2S" or "dmso"
        concLbl  = canonicalConcLabelFromToken(rawToken); % -> "1uM", "250nM", "DMSO"

        key = char(concLbl);
        if ~isKey(mMean, key)
            mMean(key) = [];
            mN(key)    = [];
        end

        mMean(key) = [mMean(key), meanValsByCol(c)];
        mN(key)    = [mN(key),    nValsByCol(c)];
    end

    concs = string(keys(mMean));
    if isempty(concs)
        warning("Skipping %s (no concentration columns parsed)", fname);
        continue
    end

    % Sort concs: DMSO first, then ascending in microM
    conc_uM = arrayfun(@concToMicroM, concs);
    [~, ord] = sort(conc_uM, 'ascend');
    concs = concs(ord);

    tp = struct();
    tp.hours   = tHours;
    tp.concs   = concs;                      % 1xN string
    tp.repMean = cell(1, numel(concs));      % each cell: [1xR]
    tp.repN    = cell(1, numel(concs));      % each cell: [1xR]

    for k = 1:numel(concs)
        tp.repMean{k} = mMean(char(concs(k)));
        tp.repN{k}    = mN(char(concs(k)));
    end

    if ~isfield(Data, drugKey)
        Data.(drugKey).drugRaw = drugRaw;
        Data.(drugKey).timepoints = tp;
    else
        Data.(drugKey).timepoints(end+1) = tp;
    end
end

%% ================= PLOT + EXPORT =================
drugKeys = fieldnames(Data);

for d = 1:numel(drugKeys)

    dk = drugKeys{d};
    drugTitle = string(Data.(dk).drugRaw);

    % Sort timepoints by time
    tps = Data.(dk).timepoints;
    times = [tps.hours];
    [times, tOrd] = sort(times);
    tps = tps(tOrd);

    % Global concentration order for this drug:
    % union across timepoints, sorted with DMSO first and ascending concentration
    concLabels = collectSortedConcsAcrossTimepoints(tps);

    % DMSO must exist
    if ~any(concLabels == "DMSO")
        error("No DMSO found for drug %s", dk);
    end

    cmap = lines(numel(concLabels));

    % 1) Raw volume
    plotDrugTimecourseAndExportCSV(tps, times, concLabels, cmap, ...
        "raw_volume", drugTitle, figDir, outCsvDir);

    % 2) Normalized volume (to DMSO at each timepoint)
    plotDrugTimecourseAndExportCSV(tps, times, concLabels, cmap, ...
        "norm_volume", drugTitle, figDir, outCsvDir);

    % 3) Special normalization (26h normalized to 3h DMSO)
    plotDrugTimecourseAndExportCSV(tps, times, concLabels, cmap, ...
        "special_norm_volume", drugTitle, figDir, outCsvDir);

    % 4) Cell count
    plotDrugTimecourseAndExportCSV(tps, times, concLabels, cmap, ...
        "cell_count", drugTitle, figDir, outCsvDir);

    % 5) Normalized cell count (to DMSO at each timepoint)
    plotDrugTimecourseAndExportCSV(tps, times, concLabels, cmap, ...
        "norm_cell_count", drugTitle, figDir, outCsvDir);
end

%% ================= LOCAL FUNCTIONS (keep at END of file) =================

function hours = parseTime(timeStr)
    timeStr = string(timeStr);
    if contains(timeStr, "min")
        val = str2double(erase(timeStr, "min"));
        hours = val/60;
    elseif contains(timeStr, "h")
        hours = str2double(erase(timeStr, "h"));
    else
        error("Unknown time format: %s", timeStr);
    end
end

function concLbl = canonicalConcLabelFromToken(rawToken)
    % Handles tokens like:
    %   "dmso"
    %   "1uM-STOCK2S"
    %   "250nM-STOCK2S"
    %   "5uM"
    t = lower(strtrim(string(rawToken)));

    if contains(t, "dmso")
        concLbl = "DMSO";
        return
    end

    % Capture a leading numeric+unit at the start, ignoring suffixes like "-STOCK2S"
    % Examples matched: "1um", "250nm", "0.5um"
    tok = regexp(t, '^(\d+\.?\d*)\s*(um|nm)', 'tokens', 'once');
    if isempty(tok)
        % best effort: return the raw token uppercased
        concLbl = upper(rawToken);
        return
    end

    numStr = tok{1};
    unit   = tok{2};

    if strcmp(unit, "um")
        concLbl = string(numStr) + "uM";
    else
        concLbl = string(numStr) + "nM";
    end
end

function x = concToMicroM(concLabel)
    % DMSO -> -Inf (forces first)
    lab = string(concLabel);
    if strcmpi(lab, "DMSO")
        x = -Inf;
        return
    end

    tok = regexp(lab, '^(\d+\.?\d*)(uM|nM)$', 'tokens', 'once');
    if isempty(tok)
        x = +Inf;
        return
    end

    val  = str2double(tok{1});
    unit = tok{2};
    if strcmp(unit, "nM")
        val = val/1000;
    end
    x = val;
end

function concLabels = collectSortedConcsAcrossTimepoints(tps)
    allConcs = strings(0);
    for i = 1:numel(tps)
        allConcs = [allConcs, string(tps(i).concs)];
    end
    allConcs = unique(allConcs, 'stable');

    % Ensure canonical casing (DMSO, nM/uM)
    % (Should already be canonical, but keep safe)
    allConcs = arrayfun(@(s) string(s), allConcs);

    % Sort with DMSO first and ascending microM
    conc_uM = arrayfun(@concToMicroM, allConcs);
    [~, ord] = sort(conc_uM, 'ascend');
    concLabels = allConcs(ord);
end

function plotDrugTimecourseAndExportCSV(tps, times, concLabels, cmap, mode, drugTitle, figDir, outCsvDir)

    % Precompute special normalization reference (3h DMSO)
    ref3hDmso = NaN;
    if mode == "special_norm_volume"
        idx3h = find(times == 3, 1);
        if ~isempty(idx3h)
            tp3 = tps(idx3h);
            idxDmso3 = find(string(tp3.concs) == "DMSO", 1);
            if ~isempty(idxDmso3)
                ref3hDmso = mean(tp3.repMean{idxDmso3}, 'omitnan');
            end
        end
    end

    fig = figure('Position',[100 100 1200 600]);
    hold on;

    lineHandles = gobjects(1, numel(concLabels));

    % Build long-form table rows for export
    DrugCol = strings(0);
    ModeCol = strings(0);
    ConcCol = strings(0);
    TimeCol = [];
    RepIdxCol = [];
    ValueCol = [];
    MeanLineCol = [];

    for c = 1:numel(concLabels)

        yLine = nan(1, numel(times));

        for ti = 1:numel(times)

            tp = tps(ti);
            tpConcs = string(tp.concs);

            idxConc = find(tpConcs == concLabels(c), 1);
            idxDmso = find(tpConcs == "DMSO", 1);
            if isempty(idxConc) || isempty(idxDmso)
                continue
            end

            switch mode
                case "raw_volume"
                    reps = tp.repMean{idxConc};
                    yScatter = reps;
                    yLine(ti) = mean(reps,'omitnan');

                case "norm_volume"
                    reps = tp.repMean{idxConc};
                    dmsoMean = mean(tp.repMean{idxDmso},'omitnan');
                    yScatter = reps ./ dmsoMean;
                    yLine(ti) = mean(yScatter,'omitnan');

                case "special_norm_volume"
                    reps = tp.repMean{idxConc};

                    if times(ti) == 26 && ~isnan(ref3hDmso)
                        normFactor = ref3hDmso;
                    else
                        normFactor = mean(tp.repMean{idxDmso},'omitnan');
                    end

                    yScatter = reps ./ normFactor;
                    yLine(ti) = mean(yScatter,'omitnan');

                case "cell_count"
                    reps = tp.repN{idxConc};
                    yScatter = reps;
                    yLine(ti) = mean(reps,'omitnan');

                case "norm_cell_count"
                    reps = tp.repN{idxConc};
                    dmsoMeanN = mean(tp.repN{idxDmso},'omitnan');
                    yScatter = reps ./ dmsoMeanN;
                    yLine(ti) = mean(yScatter,'omitnan');

                otherwise
                    error("Unknown mode: %s", mode);
            end

            % Scatter replicate points (no legend entries), match line color
            scatter(times(ti) * ones(size(yScatter)), yScatter, 60, ...
                'filled', ...
                'MarkerFaceColor', cmap(c,:), ...
                'MarkerEdgeColor', 'none', ...
                'MarkerFaceAlpha', 0.35, ...
                'HandleVisibility', 'off');

            % Export rows for each replicate
            nReps = numel(yScatter);
            DrugCol = [DrugCol; repmat(drugTitle, nReps, 1)];
            ModeCol = [ModeCol; repmat(string(mode), nReps, 1)];
            ConcCol = [ConcCol; repmat(concLabels(c), nReps, 1)];
            TimeCol = [TimeCol; repmat(times(ti), nReps, 1)];
            RepIdxCol = [RepIdxCol; (1:nReps)'];
            ValueCol = [ValueCol; yScatter(:)];
            MeanLineCol = [MeanLineCol; repmat(yLine(ti), nReps, 1)];
        end

        % Mean line (legend handle)
        lineHandles(c) = plot(times, yLine, '-o', ...
            'LineWidth', 2, ...
            'Color', cmap(c,:), ...
            'MarkerFaceColor', cmap(c,:), ...
            'DisplayName', concLabels(c));
    end

    xlabel('Time (h)');

    switch mode
        case "raw_volume"
            ylabel('Mean Volume (fL)');
            title(drugTitle + " — Raw Volume");
        case "norm_volume"
            ylabel('Normalized Volume (fL)');
            title(drugTitle + " — Normalized to DMSO");
        case "special_norm_volume"
            ylabel('Normalized Volume (fL), modified');
            title(drugTitle + " — Special Normalization");
        case "cell_count"
            ylabel('Cell Count');
            title(drugTitle + " — Cell Count");
        case "norm_cell_count"
            ylabel('Normalized Cell Count');
            title(drugTitle + " — Normalized Cell Count");
    end

    grid on;
    legend(lineHandles, concLabels, 'Location','eastoutside');

    safeDrug = matlab.lang.makeValidName(regexprep(char(drugTitle), '\s+', '_'));

    % Save JPG
    jpgName = safeDrug + "_" + mode + ".jpg";
    saveas(fig, fullfile(figDir, jpgName));

    % Save CSV (long format)
    outTable = table(DrugCol, ModeCol, ConcCol, TimeCol, RepIdxCol, ValueCol, MeanLineCol, ...
        'VariableNames', {'Drug','PlotMode','Concentration','Time_h','Replicate','Value','MeanLine'});
    csvName = safeDrug + "_" + mode + ".csv";
    writetable(outTable, fullfile(outCsvDir, csvName));
end