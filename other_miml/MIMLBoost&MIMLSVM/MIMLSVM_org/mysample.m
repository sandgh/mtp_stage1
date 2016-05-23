clear;

%% add path

% libSVMPath = '../libsvm-3.21/matlab';
% libSVMPath = '../libsvm-mat-2.86-1';
libSVMPath = '../liblinear-2.1/matlab';

addpath(libSVMPath);
addpath('../auxiliary');


%% set params

ratio=0.2
% svm.type='RBF';
svm.type='LIN';
svm.para=0.2;%the value of "gamma"
cost=1;


%% load data

load('miml-image-data.mat')
load('10CV.mat')


%% create train & test bags

shfl = Indexes;%randperm(size(bags,1));
bags_shfl = bags(shfl,:);
targets_t = targets';
targets_shfl = targets_t(shfl,:);  %targets_t(:,shfl);
targets_shfl=targets_shfl';

small_trn = 1:160;
small_test = 161:200;

full_trn = 1:1600;
full_test = 1601:2000;

%% run MIML-SVM

[results, HammingLoss,RankingLoss,OneError,Coverage,Average_Precision,Outputs,Pre_Labels,tr_time,te_time]=...
MIMLSVM(bags_shfl(full_trn),targets_shfl(:,full_trn),bags_shfl(full_test),targets_shfl(:,full_test),ratio,svm,cost);

% [HammingLoss,RankingLoss,OneError,Coverage,Average_Precision,Outputs,Pre_Labels,tr_time,te_time]=...
% MIMLSVM(bags_shfl(small_trn),targets_shfl(:,small_trn),bags_shfl(small_test),targets_shfl(:,small_test),ratio,svm,cost);


% [HammingLoss,RankingLoss,OneError,Coverage,Average_Precision,...
%     Outputs,Pre_Labels,tr_time,te_time]=...
%             MIMLSVM(config.train_bags,config.gold_y_labels',config.test_bags,...
%                             config.test_gold_y_labels',1/5,svm,cost,config);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%