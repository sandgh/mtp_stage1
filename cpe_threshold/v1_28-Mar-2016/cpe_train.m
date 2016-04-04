%%% This function
%%% y_labels - binary matrix of sntnce X reln (hiddenlabels)
%%%

function [config] = cpe_train(config, y_labels)

[yrow, ycol] = size(y_labels);


%% loop over all realtions
for i=1:ycol
    
    
    %% if no +ve (-ve) labels present then skip the training
    if(sum(y_labels(:,i)) == 0 || sum(y_labels(:,i)) == yrow)
        continue;
    end    

    
    %% @todo set the first training data as +ve example
    pstv_idx = find(y_labels(:,i)>0,1);
    
    
    %% @todo - proper cross validation
    
    max_f_score = 0;
    thersh_idx = 1;
    
    for c=config.c_range
        
        %% set the c-range
        params = ['-s 0 -b 1 -t 0 -c ', num2str(2^c)]
        
        
        %% get the model for curr reln
        models(i) = svmtrain([y_labels(pstv_idx,i); y_labels(:,i)], [config.feature_vect(pstv_idx,:); config.feature_vect], params);
        
        
        %% predict cpe's
        [predictions, accuracy_trn, cpe] = svmpredict(y_labels(:,i), config.feature_vect, models(i), '-b 1');
        
        
        %% choose the best threshold
        [curr_thresholds, f_score]  = find_best_thresh(config, cpe,i);
        
        if(f_score > max_f_score)
            
            %update best thresh
            config.thresholds(1,i) = curr_thresholds;
            max_f_score = f_score;
            
            %needs best models for testing
            config.models(i) = models(i);
            
            %needs curr best cpe to predict next y_labels
            config.cpe(:,i) = cpe(:,1);
            
        end
        
        config.testfsc_c(i,c+1) = f_score;
    end
    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%