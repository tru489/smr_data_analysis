close all;
addpath(genpath("..\..\helpers"));

%% Load data
tab1 = readtable('data_wnk\wnk_0715_means.csv');
tab2 = readtable('data_wnk\wnk_0726_means.csv');

%% Helpers
