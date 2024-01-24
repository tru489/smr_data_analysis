close all
currentFolder = pwd;

%% grab L1210 readout paired txt file
fprintf('\nGetting paired sample...\n')
[input_info.sample_filename, input_info.sample_dir, ~] = uigetfile('../*.*','Select Readout_paired_[sample name].txt',' ');
sample_path = [input_info.sample_dir,'\',input_info.sample_filename];
opts = detectImportOptions(sample_path,'ReadVariableNames',true,'VariableNamingRule','preserve','Delimiter','\t');
sample = readtable(sample_path,opts);
name_split = strsplit(input_info.sample_filename,'.');   
sample_name = name_split{end-1};   

%% calculated conversion factor
median_vol_real = 1100; % assume fL for L1210
median_vol_au = median(sample.vol_au);
PMT_to_fL_calibration_factor = median_vol_real/median_vol_au;


%% Save conversion factor to L1210 data folder
volume_calibration_result = table();
volume_calibration_result.calibration_factor_fLoverAU = PMT_to_fL_calibration_factor;

cd(input_info.sample_dir)
out_file_name = 'PMT_to_fL_calibration_factor.txt';
writetable(volume_calibration_result,out_file_name, 'delimiter', '\t');
cd(currentFolder)