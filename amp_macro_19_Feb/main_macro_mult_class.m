clear;
clc;

[config] = setConfig();
fid_parameters = fopen(config.resultFile, 'w');
fprintf(fid_parameters,'\n-----------------------------------------------------------------------------------------------\n');
fclose(fid_parameters);

%% Configuration Setup
%%Set Configuration Params
[config] = setConfig();

%%Set the libSVM Path
addpath(config.libSVMPath);

fid_parameters = fopen(config.resultFile, 'a');
fprintf(fid_parameters,'\n-----------------------------------------------------------------------------------------------\n');


%% Reading Training File
disp('Reading Training file');

datasize_avg = 6000;
no_of_classes = 4;
[data, datasize] = generateTrainData(datasize_avg,1);

train_cnt_tot = 1:floor(datasize*2/3);
test_cnt = floor(datasize*2/3)+1:datasize;
cv_cnt = floor(datasize/2+1):floor(datasize*2/3);
train_cnt = 1:floor(datasize/2);

feature_vect = data(train_cnt_tot,1:2);
gold_db_matrix = data(train_cnt_tot,3:3+no_of_classes-1);

[count_of_sentences, NO_OF_RELNS] = size(gold_db_matrix);
config.NO_OF_RELNS = NO_OF_RELNS;
[x,max_feature] = size(feature_vect);
disp('Training File reading done');


%% Reading test file
% [gold_db_matrix_test, feature_vect_test] = scene_read_example(config.TestFile);
gold_db_matrix_test = data(test_cnt,3:3+no_of_classes-1);
feature_vect_test = data(test_cnt,1:2);

%%% plot test data
gold_db_matrix_test_plot = gold_db_matrix_test';
figure;
plot(feature_vect_test(find(gold_db_matrix_test_plot(2,:)),1),feature_vect_test(find(gold_db_matrix_test_plot(2,:)),2),'b+');
title('Test Data');
hold on;
plot(feature_vect_test(find(gold_db_matrix_test_plot(1,:)),1),feature_vect_test(find(gold_db_matrix_test_plot(1,:)),2),'ro');
plot(feature_vect_test(find(gold_db_matrix_test_plot(3,:)),1),feature_vect_test(find(gold_db_matrix_test_plot(3,:)),2),'y*');
%%uncomment for 4 labels
plot(feature_vect_test(find(gold_db_matrix_test_plot(4,:)),1),feature_vect_test(find(gold_db_matrix_test_plot(4,:)),2),'gx');
hold off;
drawnow;

%% To make it single class- testing on one relation
% NO_OF_RELNS=1;
config.NO_OF_RELNS = NO_OF_RELNS;
% gold_db_matrix=gold_db_matrix(:,NO_OF_RELNS);


%% create cross validation set
gold_db_matrix_trn = gold_db_matrix(train_cnt,:);
gold_db_matrix_cv = gold_db_matrix(cv_cnt,:);
feature_vect_trn = feature_vect(train_cnt,:);
feature_vect_cv = feature_vect(cv_cnt,:);

%% Find Theta micro
Theta_macro_trn_vect = calculateThetaMacro(gold_db_matrix_trn);
Theta_macro_cv_vect = calculateThetaMacro(gold_db_matrix_cv);

best_v_cv = 0;
plt_cnt = 0;

%% initialization for each class

c_vect = zeros(NO_OF_RELNS, 1);
fscore_vect = zeros(NO_OF_RELNS, 1);
v_vect = zeros(NO_OF_RELNS, 1);
opt_fn_vect = zeros(NO_OF_RELNS, 1);
w0_vect = zeros(NO_OF_RELNS, 1);
w1_vect = zeros(NO_OF_RELNS, 1);

%% cross validate over c
best_v_cv = zeros(NO_OF_RELNS,1);
for curr_c = config.c_range
    
    plt_cnt = plt_cnt+1;
    config.c = curr_c;
    
    %% SVM Training (One vs model_finalAll)
    for i=1:NO_OF_RELNS
        %%
        fprintf(fid_parameters,'\n,---------------------Class - %f-----------------------,\n',i);
        v_prev_prev = -1;
        v_prev = -1;
        config.v_trn_best=0;
        v_trn = 0;
        iteration_no = 0;
        config.w_1_cost=0.5;
        config.w_0_cost=0.5;
        iteration_no = 0;
        %% AMP
        while (abs(v_trn-v_prev) > .00001 &&  abs(v_trn-v_prev_prev) > .00001)  && iteration_no < 10
            iteration_no = iteration_no +1;
            
            v_prev_prev = v_prev;
            v_prev = v_trn;
            
            %%% this matrix will store the prediction obtained by SVM params
            predicted_matrix = zeros(NO_OF_RELNS,count_of_sentences);
            
            
            %%%find the first non zero label (SVM should have the first label non-zero, libsvm issue)
            nz_row = find(gold_db_matrix_trn(:,i),1);
            [model_final(i)] = trainSVM_macro([1;gold_db_matrix_trn(:,i)], 1, [feature_vect_trn(nz_row,:); feature_vect_trn], config);
            
            %%%pridiction for the current relation
            
            [predicted_matrix_trn_temp, accuracy_trn, decision_values_trn_temp] = svmpredict([1;gold_db_matrix_trn(:,i)], [feature_vect_trn(nz_row,:);feature_vect_trn], model_final(i));
            predicted_matrix_trn(i,:) = predicted_matrix_trn_temp(2:end,:);
            
            
            %% Multiclass prediction
            %%Calculate TP-TN-F_Score-W0-W1
            [TP_macro_trn, TN_macro_trn] = find_TP_TN_macro(gold_db_matrix_trn(:,i), predicted_matrix_trn(i,:)')
            [v_trn] = find_FScore_macro(config, TP_macro_trn, TN_macro_trn, Theta_macro_trn_vect(i,1));
            v_trn_obj = (1+config.BETA^2-v_trn)*TP_macro_trn + v_trn*Theta_macro_trn_vect(i,1)*TN_macro_trn;
            
            %%write model params
            writeModelParams(config,'w_1_cost',config.w_1_cost);
            writeModelParams(config,'w_0_cost',config.w_0_cost);
            writeModelParams(config,'v_trn',v_trn);
            writeModelParams(config,'v_trn_obj',v_trn_obj);
            fprintf(fid_parameters,'\n,----------------,\n');
            
            %%Update weights
            config.w_1_cost=1+config.BETA^2-v_trn;
            config.w_0_cost=v_trn*Theta_macro_trn_vect(i,1);
            denom = config.w_1_cost+config.w_0_cost;
            config.w_1_cost = config.w_1_cost/denom;
            config.w_0_cost = config.w_0_cost/denom;
%             config.model_final = model_final;
            
        end %%end of while
        
        %% Set best params from cross validation
        %%%find the first non zero label (SVM should have the first label non-zero, libsvm issue)
        nz_row = find(gold_db_matrix_trn(:,i),1);
        [model_final] = trainSVM_macro([1;gold_db_matrix_cv(:,i)], 1, [feature_vect_trn(nz_row,:); feature_vect_cv], config);
        
        %%%pridiction for the current relation
        
        [predicted_matrix_cv_temp, accuracy_cv, decision_values_cv_temp] = svmpredict([1;gold_db_matrix_cv(:,i)], [feature_vect_trn(nz_row,:);feature_vect_cv], model_final);
        predicted_matrix_cv(i,:) = predicted_matrix_cv_temp(2:end,:);
        
        
        [TP_macro_cv, TN_macro_cv] = find_TP_TN_macro(gold_db_matrix_cv(:,i), predicted_matrix_cv(i,:)')
        [v_cv] = find_FScore_macro(config, TP_macro_cv, TN_macro_cv, Theta_macro_cv_vect(i,1));
        v_cv_obj = (1+config.BETA^2-v_cv)*TP_macro_cv + v_cv*Theta_macro_cv_vect(i,1)*TN_macro_cv;
        
        if(best_v_cv(i,1)<v_cv)
            config.model_final(i) = model_final;
            v_vect(i) = v_trn;
            v_vect_cv(i) = v_cv;
            best_v_cv(i,1)=v_cv;
            config.best_c(i) = config.c;
        end
        
        
    end %% end of for loop all relations
    
    
%% Testing
Theta_macro_test_vect = calculateThetaMacro(gold_db_matrix_test);
[f_score] = test_macro_multi_class(config, gold_db_matrix_test, feature_vect_test, Theta_macro_test_vect);

%% Write params to file
writeModelParams(config, 'Test_f_score',f_score);
fid_parameters = fopen(config.resultFile, 'a');
fprintf(fid_parameters,'\n,------------------------------------------------,\n');
    
end          %%%end of c loop








