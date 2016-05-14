function [config] = setConfig()


%% Mention the Params in this file

% config.libSVMPath = '../libsvm-3.21/matlab';
% addpath(config.libSVMPath);
% 
config.libLinearPath = '../liblinear-2.1/matlab';
addpath(config.libLinearPath);

config.EPOCHS_COUNT = 5;
config.c_range = [1];

config.file_name = 'dataset/v.small.data';
% config.file_name = 'dataset/train-riedel-10p.1.data';
% config.file_name = 'dataset/reidel_trainSVM.data';
config.test_file_name = 'dataset/testSVM.pos_r.data';
% config.test_file_name = 'dataset/v.small.data';
config.result_file_name = 'results/my_datasample_exp/small_k1_exp1';

config.sntnce_k_prcnt = 1;


end
