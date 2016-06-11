function [config] = setConfig()


%% Mention the Params in this file

% config.svmtype = 'rbf';
config.svmtype = 'lin';

% config.libSVMPath = '../libsvm-3.21/matlab';
% addpath(config.libSVMPath);

% config.libLinearPath = '../liblinear-2.1/matlab';
% addpath(config.libLinearPath);

config.EPOCHS_COUNT = 3;
% config.c_range = [1];
config.c_range = [0,2,5,10,15];
% config.g_range = [.1,1];
config.g_range = [.1,1,10,100,500];
% config.file_name = 'dataset/v.small.data';
% config.file_name = 'dataset/train-riedel-10p.1.data';
% config.file_name = 'dataset/reidel_trainSVM.data';
% 
% config.validation_file_name = 'dataset/train-riedel-10p.2.data';
% 
% 
% config.test_file_name = 'dataset/testSVM.pos_r.data';
% % config.test_file_name = 'dataset/v.small.data';
config.file_name = 'dataset/miml-image-data.mat';
% config.file_name = 'dataset/miml-text-data.mat';

% config.result_file_name = 'results/27may/image_micro_rbf_validation';
% config.result_file_name = 'results/27may/10p_validation_micro';
config.result_file_name = 'results/31may/image_micro_lin_range_thresh';

config.sntnce_k_prcnt = 1;


if(strcmp(config.svmtype,'rbf'))
    config.libSVMPath = '../../libsvm-mat-2.86-1';
else
    config.libSVMPath = '../../liblinear-2.1/matlab';
    config.g_range = [0];
end
addpath(config.libSVMPath);


end