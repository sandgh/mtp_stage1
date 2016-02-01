clear;
clc;

%% Configuration Setup
%%Set Configuration Params
[config] = setConfig();

%%Set the libSVM Path
addpath(config.libSVMPath);

fid_parameters = fopen(config.resultFile, 'w');
fprintf(fid_parameters,'\n-----------------------------------------------------------------------------------------------\n');


%% Reading Training File
disp('Reading Training file');
% [gold_db_matrix, feature_vect] = scene_read_example(config.TrainFile);

data = generateTrainData(6000,1);

train_cnt_tot = 1:12000;
test_cnt = 12001:18000;
cv_cnt = 9001:12000;
train_cnt = 1:9000;

feature_vect = data(train_cnt_tot,1:2);
gold_db_matrix = data(train_cnt_tot,3:5);

[count_of_sentences, NO_OF_RELNS] = size(gold_db_matrix);
config.NO_OF_RELNS = NO_OF_RELNS;
[x,max_feature] = size(feature_vect);
disp('Training File reading done');

%% Reading test file
% [gold_db_matrix_test, feature_vect_test] = scene_read_example(config.TestFile);
gold_db_matrix_test = data(test_cnt,3:5);
feature_vect_test = data(test_cnt,1:2);

%% To make it single class- testing on one relation
% NO_OF_RELNS=1;
config.NO_OF_RELNS = NO_OF_RELNS;
% gold_db_matrix=gold_db_matrix(:,NO_OF_RELNS);


%% create cross validation set
gold_db_matrix_trn = gold_db_matrix(train_cnt,:);
gold_db_matrix_cv = gold_db_matrix(cv_cnt,:); 
feature_vect_trn = feature_vect(train_cnt,:);
feature_vect_cv = feature_vect(cv_cnt,:);

% [gold_db_matrix_trn, gold_db_matrix_cv, feature_vect_trn, feature_vect_cv] = createValidationSet(gold_db_matrix, feature_vect, config);
% save('cv_set.mat', 'gold_db_matrix_trn', 'gold_db_matrix_cv', 'feature_vect_trn', 'feature_vect_cv');
% load('cv_set.mat');


%% Find Theta micro
Theta_micro_trn = calculateTheta(gold_db_matrix_trn);
Theta_micro_cv = calculateTheta(gold_db_matrix_cv);


%%
v_prev_prev = -1;
v_prev = -1;
config.v_trn_best=0;

%% Optimization
iteration_no = 0;

while abs(config.v_trn_best-v_prev) > .00001 &&  abs(config.v_trn_best-v_prev_prev) > .00001
    iteration_no = iteration_no +1;
    
    v_prev_prev = v_prev;
    v_prev = config.v_trn_best;
    
    %%% this matrix will store the prediction obtained by SVM params
    %%% i.e. the w'phi(x) for all relations for every sentence
    %%% We'll take the max as the class while predicting
    predicted_matrix = zeros(NO_OF_RELNS,count_of_sentences);
    
    %% tuning C
    
    best_v_cv = 0;
    for curr_c = config.c_range
        
        config.c = curr_c;
        
%         for curr_g = config.g_range
%             
%             config.g = curr_g;
            
            
            %% SVM Training (One vs model_finalAll)
            for i=1:NO_OF_RELNS
                
                
                %%%find the first non zero label (SVM should have the first label non-zero, libsvm issue)
                nz_row = find(gold_db_matrix_trn(:,i),1);
                
                [model_final(i)] = trainSVM([1;gold_db_matrix_trn(:,i)], 1, [feature_vect_trn(nz_row,:); feature_vect_trn], config);
                
                %%%pridiction for the current relation
                
                [predicted_matrix_trn_temp, accuracy_trn, decision_values_trn] = svmpredict([1;gold_db_matrix_trn(:,i)], [feature_vect_trn(nz_row,:);feature_vect_trn], model_final(i));
                predicted_matrix_trn(i,:) = predicted_matrix_trn_temp(2:end,:);
                
                
                [predicted_matrix_cv_temp, accuracy_cv, decision_values_cv_temp] = svmpredict([1;gold_db_matrix_cv(:,i)], [feature_vect_trn(nz_row,:);feature_vect_cv], model_final(i));
                predicted_matrix_cv(i,:) = predicted_matrix_cv_temp(2:end,:);
                decision_values_cv(i,:) = decision_values_cv_temp(2:end,:);
                
            end
            
            
            %% Multilabel prediction
            %%Calculate TP-TN-F_Score-W0-W1
            [TP_micro_trn, TN_micro_trn] = find_TP_TN_micro(gold_db_matrix_trn, predicted_matrix_trn')
            [TP_micro_cv, TN_micro_cv] = find_TP_TN_micro(gold_db_matrix_cv, predicted_matrix_cv')
            
            %%% F-Score
            [v_trn] = find_FScore_micro(config, TP_micro_trn, TN_micro_trn, Theta_micro_trn)
            [v_cv] = find_FScore_micro(config, TP_micro_cv, TN_micro_cv, Theta_micro_cv);
           % v_cv = (1+config.BETA^2-v_cv)*TP_micro_cv + v_cv*Theta_micro_cv*TN_micro_cv
            
            
            if(best_v_cv<v_cv)
                model_final_trn = model_final;
                config.v_trn_best = v_trn;
                config.TP_micro_trn = TP_micro_trn;
                config.TN_micro_trn = TN_micro_trn;
                config.TP_micro_cv = TP_micro_cv;
                config.TN_micro_cv = TN_micro_cv;
                best_v_cv=v_cv;
                config.best_c = config.c;
                config.best_g = config.g;
            end
            
%             writeModelParams(config,'c',config.c);
%             writeModelParams(config,'g',config.g);
%             writeModelParams(config,'v_trn',v_trn);
%             writeModelParams(config,'v_cv',v_cv);
        
%         end      %%%end of g loop
        
    end          %%%end of c loop
    
    writeModelParams(config,'best_c',config.best_c);
    writeModelParams(config,'best_g',config.best_g);
    writeModelParams(config,'v_trn_best',config.v_trn_best);
    writeModelParams(config,'best_v_cv',best_v_cv);
    
    %% Set best params from cross validation
    config.w_1_cost=1+config.BETA^2-config.v_trn_best;
    config.w_0_cost=config.v_trn_best*Theta_micro_trn;
    denom = config.w_1_cost+config.w_0_cost;
    config.w_1_cost = config.w_1_cost/denom;
    config.w_0_cost = config.w_0_cost/denom;
    config.model_final = model_final_trn;
    
    writeModelParams(config,'w_1_cost',config.w_1_cost);
    writeModelParams(config,'w_0_cost',config.w_0_cost);
    
    %% Testing
    
%     gold_db_matrix_test=gold_db_matrix_test(:,NO_OF_RELNS);
    Theta_micro_test = calculateTheta(gold_db_matrix_test);
    [f_score] = amp_latent_test_mult_label(config, gold_db_matrix_test, feature_vect_test, Theta_micro_test);
    
    %% Write params to file
    writeModelParams(config, 'Test_f_score',f_score);
    fid_parameters = fopen(config.resultFile, 'a');
    fprintf(fid_parameters,'\n------------------------------------------------\n');
    
    
end %end of while






























