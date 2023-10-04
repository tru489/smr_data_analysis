function base_freq_dens_cal(run_params)
% Performs baseline density calibration from solutions of varying densities
% (e.g. solutions with varying concentrations of NaCl.
% Columns expected in datafile are (left to right; names are required): 
% soln_name, soln_density, feeback_freq, feeback_delay
%
% Arguments:
%   run_params (struct): running parameters for analysis

chip_id = input('Input chip ID: ', 's');

% Get calibration file
disp("Getting density baseline calibration data...")
[path, dir, ind] = uigetfile('../*.csv', ...
    "Select density baseline calibration file", ' ');
if ind ~= 0
    data_table = readtable(fullfile(dir, path));
else
    error("IOError: CSV file not selected")
end

% Create results dir
run_params.saving.save_abs_path = create_results_dir(run_params, dir);
save_dir = run_params.saving.save_abs_path;

density = data_table.density;
freq = data_table.feedback_freq;
delay = data_table.feedback_delay;

% Removes percent sign for json formatting
soln_names = strrep(data_table.soln_name, '%', 'pct');

% Create plot for linear regression
linreg_fh = figure('Position', [2365, 192, 978, 661]); hold on;
scatter(density, freq / 1e6, 50, "blue", "filled")
ax = gca; ax.FontSize = 12;
xlabel('Solution Density (g/cm^3)', 'FontSize', 14)
ylabel('Baseline Feedback Frequency (MHz)', 'FontSize', 14)

% Linear regression
[b, ~, ~, ~, stats] = regress(freq / 1e6, [ones(size(density)), density]);
regress_rng = linspace(density(1), density(end), 10);
lin_reg = b(1) + b(2) * regress_rng;
plot(regress_rng, lin_reg, 'LineWidth', 2, 'LineStyle', '--')
rsquared = stats(1);

% Display values on plot
textbox_str = ['R^2: ', num2str(rsquared), newline,'Slope: ', ...
    num2str(b(2) * 1e6), ' cm^3Hz/g', newline, 'Intercept: ' ...
    num2str(b(1) * 1e6) ' Hz'];
annotation(linreg_fh,'textbox',...
    [0.15 0.2 0.45 0.1],...
    'String', textbox_str,...
    'LineStyle','none',...
    'FontSize',18,...
    'FitBoxToText','off','Interpreter', 'tex');
saveas(linreg_fh, fullfile(save_dir, 'dens_cal_lin_reg.jpg'))

% Create delay plot
delay_fh = figure('Position', [2365, 192, 978, 661]);
scatter(density, delay, 50, "red", "filled")
xlabel('Solution Density (g/cm^3)', 'FontSize', 14)
ylabel('Feedback Delay', 'FontSize', 14)
saveas(delay_fh, fullfile(save_dir, 'dens_cal_delay.jpg'))

% Get creation date of csv raw data file
formatted_date = get_creation_date(fullfile(dir, path));

% Write values to json for future use
st.chip_id = chip_id;
st.date = formatted_date;
st.slope = b(2) * 1e6;
st.intercept = b(1) * 1e6;
st.soln_names = soln_names;
json_id = fopen(fullfile(save_dir, formatted_date + ...
    "_density_baseline_calibration.json"), 'w');
js_str = jsonencode(st, PrettyPrint=true);
fprintf(json_id, js_str);
fclose(json_id);

disp_dir_link(save_dir)

end