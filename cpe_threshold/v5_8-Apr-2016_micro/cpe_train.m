%%% This function
%%% y_labels - binary matrix of sntnce X reln (hiddenlabels)
%%%

function [config] = cpe_train(config, y_labels)

[yrow, ycol] = size(y_labels);

% fid_parameters = fopen(config.result_file_name, 'a');

max_f_score = 0;
thersh_idx = 1;
for c=config.c_range
    
    cpe = config.cpe.*0;
    %% loop over all realtions
    %     models=;
    for i=1:ycol
        
        
        %% if no +ve (-ve) labels present then skip the training
        if(sum(y_labels(:,i)) == 0 || sum(y_labels(:,i)) == yrow)
            continue;
        end
        
        
        %% @todo set the first training data as +ve example
        pstv_idx = find(y_labels(:,i)>0,1);
        
        
        %% @todo - proper cross validation??
        
        %         fprintf(fid_parameters, 'Relation = %d, C = %d, ', i, 2^c);
        
        %% set the c-range
        %         params = ['-s 0 -b 1 -t 2 -c ', num2str(2^c)]
        [config.epoch_curr, i]
        params = ['-s 0 -q -c ', num2str(2^c)];
        %
        
        %% get the model for curr reln
        %         models(i) = svmtrain([y_labels(pstv_idx,i); y_labels(:,i)], [config.feature_vect(pstv_idx,:); config.feature_vect], params);
        models(i) = train([y_labels(pstv_idx,i); y_labels(:,i)], sparse([config.feature_vect(pstv_idx,:); config.feature_vect]), params);
        
        
        %% predict cpe's
        %         [predictions, accuracy_trn, cpe] = svmpredict(y_labels(:,i), config.feature_vect, models(i), '-b 1');
        [predictions, accuracy_trn, a] = predict(y_labels(:,i), sparse(config.feature_vect), models(i), '-q -b 1');
        cpe(:,i)=a(:,1);
    end
    
    %% choose the best threshold
    [curr_threshold, f_score, p ,r]  = find_best_thresh_micro(config,cpe,c);
    
    if(f_score > max_f_score)
        
        %update best thresh
        %             config.thresholds(1,i) = curr_thresholds;
        %testing prev cpe
        config.threshold_curr = curr_threshold;
        max_f_score = f_score;
        precision=p;
        recall=r;
        %needs best models for testing
        config.models = models;
        
        %needs curr best cpe to predict next y_labels
        %             config.cpe(:,i) = cpe(:,1);
        %testing prev cpe
        config.cpe_curr = cpe;
        
    end
    
   
    
    
    config.cpe = (config.cpe + config.cpe_curr)/2;
    config.threshold = (config.threshold + config.threshold_curr)/2;
    
    fid_parameters_fsc_summary_training = fopen([config.result_file_name_train, '_train_summary_.txt'], 'a');
    
    fprintf(fid_parameters_fsc_summary_training,'\n');
    fprintf(fid_parameters_fsc_summary_training, ' c %f ', c);
    
    
    % fprintf(fid_parameters, '%f', sum(config.f_score(:,1))/config.pstv_train_classes);
    fprintf(fid_parameters_fsc_summary_training, ' best_threshold %f ', config.threshold);
    fprintf(fid_parameters_fsc_summary_training, ' precision %f ', precision);
    fprintf(fid_parameters_fsc_summary_training, ' recall %f ', recall);
    fprintf(fid_parameters_fsc_summary_training, ' f-micro %f ', max_f_score);
    
    fclose(fid_parameters_fsc_summary_training);
    % fclose(fid_parameters);
    
    
    
end

config.epoch_curr = config.epoch_curr+1;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%