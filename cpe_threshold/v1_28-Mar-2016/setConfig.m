function [config] = setConfig()


%% Mention the Params in this file

config.libSVMPath = '../libsvm-3.21/matlab';

addpath(config.libSVMPath);

config.EPOCHS_COUNT = 2;
config.c_range = 0:1;

config.file_name = 'dataset/v.small.data1';
config.test_file_name = 'dataset/testSVM.pos_r.data1';
config.result_file_name = 'results/output.txt';


end