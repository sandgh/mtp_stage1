%%% This function
%%%
%%%

function [models, thresholds] = cpe_train(config, y_labels)

[yrow, ycol] = size(y_labels);


thresholds = zeros(1,ycol);
%% loop over all realtions
for i=1:ycol
    
    %% @todo set the first training data as +ve example
    
    
    %% @todo need to set the c-range
    params = ['-s 0 -b 1 -t 0  -c 1']
    
    
    %% get the model
    models(i) = svmtrain(y_labels(:,i), config.feature_vect, params);
    
    %% predict cpe's
    [predictions, accuracy_trn, cpe] = svmpredict(y_labels(:,i), config.feature_vect, models(i), '-b 1');
    
    
    %% choose the best threshold
    thresholds(1,i) = find_best_thresh(config, cpe);
    
    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%