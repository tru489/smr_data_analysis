function peak_fit_metrics = S2_PeakFitter(run_params, xdata, ydata, ...
    baseline, peaks, peakwidth)
% Polynomial fitting for peaks and antipeaks within peakset and for local
% baseline
% 
% Arguments:
%   run_params (struct): running parameters for analysis
%   xdata (array(double)): indices of local frequency data
%   ydata (array(double)): local frequency data
%   baseline (array(double)): concatenated baseline sections to the left
%       and right of peakset
%   peaks (array(double)): local indices of peaks within frequency data
%       segment
%   peakwidth (array(double)): width of peakset in datapoints from
%       subtracting the two edge markers of the peakset
% Returns:
%   peak_fit_metrics (struct): contains metrics from this particular peak
%       fit. In particular:
%           pkidx_poly (array(double)): indices of peaks within data slice
%               for this peakset (from polynomial fit)
%           pkht_poly (array(double)): heights of peaks within this peakset
%               (from polynomial fit)
%           apkidx_poly (array(double)): indices of antipeaks within data 
%               slice for this peakset (from polynomial fit)
%           apkht_poly (array(double)): heights of antipeaks within this 
%               peakset (from polynomial fit)
%           baselineslope (array(double)): slope of linearly fit baseline
%           htdiff_poly (array(double)): mean node deviation (from 
%               polynomial fit)
%           ahtdiff_poly (array(double)): "FWHM" of peakset (i.e. distance
%               in datapoints between half-max of leading edge of first 
%               peak to half-max of trailing edge of last peak in peakset)
%           fit_baseline (array(double)): linear/polynomial fit of left and
%               right baselines. Same size as xdata and ydata (that is,
%               begins at beginning of detected baseline and ends at the
%               end of the detected baseline, not the entire segmented
%               peak)

%% Unload relevant run parameters
dispprogress = run_params.analysis_params.dispprogress;

%% Baseline fitting
% x and y baseline data
xbasedata = baseline;
ybasedata = ydata(baseline)';

% Identifies antipeak (i.e. node) indices
antipeaks = zeros(1, length(peaks) - 1);
for i = 1:(length(peaks) - 1)
    antiy_max_idx = find(ydata == max(ydata(peaks(i):peaks(i+1))));
    antipeaks(i) = antiy_max_idx(1);
end

% Provide a fit of the baseline for this peakset and subtract away
% from frequency
if string(class(run_params.backend.baseline_fit_type)) == "double"
    if run_params.backend.use_node_bl_fit
        an_weight = run_params.backend.node_bl_weight;
        start_add_idx = length(xbasedata) + 1;
        xbasedata_mod = xbasedata;
        xbasedata_mod(start_add_idx:start_add_idx+length(antipeaks)*an_weight-1) = ...
            repmat(xdata(antipeaks), an_weight, 1);
        ybasedata_mod = ybasedata;
        ybasedata_mod(start_add_idx:start_add_idx+length(antipeaks)*an_weight-1) = ...
            repmat(ydata(antipeaks), an_weight, 1);
        baseline_fit = polyfit(xbasedata_mod, ybasedata_mod, run_params.backend.baseline_fit_type);
    else
        baseline_fit = polyfit(xbasedata, ybasedata, run_params.backend.baseline_fit_type);
    end
end

% if run_params.backend.quad_baseline
%     baseline_fit = polyfit(xbasedata, ybasedata, 2);
% else
%     baseline_fit = polyfit(xbasedata, ybasedata, 1);
% end

baselineslope = baseline_fit(1);
baselinefreq = (polyval(baseline_fit, xdata))';
freqdata = ydata' - baselinefreq; 

% Baseline frequency data corrected for baseline regression
freqbasedata = ybasedata - baselinefreq(xbasedata);

if run_params.backend.alternative_smoothing
    freqsmth = sgolayfilt(freqdata, 3, 21);
else
    freqsmth = sgolayfilt(freqdata, 3, 11);
end

if dispprogress
    figure(1);

    % Plot whole frequency data, corrected with baseline regression
    subplot(2,2,3); hold off; plot(xdata, freqdata, '-')
    hold on

    % Plot baseline segments
    subplot(2,2,3); plot(xbasedata, freqbasedata, '.g');
    % subplot(2,2,3); plot(xdata, median(ydata)-baselinefreq, '--k');
    % subplot(2,2,3); plot(xdata, baselinefreq - baselinefreq, '-c');
    set(gca,'XLim',[0 length(xdata)]);
    set(gca,'YLim',[1.1*min(freqdata) max(freqdata)-0.1*min(freqdata)]);
end

% Half-height indices of peaks at the left and right of peakset
hahtwd_ll = find(freqsmth <= freqsmth(peaks(1))/2, 1);
hahtwd_rr = find(freqsmth <= freqsmth(peaks(end))/2, 1, 'last');

if dispprogress
    % Peak minima are in red
    subplot(2,2,3); plot(xdata(peaks), freqdata(peaks), '.r');
    
    % Antipeak maxima are in red
    subplot(2,2,3); plot(xdata(antipeaks), freqdata(antipeaks), '.r');
    
    % Left half-peak height as a green star
    subplot(2,2,3); plot(xdata(hahtwd_ll), freqdata(hahtwd_ll), '*g');
    
    % Right half-peak height as a green star
    subplot(2,2,3); plot(xdata(hahtwd_rr), freqdata(hahtwd_rr), '*g');
end

%% Polynomial fitting of peaks
% Width of segment of peak to be fitted
pk_fit_wd = round(peakwidth / 30);

pkidx_poly = zeros(1, length(peaks));
apkidx_poly = zeros(1, length(antipeaks));
pkht_poly = zeros(1, length(peaks));
apkht_poly = zeros(1, length(antipeaks));

% Iterate through peaks to extract peak metrics
for i = 1:length(peaks)
    % Actual segment of peak to be fitted
    pk_fit_segx = max(xdata(peaks(i)) - pk_fit_wd, 1): ...
        min((xdata(peaks(i)) + pk_fit_wd), length(xdata));
    pk_fit_segx = pk_fit_segx';
    pk_fit_segy = freqdata(pk_fit_segx);

    % Perform quarternary polynomial fit
    polypkeq = polyfit(1:length(pk_fit_segx), pk_fit_segy, 4);

    % Evaluate peak fit
    peakfit = polyval(polypkeq, 1:length(pk_fit_segx));

    % Find peak min value and location
    [pky, pkx] = min(peakfit);    
    
    % Adjust the position of peak apex (pkx is local to segment for fitting
    % of this specific peak within peakset, so this expression makes the
    % index global to the data segment)
    pkidx_poly(i) = pkx + xdata(peaks(i)) - pk_fit_wd - 1;

    % Define peak height as vertical distance from fitted peak minimum
    pkht_poly(i) = -1*pky;
    if dispprogress
        % Plot frequency data for this peak
        subplot(2,2,3); 
        plot(pk_fit_segx, pk_fit_segy, '*g') 
        
        % Plot peak fit
        subplot(2,2,3); 
        plot(pk_fit_segx, peakfit, 'r')                 
        
        % Plot peak apex
        subplot(2,2,3); 
        plot(pkidx_poly(i), pky, 'or')
    end
end

%% Polynomial fitting of antipeaks
% Fit antipeaks
for i = 1:length(antipeaks)
     % Actual segment of peak to be fitted
    antipk_fit_segx = max(xdata(antipeaks(i)) - pk_fit_wd,1): ...
        min(length(xdata), (xdata(antipeaks(i)) + pk_fit_wd));
    antipk_fit_segx = antipk_fit_segx';
    antipk_fit_segy = freqdata(antipk_fit_segx);
    
    if run_params.backend.antipeak_polyfit
        % Perform quarternary polynomial fit to fit antipeaks
        polyantipkeq = polyfit((-pk_fit_wd:pk_fit_wd), antipk_fit_segy, 4);
    
        % Evaluate peak fit
        antipeakfit = polyval(polyantipkeq, -pk_fit_wd:pk_fit_wd);
    
         % Find peak min value and location
        [apky, apkx] = max(antipeakfit);
    
        % Adjust the position of peak apex
        apkidx_poly(i) = xdata(antipeaks(i)) - pk_fit_wd + apkx - 1;
        apkht_poly(i) = apky;
    else
        antipeakfit = freqsmth(antipk_fit_segx);
        [apky, apkx] = max(antipeakfit);
        apkidx_poly(i) = xdata(antipeaks(i)) - pk_fit_wd + apkx - 1;
        apkht_poly(i) = apky; 
    end

    if dispprogress
        % Plot frequency data
        subplot(2,2,3); 
        plot(antipk_fit_segx, antipeakfit, 'r')   
        
        % Plot antipeak apices
        subplot(2,2,3); 
        plot(apkidx_poly(i), apky, 'or')       
    end
end

% htdiff_poly = 100*abs(diff(pkht_poly([1 end])))/mean(pkht_poly([1 end]));
htdiff_poly = mean(apkht_poly([1 end]));

% ahtdiff_poly = 100*abs(diff(apkht_poly([1 end])))/mean(apkht_poly([1 end]));
ahtdiff_poly = hahtwd_rr - hahtwd_ll;   % FWHM

hold off

peak_fit_metrics.pkidx_poly = pkidx_poly;
peak_fit_metrics.pkht_poly = pkht_poly;
peak_fit_metrics.apkidx_poly = apkidx_poly;
peak_fit_metrics.apkht_poly = apkht_poly;
peak_fit_metrics.baselineslope = baselineslope;
peak_fit_metrics.htdiff_poly = htdiff_poly;
peak_fit_metrics.ahtdiff_poly = ahtdiff_poly;
peak_fit_metrics.fit_baseline = baselinefreq;

return

end