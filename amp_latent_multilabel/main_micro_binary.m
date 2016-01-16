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
[gold_db_matrix, feature_vect] = scene_read_example('scene/scene-train.arff');
[count_of_sentences, NO_OF_RELNS] = size(gold_db_matrix);
[x,max_feature] = size(feature_vect);
disp('Training File reading done');

%% To make it single class- testing on one relation
NO_OF_RELNS=1;
gold_db_matrix=gold_db_matrix(:,NO_OF_RELNS);

%% Write initial W to file to infer latent variables
%%%%%%%%% Currently W is initialized with 0 it could also be rand %%%%%%%%%
% writeWeightVector('tmp1/inf_lat_var_all', zeros(NO_OF_RELNS, max_feature+1), NO_OF_RELNS, max_feature)
  

%% Find Theta micro
Theta_micro = calculateTheta(gold_db_matrix);


%% epoch start
for epoch=1:config.EPOCHS_COUNT  %%%%%%%%%%%% epoch length
    
    %% Infer Latent Vars
%     [latent_labels, latent_size,x1] = inferLatentVariables(config);
    
    v_prev_prev = -1;
    v_prev = -1;
    v=0;
    
    while abs(v-v_prev) > .00001 &&  abs(v-v_prev_prev) > .00001
        
        v_prev = v;
        v_prev_prev = v_prev;
        %% initilize W and bias
        W = zeros(NO_OF_RELNS, max_feature);
        bias = zeros(NO_OF_RELNS, 1);

        %%% this matrix will store the prediction obtained by SVM params
        %%% i.e. the w'phi(x) for all relations for every sentence
        %%% We'll take the max as the class while predicting
        predicted_matrix = zeros(NO_OF_RELNS,count_of_sentences);


        %% SVM Training (One vs All)    
        for i=1:NO_OF_RELNS

            [w, bias_curr, noPositiveFlag,model] = trainSVM(count_of_sentences, gold_db_matrix(:,i), 1, feature_vect, config);
            model_final(i)=model;
            if(noPositiveFlag == 1) continue; end

            W(i,:) = w;
            bias(i,:) = bias_curr;
            
            %%%pridiction for the current relation
            [predicted_matrix(i,:), accuracy, decision_values] = svmpredict(gold_db_matrix(:,i), feature_vect, model_final(i));

%             predicted_matrix(i,:)=sign(W(i,:) * feature_vect' +bias(i));

        end


        %% SVM Prediction - Training  
        if(config.trainingPredictionType == 1)   %%Multiclass prediction
            %% Multiclass prediction
            [predictions_vect] = predictionSVM(latent_size, bias, W, feature_vect);

           %%Joint Prediction (finds y from h - at least one assumtion)
           [predicted_db_matrix] = jointPrediction(num_egs, NO_OF_RELNS, no_sentences_per_example, predictions_vect);

           %%Calculate TP-TN-F_Score-W0-W1
           %%% TP-TN 
           [TP_micro, TN_micro] = find_TP_TN_micro(gold_db_matrix, predicted_db_matrix);


           %%% F-Score
           [v] = find_FScore_micro(config, TP_micro, TN_micro, Theta_micro);

        
        elseif (config.trainingPredictionType == 2)     %% Naacle joint prediction
            %% Naacle joint prediction
            system('./evaluate_naacle_train.sh');
            
            fscorefile = fopen('f_score_joint_train.txt','r');
            
            v = fscanf(fscorefile,'%f');
            
            TP_micro = 0.0;
            TN_micro = 0.0;
            
        elseif(config.trainingPredictionType == 3)   %%Multilabel prediction
            %% Multiclass prediction
%             [predictions_vect] = predictionSVM(latent_size, bias, W, feature_vect);
% 
%            %%Joint Prediction (finds y from h - at least one assumtion)
%            [predicted_db_matrix] = jointPrediction(num_egs, NO_OF_RELNS, no_sentences_per_example, predictions_vect);

           %%Calculate TP-TN-F_Score-W0-W1
           %%% TP-TN 
           [TP_micro, TN_micro] = find_TP_TN_micro(gold_db_matrix, predicted_matrix')


           %%% F-Score
           [v] = find_FScore_micro(config, TP_micro, TN_micro, Theta_micro)
        end
           
       %%% w0-w1
       config.w_1_cost=1+config.BETA^2-v;
       config.w_0_cost=v*Theta_micro;
       
       %% Write params to file
       writeModelParams(config, TP_micro, TN_micro, epoch, v);
       
    end %end of while

    
   %% Write W to file to infer latent var in the next epoch
%    writeWeightVector('tmp1/inf_lat_var_all', [W bias], NO_OF_RELNS, max_feature);
    

    %% Testing

    %     system(['./evaluate_naacle.sh ', config.TrainFile, ' ',int2str(epoch)]);

[gold_db_matrix_test, feature_vect_test] = scene_read_example('scene/scene-test.arff');
Theta_micro_test = calculateTheta(gold_db_matrix_test);

gold_db_matrix_test=gold_db_matrix_test(:,NO_OF_RELNS);
        for i=1:NO_OF_RELNS


        [predicted_label_test(:,i), accuracy, decision_values] = svmpredict(gold_db_matrix_test(:,i), feature_vect_test, model_final(i));
        
        end
        
        [TP_micro, TN_micro] = find_TP_TN_micro(gold_db_matrix_test, predicted_label_test);


           %%% F-Score
           v = find_FScore_micro(config, TP_micro, TN_micro, Theta_micro_test)
        
   end
fid_parameters = fopen([config.TrainFile,'_','current_parameters'], 'a');
fprintf(fid_parameters,'-----------------------------------------------------------------------------------------------'); 





























