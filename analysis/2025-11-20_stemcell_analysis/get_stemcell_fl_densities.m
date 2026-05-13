close all;
addpath(genpath("..\..\helpers"));

paths = [...
    "A:\thomasu\raw_data\2025-11-06\stemcells_d2o_dmso\20251215.100501_mass_results\2025-11-06_stemcells_d2o_dmso.csv",...
    "A:\thomasu\raw_data\2025-11-06\stemcells_d2o_wnki\20251215.100528_mass_results\2025-11-06_stemcells_d2o_wnki.csv",...
    "A:\thomasu\raw_data\2025-11-20 - Margarete stem cells\human_dmso_d2o\20251215.095826_mass_results\2025-11-20 - Margarete stem cells_human_dmso_d2o.csv",...
    "A:\thomasu\raw_data\2025-11-20 - Margarete stem cells\human_dmso_h2o\20251215.100257_mass_results\2025-11-20 - Margarete stem cells_human_dmso_h2o.csv",...
    "A:\thomasu\raw_data\2025-11-20 - Margarete stem cells\human_wnki_d2o\20251215.100315_mass_results\2025-11-20 - Margarete stem cells_human_wnki_d2o.csv"];

slope = -188921.29865172753;
intc = 1.2525573509867985E+6;

ref_freqs = [...
    1049005, 1049005,...
    1046995, 1063695, 1046995];

for i = 1:length(paths)
    data_tab_tmp = readtable(paths(i));
    rf_tmp = ref_freqs(i);

    density = (rf_tmp - mean(data_tab_tmp.avg_baseline) - intc) / slope;
    fprintf('Density: %.5f\n', density)
end