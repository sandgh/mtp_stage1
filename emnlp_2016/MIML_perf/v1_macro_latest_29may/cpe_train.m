%%% This function
%%% y_labels - binary matrix of sntnce X reln (hiddenlabels)
%%%

function [config] = cpe_train(config, y_labels)

[yrow, ycol] = size(y_labels);

% fid_parameters = fopen(config.result_file_name, 'a');


%% loop over all realtions
for i=4 %1:ycol
    
    
    %% if no +ve (-ve) labels present then skip the training
    if(sum(y_labels(:,i)) == 0 || sum(y_labels(:,i)) == yrow)
        continue;
    end
    
    
    %% @todo set the first training data as +ve example
    pstv_idx = find(y_labels(:,i)>0,1);
    
    
    %% @todo - proper cross validation??
    
    max_f_score = -1;
    thersh_idx = 1;
    
    for c=config.c_range
        for g=config.g_range
            
            %         fprintf(fid_parameters, 'Relation = %d, C = %d, ', i, 2^c);
            
            %% set the c-range
            %         params = ['-s 0 -b 1 -t 2 -c ', num2str(2^c)]
            config.current_c = 2^c;
            config.current_reln = i;
            [config.epoch_curr, i]
            
            params = ['-s 0 -q -c ', num2str(2^c)]
            %
            
            %% get the model for curr reln
            t = clock;
            
            if(strcmp(config.svmtype,'rbf'))
                params = ['-s 0 -b 1 -t 2 -g ',num2str(g/(2*config.g_std)),' -c ', num2str(2^c)]
                models(i) = svmtrain([y_labels(pstv_idx,i); y_labels(:,i)], [config.feature_vect(pstv_idx,:); config.feature_vect], params);
                [predictions, accuracy_trn, cpe] = svmpredict(y_labels(:,i), config.feature_vect, models(i), '-b 1');
            else
                params = ['-s 0 -q -c ', num2str(2^c)]
                models(i) = train([y_labels(pstv_idx,i); y_labels(:,i)], sparse([config.feature_vect(pstv_idx,:); config.feature_vect]), params);
                [predictions, accuracy_trn, cpe] = predict(y_labels(:,i), sparse(config.feature_vect), models(i), '-q -b 1');
            end
            
            %         models(i) = svmtrain([y_labels(pstv_idx,i); y_labels(:,i)], [config.feature_vect(pstv_idx,:); config.feature_vect], params);
            %             models(i) = train([y_labels(pstv_idx,i); y_labels(:,i)], sparse([config.feature_vect(pstv_idx,:); config.feature_vect]), params);
            
            trn_time = etime(clock,t);
            
            %% predict cpe's
            
            %     [predictions, accuracy_trn, cpe] = svmpredict(y_labels(:,i), config.feature_vect, models(i), '-b 1');
            %             [predictions, accuracy_trn, cpe] = predict(y_labels(:,i), sparse(config.feature_vect), models(i), '-q -b 1');
            
            
            
            %% choose the best threshold
            t=clock;
            [curr_thresholds, f_score]  = find_best_thresh(config, cpe,i);
            thresh_time = etime(clock,t);
            
            t =clock;
            f_score_validation = find_validation_F_Score( config,i,models(i),curr_thresholds);
            vald_time = etime(clock,t);
            
            
            if(f_score_validation==-3)          %-3 if reln not present in validatn set
                
                f_score_validation=f_score;
                
            end
            
            if(f_score_validation > max_f_score)
                
                %update best thresh
                %             config.thresholds(1,i) = curr_thresholds;
                %testing prev cpe
                config.thresholds_curr(1,i) = curr_thresholds;
                max_f_score = f_score_validation;
                
                %needs best models for testing
                config.models(i) = models(i);
                
                %needs curr best cpe to predict next y_labels
                %             config.cpe(:,i) = cpe(:,1);
                %testing prev cpe
                config.cpe_curr(:,i) = cpe(:,1);
                
            end
            
            if(strcmp(config.svmtype,'rbf'))
                config.time_results(config.trn_time_counter,:) = [config.epoch_curr, i, c, g, trn_time, vald_time, thresh_time, f_score, f_score_validation,max_f_score];
            else
                config.time_results(config.trn_time_counter,:) = [config.epoch_curr, i, c, trn_time, vald_time, thresh_time, f_score, f_score_validation,max_f_score];
            end
                time_results = config.time_results;
                save([config.result_file_name, '_time_train.mat'], 'time_results');
                config.trn_time_counter = config.trn_time_counter+1;
                
                %         config.c_fsc_train(config.epoch_curr,i,c) = find_c_F_Score(config,i,models(i),curr_thresholds);
                
                %         fprintf(fid_parameters, 'thresh = %f, curr_fsc = %f \n', config.thresholds(1,i), f_score);
            end
        end
        
        %testing with prev cpe weights
        %     config.cpe(:,i) = (config.cpe(:,i)*config.epoch_curr + config.cpe_curr(:,i)) ...
        %                                                     /(config.epoch_curr+1);
        %     config.thresholds(1,i) = (config.thresholds(1,i)*config.epoch_curr + config.thresholds_curr(:,i)) ...
        %                                                     /(config.epoch_curr+1);
        
        %     config.cpe(:,i) = (config.cpe(:,i) + config.cpe_curr(:,i))/2;
        %     config.thresholds(1,i) = (config.thresholds(1,i) + config.thresholds_curr(:,i))/2;
        
        config.cpe(:,i) = config.cpe_curr(:,i);
        config.thresholds(1,i) = config.thresholds_curr(:,i);
        
        
        
    end
    
    config.epoch_curr = config.epoch_curr+1;
    % fclose(fid_parameters);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%