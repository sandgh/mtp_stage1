clear;
clc;

[config] = setConfig();
fid_parameters = fopen(config.resultFile, 'w');
fprintf(fid_parameters,'\n-----------------------------------------------------------------------------------------------\n');
fclose(fid_parameters);


for lp = 1:1
    
%% Configuration Setup
%%Set Configuration Params
[config] = setConfig();

%%Set the libSVM Path
addpath(config.libSVMPath);

fid_parameters = fopen(config.resultFile, 'a');
fprintf(fid_parameters,'\n-----------------------------------------------------------------------------------------------\n');


%% Reading Training File
disp('Reading Training file');
% [gold_db_matrix, feature_vect] = scene_read_example(config.TrainFile);

datasize_avg = 6000;
no_of_classes = 4;
[data, datasize] = generateTrainData(datasize_avg,1);
% datasize = datasize*no_of_classes;

%% hard coded testing
% datasize = 7020;
% load('data1.mat');

% train_cnt_tot = 1:12000;
% test_cnt = 12001:18000;
% cv_cnt = 9001:12000;
% train_cnt = 1:9000;

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

% [gold_db_matrix_trn, gold_db_matrix_cv, feature_vect_trn, feature_vect_cv] = createValidationSet(gold_db_matrix, feature_vect, config);
% save('cv_set.mat', 'gold_db_matrix_trn', 'gold_db_matrix_cv', 'feature_vect_trn', 'feature_vect_cv');
% load('cv_set.mat');


%% Find Theta micro
Theta_micro_trn = calculateTheta(gold_db_matrix_trn);
Theta_micro_cv = calculateTheta(gold_db_matrix_cv);

    best_v_cv = 0;
    plt_cnt = 0;
for curr_c = config.c_range
        plt_cnt = plt_cnt+1;
        config.c = curr_c;
        
%         for curr_g = config.g_range
%             
%             config.g = curr_g;

%%
v_prev_prev = -1;
v_prev = -1;
config.v_trn_best=0;
v_trn = 0;

%% Optimization
iteration_no = 0;
config.w_1_cost=0.5;
config.w_0_cost=0.5;
while (abs(v_trn-v_prev) > .00001 &&  abs(v_trn-v_prev_prev) > .00001)  && iteration_no < 10
    iteration_no = iteration_no +1;
    
    v_prev_prev = v_prev;
    v_prev = v_trn;
    
    %%% this matrix will store the prediction obtained by SVM params
    predicted_matrix = zeros(NO_OF_RELNS,count_of_sentences);
    
    %% tuning C
    
%     best_v_cv = 0;
%     plt_cnt = 0;
    
            
            
            %% SVM Training (One vs model_finalAll)
            for i=1:NO_OF_RELNS
                
                
                %%%find the first non zero label (SVM should have the first label non-zero, libsvm issue)
                nz_row = find(gold_db_matrix_trn(:,i),1);
                
                [model_final(i)] = trainSVM([1;gold_db_matrix_trn(:,i)], 1, [feature_vect_trn(nz_row,:); feature_vect_trn], config);
                
                %%%pridiction for the current relation
                
                [predicted_matrix_trn_temp, accuracy_trn, decision_values_trn_temp] = svmpredict([1;gold_db_matrix_trn(:,i)], [feature_vect_trn(nz_row,:);feature_vect_trn], model_final(i));
                predicted_matrix_trn(i,:) = predicted_matrix_trn_temp(2:end,:);
                decision_values_trn(i,:) = decision_values_trn_temp(2:end,:);
                
                
                
            end
            [x, max_i_trn] = max(decision_values_trn);
            predicted_matrix_trn = zeros(NO_OF_RELNS, size(gold_db_matrix_trn,1));
            for i=1:config.NO_OF_RELNS
                predicted_matrix_trn(i,max_i_trn==i) = 1;
            end
            
            %% Multilabel prediction
            %%Calculate TP-TN-F_Score-W0-W1
            [TP_micro_trn, TN_micro_trn] = find_TP_TN_micro(gold_db_matrix_trn, predicted_matrix_trn')
            [v_trn] = find_FScore_micro(config, TP_micro_trn, TN_micro_trn, Theta_micro_trn)
            v_trn_obj = (1+config.BETA^2-v_trn)*TP_micro_trn + v_trn*Theta_micro_trn*TN_micro_trn
            
            writeModelParams(config,'w_1_cost',config.w_1_cost);
            writeModelParams(config,'w_0_cost',config.w_0_cost);
            writeModelParams(config,'v_trn',v_trn);
            writeModelParams(config,'v_trn_obj',v_trn_obj);
            fprintf(fid_parameters,'\n,----------------,\n');
            
             %% Set best params from cross validation
            config.w_1_cost=1+config.BETA^2-v_trn;
            config.w_0_cost=v_trn*Theta_micro_trn;
            denom = config.w_1_cost+config.w_0_cost;
            config.w_1_cost = config.w_1_cost/denom;
            config.w_0_cost = config.w_0_cost/denom;
            config.model_final = model_final;
   
end %end of while

%% Get classification (max prediction)


            for i=1:NO_OF_RELNS
                nz_row = find(gold_db_matrix_trn(:,i),1);
            	[predicted_matrix_cv_temp, accuracy_cv, decision_values_cv_temp] = svmpredict([1;gold_db_matrix_cv(:,i)], [feature_vect_trn(nz_row,:);feature_vect_cv], model_final(i));
                predicted_matrix_cv(i,:) = predicted_matrix_cv_temp(2:end,:);
                decision_values_cv(i,:) = decision_values_cv_temp(2:end,:);
            end

            [x, max_i_cv] = max(decision_values_cv);
            predicted_matrix_cv = zeros(NO_OF_RELNS,size(gold_db_matrix_cv,1));
            for i=1:config.NO_OF_RELNS
                predicted_matrix_cv(i,(max_i_cv==i)) = 1;
            end
            
            
            [TP_micro_cv, TN_micro_cv] = find_TP_TN_micro(gold_db_matrix_cv, predicted_matrix_cv')
            
            %%% F-Score
            
            [v_cv] = find_FScore_micro(config, TP_micro_cv, TN_micro_cv, Theta_micro_cv);
            v_cv = (1+config.BETA^2-v_cv)*TP_micro_cv + v_cv*Theta_micro_cv*TN_micro_cv
%             plot_v_cv(plt_cnt) = v_cv;
%             plot_c(plt_cnt) = 2^config.c;
%             plot_v_trn(plt_cnt) = v_trn;
            
%             v_trn_obj = (1+config.BETA^2-v_trn)*TP_micro_trn + v_trn*Theta_micro_trn*TN_micro_trn
            
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
    
    %% plot c vs v_cv
%     figure;plot(plot_c,plot_v_cv,'g-');
%     figure;plot(plot_c,plot_v_trn,'r-');
    
    %% write params
    writeModelParams(config,'c',curr_c);
    writeModelParams(config,'g',config.g);
%     writeModelParams(config,'v_trn_best',config.v_trn_best);
    writeModelParams(config,'best_v_cv',best_v_cv);
    
   
    
    %% Testing
    
%     gold_db_matrix_test=gold_db_matrix_test(:,NO_OF_RELNS);
    Theta_micro_test = calculateTheta(gold_db_matrix_test);
    [f_score] = amp_latent_test_mult_label(config, gold_db_matrix_test, feature_vect_test, Theta_micro_test);
    
    %% Write params to file
    writeModelParams(config, 'Test_f_score',f_score);
    fid_parameters = fopen(config.resultFile, 'a');
    fprintf(fid_parameters,'\n,------------------------------------------------,\n');


%         end      %%%end of g loop
        
    end          %%%end of c loop


end

























