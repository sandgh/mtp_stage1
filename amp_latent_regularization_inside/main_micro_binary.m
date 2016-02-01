clear;
clc;

%% Configuration Setup
%%Set Configuration Params
[config] = setConfig();

%%Set the libSVM Path
addpath(config.libSVMPath);

fid_parameters = fopen(config.resultFile, 'w');
%% Reading Training File
fprintf(fid_parameters,'\n-----------------------------------------------------------------------------------------------\n');

%% Reading Training File
disp('Reading Training file');
% [gold_db_matrix, feature_vect, NO_OF_RELNS, num_egs, max_feature, count_of_sentences, no_sentences_per_example, TEST_RELATIONS] = readTrainingData(config);
[gold_db_matrix, feature_vect] = scene_read_example(config.TrainFile);
[count_of_sentences, NO_OF_RELNS] = size(gold_db_matrix);
config.NO_OF_RELNS = NO_OF_RELNS;
[x,max_feature] = size(feature_vect);
disp('Training File reading done');

%% Reading test file
[gold_db_matrix_test, feature_vect_test] = scene_read_example(config.TestFile);

%% To make it single class- testing on one relation
NO_OF_RELNS=1;
config.NO_OF_RELNS = NO_OF_RELNS;
gold_db_matrix=gold_db_matrix(:,NO_OF_RELNS);
[gold_db_matrix_trn, gold_db_matrix_cv, feature_vect_trn, feature_vect_cv] = createValidationSet(gold_db_matrix, feature_vect, config);
%% Find Theta micro
Theta_micro_trn = calculateTheta(gold_db_matrix_trn);
Theta_micro_cv = calculateTheta(gold_db_matrix_cv);


v_prev_prev = -1;
v_prev = -1;
config.v_trn_best=0;

%% Optimization
iteration_no = 0;

while abs(config.v_trn_best-v_prev) > .00001 &&  abs(config.v_trn_best-v_prev_prev) > .00001
    iteration_no = iteration_no +1;
    
    v_prev_prev = v_prev;
    v_prev = config.v_trn_best;
    
    %% initilize W and bias
    % W = zeros(NO_OF_RELNS, max_feature);
    % bias = zeros(NO_OF_RELNS, 1);

    %%% this matrix will store the prediction obtained by SVM params
    %%% i.e. the w'phi(x) for all relations for every sentence
    %%% We'll take the max as the class while predicting
    predicted_matrix = zeros(NO_OF_RELNS,count_of_sentences);

    
    %% tuning C
    
    best_v_cv = 0;
    best_minimizing_function = 0;
    for curr_c = config.c_range
        
        config.c = curr_c;
        
        for curr_g = config.g_range
            
            config.g = curr_g;
    %% SVM Training (One vs model_finalAll)    
    for i=1:NO_OF_RELNS

%         [w, bias_curr, noPositiveFlag,model_final(i)] = trainSVM(count_of_sentences, gold_db_matrix(:,i), 1, feature_vect, config);
                [model_final(i)] = trainSVM(gold_db_matrix_trn(:,i), 1, feature_vect_trn, config);

    
%         W(i,:) = w;
%         bias(i,:) = bias_curr;
        %%%pridiction for the current relation
        [predicted_matrix_trn(i,:), accuracy_trn, decision_values_trn] = svmpredict(gold_db_matrix_trn(:,i), feature_vect_trn, model_final(i));
        [predicted_matrix_cv(i,:), accuracy_cv, decision_values_cv] = svmpredict(gold_db_matrix_cv(:,i), feature_vect_cv, model_final(i));
%         predicted_matrix(i,:)=sign(W(i,:) * feature_vect' +bias(i));

    end


   %% Multilabel prediction
   %%Calculate TP-TN-F_Score-W0-W1
   %%% TP-TN 
   [TP_micro_trn, TN_micro_trn] = find_TP_TN_micro(gold_db_matrix_trn, predicted_matrix_trn')
   [TP_micro_cv, TN_micro_cv] = find_TP_TN_micro(gold_db_matrix_cv, predicted_matrix_cv')

   %%% F-Score
            [v_trn] = find_FScore_micro(config, TP_micro_trn, TN_micro_trn, Theta_micro_trn)
            [v_cv] = find_FScore_micro(config, TP_micro_cv, TN_micro_cv, Theta_micro_cv);
           minimizing_function = (1+config.BETA^2-v_cv)*TP_micro_cv + v_cv*Theta_micro_cv*TN_micro_cv
            
            
            if(best_minimizing_function<minimizing_function)
                model_final_trn = model_final;
                config.v_trn_best = v_trn;
                config.TP_micro_trn = TP_micro_trn;
                config.TN_micro_trn = TN_micro_trn;
                config.TP_micro_cv = TP_micro_cv;
                config.TN_micro_cv = TN_micro_cv;
                best_v_cv=v_cv;
		best_minimizing_function=minimizing_function
                config.best_c = config.c;
                config.best_g = config.g;
            end
            
%             writeModelParams(config,'c',config.c);
%             writeModelParams(config,'g',config.g);
%             writeModelParams(config,'v_trn',v_trn);
%             writeModelParams(config,'v_cv',v_cv);
        
        end      %%%end of g loop
        
    end          %%%end of c loop
    
    writeModelParams(config,'config.best_c',config.best_c);
    writeModelParams(config,'config.best_g',2^config.best_g);
    writeModelParams(config,'v_trn_best',config.v_trn_best);
    writeModelParams(config,'config.best_v_cv',best_v_cv);
    writeModelParams(config,'config.best_minimizing_function',best_minimizing_function);
    
    %% Set best params from cross validation
    config.w_1_cost=1+config.BETA^2-config.v_trn_best;
    config.w_0_cost=config.v_trn_best*Theta_micro_trn;
    denom = config.w_1_cost+config.w_0_cost;
    config.w_1_cost = config.w_1_cost/denom;
    config.w_0_cost = config.w_0_cost/denom;
    config.model_final = model_final_trn;
    
    writeModelParams(config,'config.w_1_cost',config.w_1_cost);
    writeModelParams(config,'config.w_0_cost',config.w_0_cost);
    
    %% Testing
    
    gold_db_matrix_test=gold_db_matrix_test(:,NO_OF_RELNS);
    Theta_micro_test = calculateTheta(gold_db_matrix_test);
    [f_score] = amp_latent_test(config, gold_db_matrix_test, feature_vect_test, Theta_micro_test);
    
    %% Write params to file
    writeModelParams(config, 'Test_f_score',f_score);
    fid_parameters = fopen(config.resultFile, 'a');
    fprintf(fid_parameters,'\n------------------------------------------------\n');
    
    
end %end of while






























