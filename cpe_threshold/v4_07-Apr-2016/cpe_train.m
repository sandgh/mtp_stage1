%%% This function
%%% y_labels - binary matrix of sntnce X reln (hiddenlabels)
%%%

function [config] = cpe_train(config, y_labels)

[yrow, ycol] = size(y_labels);

% fid_parameters = fopen(config.result_file_name, 'a');


%% loop over all realtions
for i=1:ycol

    
    %% if no +ve (-ve) labels present then skip the training
    if(sum(y_labels(:,i)) == 0 || sum(y_labels(:,i)) == yrow)
        continue;
    end    

    
    %% @todo set the first training data as +ve example
    pstv_idx = find(y_labels(:,i)>0,1);
    
    
    %% @todo - proper cross validation??
    
    max_f_score = 0;
    thersh_idx = 1;
    
    for c=config.c_range
        
%         fprintf(fid_parameters, 'Relation = %d, C = %d, ', i, 2^c);
        
        %% set the c-range
        params = ['-s 0 -b 1 -t 2 -c ', num2str(2^c)]
%         params = ['-s 0 -c ', num2str(2^c)]
%         
        
        %% get the model for curr reln
        models(i) = svmtrain([y_labels(pstv_idx,i); y_labels(:,i)], [config.feature_vect(pstv_idx,:); config.feature_vect], params);
%           models(i) = train([y_labels(pstv_idx,i); y_labels(:,i)], sparse([config.feature_vect(pstv_idx,:); config.feature_vect]), params);
      
        
        %% predict cpe's
        [predictions, accuracy_trn, cpe] = svmpredict(y_labels(:,i), config.feature_vect, models(i), '-b 1');
%         [predictions, accuracy_trn, cpe] = predict(y_labels(:,i), sparse(config.feature_vect), models(i), '-b 1');
        
        
        %% choose the best threshold
        [curr_thresholds, f_score]  = find_best_thresh(config, cpe,i);
        
        if(f_score > max_f_score)
            
            %update best thresh
%             config.thresholds(1,i) = curr_thresholds;
            %testing prev cpe
            config.thresholds_curr(1,i) = curr_thresholds;
            max_f_score = f_score;
            
            %needs best models for testing
            config.models(i) = models(i);
            
            %needs curr best cpe to predict next y_labels
%             config.cpe(:,i) = cpe(:,1);
            %testing prev cpe
            config.cpe_curr(:,i) = cpe(:,1);
            
        end
        
        config.testfsc_c(i,c+1) = f_score;
        
%         fprintf(fid_parameters, 'thresh = %f, curr_fsc = %f \n', config.thresholds(1,i), f_score);
    end

    %testing with prev cpe weights
%     config.cpe(:,i) = (config.cpe(:,i)*config.epoch_curr + config.cpe_curr(:,i)) ...
%                                                     /(config.epoch_curr+1);
%     config.thresholds(1,i) = (config.thresholds(1,i)*config.epoch_curr + config.thresholds_curr(:,i)) ...
%                                                     /(config.epoch_curr+1);

    config.cpe(:,i) = (config.cpe(:,i) + config.cpe_curr(:,i))/2;
    config.thresholds(1,i) = (config.thresholds(1,i) + config.thresholds_curr(:,i))/2;
end

config.epoch_curr = config.epoch_curr+1;
% fclose(fid_parameters);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%