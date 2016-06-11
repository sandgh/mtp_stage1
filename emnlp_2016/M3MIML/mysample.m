clear;


%% set params
svm.type='RBF';
% svm.type='LIN';
svm.para=1;
cost=1;


%% load data

% svm.dataset = 'text';
svm.dataset = 'image';

if(strcmp(svm.dataset,'text'))
    load('miml-text-data.mat');
    targets = target;
    clear target;
else
    load('miml-image-data.mat');
end

load('10CV.mat');

%% create train & test bags

shfl = Indexes;%randperm(size(bags,1));
bags_shfl = bags(shfl,:);
targets_t = targets';
targets_shfl = targets_t(shfl,:);  %targets_t(:,shfl);
targets_shfl = targets_shfl';

small_trn = 1:160;
small_test = 161:200;

full_trn = 1:800;
full_test = 1601:2000;

% full_trn = 1:200;
% full_test = 300:400;

%% run MIML-SVM
c = 5;
g = 1;
% c = [0, 5, 10, 15];
% g = [.1,  1, 10,  100,];

trn_time_counter = 1;
train_bags = bags_shfl(full_trn);
train_target = targets_shfl(:,full_trn)
[num_class,num_train]=size(train_target);

bag_size=zeros(1,num_train);
for i=1:num_train
    [tempsize,tempvalue]=size(train_bags{i,1});
    bag_size(1,i)=tempsize;
end
train_data = [];
for i=1:num_train
    for temp1=1:bag_size(1,i)
        train_data=[train_data;train_bags{i,1}(temp1,:)];
    end
end
g_std = getAvgSqEucDistAcc(train_data,size(train_data,1))
for j1 = 1:numel(c)
    cost = 2^c(1,j1);
    for i1=1:numel(g)
        gamma = g(1,i1)/(2*g_std);
        svm.para=gamma;
        
        [Alpha,Beta,Bias,tr_time]=M3MIML_train(train_bags, train_target,svm,cost);
        
        timestat.trn_time_results(trn_time_counter,:) = [cost, g(1,i1), tr_time];
        
        [HammingLoss,RankingLoss,OneError,Coverage,Average_Precision,Outputs,Pre_Labels,te_time]=...
            M3MIML_test(bags_shfl(full_trn),targets_shfl(:,full_trn),bags_shfl(full_test),targets_shfl(:,full_test),svm,Alpha,Beta,Bias)
        
        [ f_macro,precision,recall,f_micro ] = find_micro_and_macro(Pre_Labels, targets_shfl(:,full_test)');
        
        timestat.test_time_results(trn_time_counter,:) = [cost, g(1,i1), te_time, Average_Precision, f_macro,precision,recall,f_micro];
        
        trn_time_counter = trn_time_counter+1;
        
        save([svm.dataset, 'm3miml_timestat_small.mat'], 'timestat');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%