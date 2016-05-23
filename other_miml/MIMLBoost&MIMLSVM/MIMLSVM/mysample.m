clear;
libSVMPath = '../libsvm-mat-2.86-1';
addpath(libSVMPath);
addpath('../auxiliary')

% load('miml-image-data.mat')
svm.type='RBF';
% svm.type='LIN';
svm.para=0.2;%the value of "gamma"
cost=1;

config = setConfig();
disp('Reading training data');
config = read_sparse_naacl_data( config );
disp('Reading test data');
config = read_sparse_test_naacl_data(config);
% config = load_naacl_data( config );
% config = load_test_naacl_data(config);

% how to check if data loads properly
% a = full(cell2mat(config.bags(1,1)));


% shfl = randperm(size(bags,1));
% bags_shfl = bags(shfl,:);
% targets_t = targets';
% targets_shfl = targets_t(shfl,:);  %targets_t(:,shfl);
% targets_shfl=targets_shfl';



% [HammingLoss,RankingLoss,OneError,Coverage,Average_Precision,Outputs,Pre_Labels,tr_time,te_time]=...
% MIMLSVM(bags_shfl(1:100),targets_shfl(:,1:100),bags_shfl(160:200),targets_shfl(:,160:200),1/5,svm,cost);

[HammingLoss,RankingLoss,OneError,Coverage,Average_Precision,...
    Outputs,Pre_Labels,tr_time,te_time]=...
            MIMLSVM(config.train_bags,config.gold_y_labels',config.test_bags,...
                            config.test_gold_y_labels',1/5,svm,cost,config);