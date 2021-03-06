function [config] = setConfig()

%%Make
% system('make clean')
% system('make')

%% Mention the Params in this file
    config.libSVMPath = '../libsvm-3.21/matlab';
    config.BETA = 1;
    config.EPOCHS_COUNT = 1;
    config.TEST_RELATIONS = -1;
    config.TrainFile = 'dataset/scene/scene-train.arff';
    config.TestFile = 'dataset/scene/scene-test.arff';
    config.resultFile = 'results/scene-results.data';
    config.w_1_cost=0.5;
    config.w_0_cost=0.5;
    
    config.c_range = [0:6];
%     config.c_range = [0:15];
    config.g_range = [-4:1];
    config.g = -1;      %% for multiclass we're using wd data only, hence g = 1/no_of_feature = 0.5
    config.vc_fold_size = 5;
    
    %%% Training prediction Type
    %%%     1 = W'phi(x)
    %%%     2 = Naacl prediction (joint inference)
    %%%     3 = Simple Multilabel
    config.trainingPredictionType=3;
end