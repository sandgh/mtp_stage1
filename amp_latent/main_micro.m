clear;
clc;

%% Configuration Setup
%%Set Configuration Params
[config] = setConfig();

%%Set the libSVM Path
addpath(config.libSVMPath);


%% Reading Training File
disp('Reading Training file');
[gold_db_matrix, feature_vect, NO_OF_RELNS, num_egs, max_feature, count_of_sentences, no_sentences_per_example, TEST_RELATIONS] = readTrainingData(config);
disp('Training File reading done');


%% Write initial W to file to infer latent variables
%%%%%%%%% Currently W is initialized with 0 it could also be rand %%%%%%%%%
writeWeightVector('tmp1/inf_lat_var_all', zeros(NO_OF_RELNS, max_feature+1), NO_OF_RELNS, max_feature)
  

%% Find Theta micro
Theta_micro = calculateTheta(gold_db_matrix);


%% epoch start
for epoch=1:config.EPOCHS_COUNT  %%%%%%%%%%%% epoch length
    
    %% Infer Latent Vars
    [latent_labels, latent_size,x1] = inferLatentVariables(config);
    
    v_prev_prev = -1;
    v_prev = -1;
    v=0;
    
    while abs(v-v_prev) > .00001 &&  abs(v-v_prev_prev) > .00001
        %% initilize W and bias
        W = zeros(NO_OF_RELNS, max_feature);
        bias = zeros(NO_OF_RELNS, 1);

        %%% this matrix will store the prediction obtained by SVM params
        %%% i.e. the w'phi(x) for all relations for every sentence
        %%% We'll take the max as the class while predicting
        predicted_matrix = zeros(NO_OF_RELNS,count_of_sentences);


        %% SVM Training (One vs All)    
        for i=1:TEST_RELATIONS

            [w, bias_curr, noPositiveFlag] = trainSVM(latent_size, latent_labels, i, feature_vect, config);

            if(noPositiveFlag == 1) continue; end

            W(i+1,:) = w;
            bias(i+1,:) = bias_curr;

            %%%pridiction for the current relation
            predicted_matrix(i+1,:)=sign(W(i+1,:) * feature_vect' +bias(i+1));

        end


        %% SVM Prediction - Training  
        [predictions_vect] = predictionSVM(latent_size, bias, W, feature_vect);


       %% Joint Prediction (finds y from h - at least one assumtion)
       [predicted_db_matrix] = jointPrediction(num_egs, NO_OF_RELNS, no_sentences_per_example, predictions_vect);


       %% Calculate TP-TN-F_Score-W0-W1
       %%% TP-TN 
       [TP_micro, TN_micro] = find_TP_TN_micro(gold_db_matrix, predicted_db_matrix);

       v_prev = v;
       v_prev_prev = v_prev;
       %%% F-Score
       [v] = find_FScore_micro(config, TP_micro, TN_micro, Theta_micro);

       %%% w0-w1
       config.w_1_cost=1+config.BETA^2-v;
       config.w_0_cost=v*Theta_micro;
       
       %% Write params to file
       writeModelParams(config, TP_micro, TN_micro, epoch, v);
       
    end %end of while

    
   %% Write W to file to infer latent var in the next epoch
   writeWeightVector('tmp1/inf_lat_var_all', [W bias], NO_OF_RELNS, max_feature);
    

    %% Testing
    system(['./evaluate_naacle.sh ', config.TrainFile, ' ',int2str(epoch)]);
     
    disp('Epoch Done!!!');
   end






























