%%% This function
%%% y_labels - binary matrix of sntnce X reln (hiddenlabels)
%%%

function [config] = cpe_train(config, y_labels)

[yrow, ycol] = size(y_labels);

% fid_parameters = fopen(config.result_file_name, 'a');

max_f_score = 0;
thersh_idx = 1;

for c=config.c_range
    for g=config.g_range
        config.current_c = c;
        config.current_g = g;
        cpe = config.cpe.*0;
        %% loop over all realtions
        %     models=;
        t = clock;
        
        for i=1:ycol
            
            
            %% if no +ve (-ve) labels present then skip the training
            if(sum(y_labels(:,i)) == 0 || sum(y_labels(:,i)) == yrow)
                continue;
            end
            
            
            %% @todo set the first training data as +ve example
            pstv_idx = find(y_labels(:,i)>0,1);
            [config.epoch_curr c g i]
            
            %% @todo - proper cross validation??
            
            %         fprintf(fid_parameters, 'Relation = %d, C = %d, ', i, 2^c);
            
            %% set the c-range
            %         params = ['-s 0 -b 1 -t 2 -c ', num2str(2^c)]
            
            if(strcmp(config.svmtype,'rbf'))
                params = ['-s 0 -b 1 -t 2 -g ',num2str(g/(2*config.g_std)),' -c ', num2str(2^c)]
                models(i) = svmtrain([y_labels(pstv_idx,i); y_labels(:,i)], [config.feature_vect(pstv_idx,:); config.feature_vect], params);
                [predictions, accuracy_trn, a] = svmpredict(y_labels(:,i), config.feature_vect, models(i), '-b 1');
            else
                params = ['-s 0 -q -c ', num2str(2^c)]
                models(i) = train([y_labels(pstv_idx,i); y_labels(:,i)], sparse([config.feature_vect(pstv_idx,:); config.feature_vect]), params);
                [predictions, accuracy_trn, a] = predict(y_labels(:,i), sparse(config.feature_vect), models(i), '-q -b 1');
            end
            %
            
            %% get the model for curr reln
            %         models(i) = svmtrain([y_labels(pstv_idx,i); y_labels(:,i)], [config.feature_vect(pstv_idx,:); config.feature_vect], params);
            %             models(i) = train([y_labels(pstv_idx,i); y_labels(:,i)], sparse([config.feature_vect(pstv_idx,:); config.feature_vect]), params);
            
            %% predict cpe's
            
            %             [predictions, accuracy_trn, a] = predict(y_labels(:,i), sparse(config.feature_vect), models(i), '-q -b 1');
            cpe(:,i)=a(:,1);
            
        end
        
        trn_time = etime(clock,t);
        
        
        %% choose the best threshold
        t =clock;
        [curr_threshold, f_score, p ,r]  = find_best_thresh_micro(config,cpe,c);
        thresh_time = etime(clock,t);
        
        
        t=clock;
        %         [predictions, accuracy_trn, cpe] = svmpredict(y_labels(:,i), config.feature_vect, models(i), '-b 1');
        
        f_score_validation = find_validation_F_Score( config,models,curr_threshold);
        
        vald_time = etime(clock,t);
        
        
        
        %     if(f_score_validation==-3)          %-3 if reln not present in validatn set
        %         f_score_validation=f_score;
        %
        %     end
        
        if(f_score_validation > max_f_score)
            
            %update best thresh
            %             config.thresholds(1,i) = curr_thresholds;
            %testing prev cpe
            config.thresholds_curr = curr_threshold;
            max_f_score = f_score_validation;
            
            %needs best models for testing
            config.models = models;
            
            %needs curr best cpe to predict next y_labels
            %             config.cpe(:,i) = cpe(:,1);
            %testing prev cpe
            config.cpe_curr = cpe;
            
            
            
        end
        
        
        config.cpe = config.cpe_curr;
        config.thresholds = config.thresholds_curr;
        
        %     config.cpe = (config.cpe + config.cpe_curr)/2;
        %     config.threshold = (config.threshold + config.threshold_curr)/2;
        %
        %     fid_parameters_fsc_summary_training = fopen([config.result_file_name_train, '_train_summary_.txt'], 'a');
        %
        %     fprintf(fid_parameters_fsc_summary_training,'\n');
        %     fprintf(fid_parameters_fsc_summary_training, ' c %f ', c);
        %
        %
        %     % fprintf(fid_parameters, '%f', sum(config.f_score(:,1))/config.pstv_train_classes);
        %     fprintf(fid_parameters_fsc_summary_training, ' best_threshold %f ', config.threshold);
        %     fprintf(fid_parameters_fsc_summary_training, ' precision %f ', precision);
        %     fprintf(fid_parameters_fsc_summary_training, ' recall %f ', recall);
        %     fprintf(fid_parameters_fsc_summary_training, ' f-micro %f ', max_f_score);
        %
        %     fclose(fid_parameters_fsc_summary_training);
        % fclose(fid_parameters);
        
        if(strcmp(config.svmtype,'rbf'))
            config.time_results(config.trn_time_counter,:) = [config.epoch_curr, c, g, trn_time, vald_time, thresh_time, f_score, f_score_validation,max_f_score, config.thresholds];
        else
            config.time_results(config.trn_time_counter,:) = [config.epoch_curr, c, trn_time, vald_time, thresh_time, f_score, f_score_validation,max_f_score, config.thresholds];
        end
        time_results = config.time_results;
        save([config.result_file_name, '_time_train.mat'], 'time_results');
        config.trn_time_counter = config.trn_time_counter+1;
        
        
        
    end
end
config.epoch_curr = config.epoch_curr+1;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%