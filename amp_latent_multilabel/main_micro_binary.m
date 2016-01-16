clear;
clc;

%% Configuration Setup
%%Set Configuration Params
[config] = setConfig();

%%Set the libSVM Path
addpath(config.libSVMPath);


%% Reading Training File
disp('Reading Training file');
% [gold_db_matrix, feature_vect, NO_OF_RELNS, num_egs, max_feature, count_of_sentences, no_sentences_per_example, TEST_RELATIONS] = readTrainingData(config);
[gold_db_matrix, feature_vect] = scene_read_example(config.TrainFile);
[count_of_sentences, NO_OF_RELNS] = size(gold_db_matrix);
config.NO_OF_RELNS = NO_OF_RELNS;
[x,max_feature] = size(feature_vect);
disp('Training File reading done');

%% To make it single class- testing on one relation
NO_OF_RELNS=1;
config.NO_OF_RELNS = NO_OF_RELNS;
gold_db_matrix=gold_db_matrix(:,NO_OF_RELNS);

%% Find Theta micro
Theta_micro = calculateTheta(gold_db_matrix);


v_prev_prev = -1;
v_prev = -1;
v=0;

%% Optimization
iteration_no = 0;

while abs(v-v_prev) > .00001 &&  abs(v-v_prev_prev) > .00001
    iteration_no = iteration_no +1;
    v_prev = v;
    v_prev_prev = v_prev;
    
    %% initilize W and bias
    W = zeros(NO_OF_RELNS, max_feature);
    bias = zeros(NO_OF_RELNS, 1);

    %%% this matrix will store the prediction obtained by SVM params
    %%% i.e. the w'phi(x) for all relations for every sentence
    %%% We'll take the max as the class while predicting
    predicted_matrix = zeros(NO_OF_RELNS,count_of_sentences);


    %% SVM Training (One vs model_finalAll)    
    for i=1:NO_OF_RELNS

        [w, bias_curr, noPositiveFlag,model_final(i)] = trainSVM(count_of_sentences, gold_db_matrix(:,i), 1, feature_vect, config);

%         W(i,:) = w;
%         bias(i,:) = bias_curr;
        %%%pridiction for the current relation
        [predicted_matrix(i,:), accuracy, decision_values] = svmpredict(gold_db_matrix(:,i), feature_vect, model_final(i));

%         predicted_matrix(i,:)=sign(W(i,:) * feature_vect' +bias(i));

    end


   %% Multilabel prediction
   %%Calculate TP-TN-F_Score-W0-W1
   %%% TP-TN 
   [TP_micro, TN_micro] = find_TP_TN_micro(gold_db_matrix, predicted_matrix')

   %%% F-Score
   [v] = find_FScore_micro(config, TP_micro, TN_micro, Theta_micro)

   %%% w0-w1
   config.w_1_cost=1+config.BETA^2-v;
   config.w_0_cost=v*Theta_micro;
   config.model_final = model_final;

   %% Testing
   
   [gold_db_matrix_test, feature_vect_test] = scene_read_example(config.TestFile);
   gold_db_matrix_test=gold_db_matrix_test(:,NO_OF_RELNS);
   Theta_micro_test = calculateTheta(gold_db_matrix_test);
   [f_score] = amp_latent_test(config, gold_db_matrix_test, feature_vect_test, Theta_micro_test);
   
   %% Write params to file
   writeModelParams(config, TP_micro, TN_micro, 1, iteration_no, v, f_score);

end %end of while






























