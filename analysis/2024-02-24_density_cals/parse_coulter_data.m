close all;
addpath(genpath('..\..\final_code'))

cc_paths = [...
    "A:\thomasu\raw_data\2024-02-21\coulter_counter\AA Mannitol PBS 1.#m4",...
    "A:\thomasu\raw_data\2024-02-21\coulter_counter\AA SMS pbs.#m4",...
    "A:\thomasu\raw_data\2024-02-21\coulter_counter\SS Mannitol PBS 1.#m4",...
    "A:\thomasu\raw_data\2024-02-21\coulter_counter\SS SMS pbs.#m4",...
    "A:\thomasu\raw_data\2024-02-22\coulter_counter\AA Mannitol PBS.#m4",...
    "A:\thomasu\raw_data\2024-02-22\coulter_counter\AA SMS PBS.#m4",...
    "A:\thomasu\raw_data\2024-02-22\coulter_counter\SS Mannitol PBS.#m4",...
    "A:\thomasu\raw_data\2024-02-22\coulter_counter\SS SMS PBS.#m4",...
    "A:\thomasu\raw_data\2024-02-23\coulter_counter\AA Mannitol PBS 1.#m4",...
    "A:\thomasu\raw_data\2024-02-23\coulter_counter\AA SMS PBS 1.#m4",...
    "A:\thomasu\raw_data\2024-02-23\coulter_counter\SS Mannitol PBS 1.#m4",...
    "A:\thomasu\raw_data\2024-02-23\coulter_counter\SS SMS PBS 1.#m4"];
labels_ = [...
    "aa1_mannitol", "aa1_sms", "ss1_mannitol", "ss1_sms", ...
    "aa2_mannitol", "aa2_sms", "ss2_mannitol", "ss2_sms", ...
    "aa3_mannitol", "aa3_sms", "ss3_mannitol", "ss3_sms"...
    ];

low_cutoff = 20; high_cutoff = 250;
avgs = zeros(length(labels_), 1);
for i = 1:2:length(labels_)
    % Mannitol
    Vol_data = load_coulter_data(cc_paths(i));
    count = Vol_data.count; vol_bins = Vol_data.volume_fL;
    count(vol_bins < low_cutoff | vol_bins > high_cutoff) = 0;

    fh = figure; hold on;
    h = histogram('BinEdges',[0;vol_bins]','BinCounts',count / sum(count), ...
        FaceColor='blue', EdgeColor='blue', DisplayName='Mannitol');
    h.FaceAlpha = 0.2; h.EdgeAlpha = 0.2;

    vols_adj = [0; vol_bins];
    bin_avgs = interp1(1:length(vols_adj), vols_adj, 1.5:1:length(vols_adj)-0.5);
    total_avg_mannitol = sum(count .* bin_avgs') / sum(count);
    avgs(i) = total_avg_mannitol;
    % -------------------------
    % SMS
    Vol_data = load_coulter_data(cc_paths(i+1));
    count = Vol_data.count; vol_bins = Vol_data.volume_fL;
    count(vol_bins < low_cutoff | vol_bins > high_cutoff) = 0;

    h = histogram('BinEdges',[0;vol_bins]','BinCounts',count / sum(count), ...
        FaceColor='red', EdgeColor='red', DisplayName='SMS');
    h.FaceAlpha = 0.2; h.EdgeAlpha = 0.2;
    xlim([0, 250])
    legend(Location='northoutside')
    ylabel('Probability density'); xlabel('Total volume (fl)')
    lb = char(labels_(i));
    title(lb(1:3))
    saveas(fh, "fig\" + string(lb(1:3)) + "_coulter_hist.jpg")

    vols_adj = [0; vol_bins];
    bin_avgs = interp1(1:length(vols_adj), vols_adj, 1.5:1:length(vols_adj)-0.5);
    total_avg_sms = sum(count .* bin_avgs') / sum(count);

    avgs(i+1) = total_avg_sms;
end
coulter_dict = dictionary(labels_, avgs');
save('data\coulter_preload.mat', 'coulter_dict');