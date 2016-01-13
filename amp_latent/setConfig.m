function [config] = setConfig()

%%Make
system('make clean')
system('make')

%% Mention the Params in this file
    config.libSVMPath = '../libsvm-3.21/matlab';
    config.BETA = 1;
    config.EPOCHS_COUNT = 20;
    config.TEST_RELATIONS = -1;
    config.TrainFile = 'dataset/v.small.data1';
    config.w_1_cost=1;
    config.w_0_cost=1;
    
    %%% Training prediction Type
    %%%     1 = W'phi(x)
    %%%     2 = Naacl prediction (joint inference)
    config.trainingPredictionType=1;
end