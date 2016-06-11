function [config] = setConfig()


%% Mention the Params in this file
% config.svmtype = 'rbf';
config.svmtype = 'lin';


% config.libSVMPath = '../../libsvm-3.21/matlab';
% addpath(config.libSVMPath);
%
% config.libLinearPath = '../../liblinear-2.1/matlab';
% addpath(config.libLinearPath);

config.EPOCHS_COUNT = 0;
config.c_range = [1];
% config.c_range = [1,3,5,10];
% config.g_range = [.1,1];
% config.g_range = [.01,.1,1,10,100,500];

config.file_name = 'dataset/miml-image-data.mat';

% % config.c_range = [0];
% config.file_name = 'dataset/v.small.data';
% config.file_name = 'dataset/train-riedel-10p.1.data';
% % config.file_name = 'dataset/kbp.10p2.data';
% config.file_name = 'dataset/reidel_trainSVM.data';
%
% config.validation_file_name = 'dataset/train-riedel-10p.2.data';
%
%  config.file_name = 'dataset/reidel_trainSVM.data';
% config.test_file_name = 'dataset/testSVM.pos_r.data';
% % config.test_file_name = 'dataset/v.small.data';
%
% % config.test_file_name = 'dataset/kbp.10p3.data';
%
config.result_file_name = 'results/02jun/image_macro_graph_generation';
% config.result_file_name = 'results/02jun/full_macro_lin_range_thresh_k0.2';

config.sntnce_k_prcnt = [0.2];

if(strcmp(config.svmtype,'rbf'))
    config.libSVMPath = '../../libsvm-mat-2.86-1';
else
    config.libSVMPath = '../../liblinear-2.1/matlab';
    config.g_range = [0];
end
addpath(config.libSVMPath);


end
