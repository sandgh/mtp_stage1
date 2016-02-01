clear;
clc;

%% Configuration Setup
%%Set Configuration Params
[config] = setConfig();

%%Set the libSVM Path
addpath(config.libSVMPath);

fid_parameters = fopen(config.resultFile, 'w');
%% Reading Training File
fprintf(fid_parameters,'\n,-----------------------------------------------------------------------------------------------,\n');
fclose(fid_parameters);
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

[gold_db_matrix_trn, gold_db_matrix_cv, feature_vect_trn, feature_vect_cv] = createValidationSet(gold_db_matrix, feature_vect, config);
%% Find Theta micro
Theta_micro_trn = calculateTheta(gold_db_matrix_trn);
Theta_micro_cv = calculateTheta(gold_db_matrix_cv);

best_v_cv = 0;
best_maximizing_function = 0;

for curr_c = config.c_range
    config.c = curr_c;
    if(config.c==0)
        continue;
    end    
    for curr_g = config.g_range
        config.g = curr_g;
        fid_parameters = fopen(config.resultFile, 'a');
        fprintf(fid_parameters,'\n,-------------------------------------,\n');
        fprintf(fid_parameters, ['c - %f,'], curr_c);
        fprintf(fid_parameters, ['g - %f\n'], curr_g);
        %         writeModelParams(config,'c',curr_c);
        %         writeModelParams(config,'g',curr_g);
        %         fprintf(fid_parameters,'\n');
        fclose(fid_parameters);
        config.w_1_cost=0.5;
        config.w_0_cost=0.5;
        v_prev_prev = -1;
        v_prev = -1;
        v_trn=0;
        
        %% Optimization
        
        
        iteration_no = 0;
        %         writeModelParams(config,'c',config.c);
        %         writeModelParams(config,'g',config.g);
        
        while abs(v_trn-v_prev) > .00001 &&  abs(v_trn-v_prev_prev) > .00001
            iteration_no = iteration_no +1;
            
            v_prev_prev = v_prev;
            v_prev = v_trn;
            
            %% initilize W and bias
            % W = zeros(NO_OF_RELNS, max_feature);
            % bias = zeros(NO_OF_RELNS, 1);
            
            %%% this matrix will store the prediction obtained by SVM params
            %%% i.e. the w'phi(x) for all relations for every sentence
            %%% We'll take the max as the class while predicting
            predicted_matrix = zeros(NO_OF_RELNS,count_of_sentences);
            
            
            
            
            
            
            
            for i=1:NO_OF_RELNS
                
                %         [w, bias_curr, noPositiveFlag,model_final(i)] = trainSVM(count_of_sentences, gold_db_matrix(:,i), 1, feature_vect, config);
                nz_row = find(gold_db_matrix_trn(:,i),1);
                [model_final(i)] = trainSVM([1;gold_db_matrix_trn(:,i)], 1, [feature_vect_trn(nz_row,:); feature_vect_trn], config);
                %                 [model_final(i)] = trainSVM(gold_db_matrix_trn(:,i), 1, feature_vect_trn, config);
                
                
                %         W(i,:) = w;
                %         bias(i,:) = bias_curr;
                %%%pridiction for the current relation
                %                 [predicted_matrix_trn(i,:), accuracy_trn, decision_values_trn] = svmpredict(gold_db_matrix_trn(:,i), feature_vect_trn, model_final(i));
                %         predicted_matrix(i,:)=sign(W(i,:) * feature_vect' +bias(i));
                [predicted_matrix_trn_temp, accuracy_trn, decision_values_trn_temp] = svmpredict([1;gold_db_matrix_trn(:,i)], [feature_vect_trn(nz_row,:);feature_vect_trn], model_final(i));
                predicted_matrix_trn(i,:) = predicted_matrix_trn_temp(2:end,:);
                decision_values_trn(i,:) = decision_values_trn_temp(2:end,:);
            end
            
            
            %% Multilabel prediction
            %%Calculate TP-TN-F_Score-W0-W1
            %%% TP-TN
            [TP_micro_trn, TN_micro_trn] = find_TP_TN_micro(gold_db_matrix_trn, predicted_matrix_trn')
            
            
            %%% F-Score
            [v_trn] = find_FScore_micro(config, TP_micro_trn, TN_micro_trn, Theta_micro_trn)
            maximizing_function = (1+config.BETA^2-v_trn)*TP_micro_trn + v_trn*Theta_micro_trn*TN_micro_trn
            
            writeModelParams(config,'maximizing_function_train',maximizing_function);
            writeModelParams(config,'v_trn',v_trn);
            writeModelParams(config,'config.w_1_cost',config.w_1_cost);
            writeModelParams(config,'config.w_0_cost',config.w_0_cost);
            
            %%
            config.w_0_cost=1+config.BETA^2-v_trn;
            config.w_1_cost=v_trn*Theta_micro_trn;
            denom = config.w_1_cost+config.w_0_cost;
            config.w_1_cost = config.w_1_cost/denom;
            config.w_0_cost = config.w_0_cost/denom;
            %             config.model_final = model_final;   
                      
            
            fid_parameters = fopen(config.resultFile, 'a');
            fprintf(fid_parameters,'\n');
            fclose(fid_parameters);
            
        end %end of while
        
        for i=1:NO_OF_RELNS
            %             [predicted_matrix_cv(i,:), accuracy_cv, decision_values_cv] = svmpredict(gold_db_matrix_cv(:,i), feature_vect_cv, model_final(i));
            nz_row = find(gold_db_matrix_cv(:,i),1);
            [predicted_matrix_cv_temp, accuracy_cv, decision_values_cv_temp] = svmpredict([1;gold_db_matrix_cv(:,i)], [feature_vect_trn(nz_row,:);feature_vect_cv], model_final(i));
            predicted_matrix_cv(i,:) = predicted_matrix_cv_temp(2:end,:);
            decision_values_cv(i,:) = decision_values_cv_temp(2:end,:);
        end
        
        [TP_micro_cv, TN_micro_cv] = find_TP_TN_micro(gold_db_matrix_cv, predicted_matrix_cv')
        [v_cv] = find_FScore_micro(config, TP_micro_cv, TN_micro_cv, Theta_micro_cv);
        maximizing_function = (1+config.BETA^2-v_cv)*TP_micro_cv + v_cv*Theta_micro_cv*TN_micro_cv
        
        
        if(best_maximizing_function<maximizing_function)
            config.model_final = model_final;
            %             model_final_trn = model_final;
            config.v_trn_best = v_trn;
            %             config.TP_micro_trn = TP_micro_trn;
            %             config.TN_micro_trn = TN_micro_trn;
            %             config.TP_micro_cv = TP_micro_cv;
            %             config.TN_micro_cv = TN_micro_cv;
            best_v_cv=v_cv;
            best_maximizing_function=maximizing_function;
            config.best_c = config.c;
            config.best_g = config.g;
            
                
            
            gold_db_matrix_test=gold_db_matrix_test(:,1:NO_OF_RELNS);
            Theta_micro_test = calculateTheta(gold_db_matrix_test);
            [f_score] = amp_latent_test(config, gold_db_matrix_test, feature_vect_test, Theta_micro_test);
            
            %% Write params to file
            fid_parameters = fopen(config.resultFile, 'a');
            fprintf(fid_parameters,'\nTest_f_score-%f',f_score);
            fclose(fid_parameters);
            
        end
        
        
        
    end      %%%end of g loop
    
end          %%%end of c loop


fid_parameters = fopen(config.resultFile, 'a');
fprintf(fid_parameters,'\n\nbest_c,best_g,v_trn_best,best_v_cv,best_maximizing_function\n');
            fclose(fid_parameters);


writeModelParams(config,'config.best_c',config.best_c);
writeModelParams(config,'config.best_g',2^config.best_g);
writeModelParams(config,'v_trn_best',config.v_trn_best);
writeModelParams(config,'config.best_v_cv',best_v_cv);
writeModelParams(config,'config.best_maximizing_function',best_maximizing_function);





%% Testing

gold_db_matrix_test=gold_db_matrix_test(:,1:NO_OF_RELNS);
Theta_micro_test = calculateTheta(gold_db_matrix_test);
[f_score] = amp_latent_test(config, gold_db_matrix_test, feature_vect_test, Theta_micro_test);

%% Write params to file
fid_parameters = fopen(config.resultFile, 'a');
fprintf(fid_parameters,'\n------------------------------------------------\n');
fprintf(fid_parameters,'\nTest_f_score- %f',f_score);
fclose(fid_parameters);




















