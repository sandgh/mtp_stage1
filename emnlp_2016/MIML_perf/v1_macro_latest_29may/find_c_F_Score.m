function [ f_score ] = find_c_F_Score( config,i,model,curr_thresholds )


[ent_mntn_cnt_row, ent_mntn_cnt_col] = size(config.test_ent_mntn_cnt);

        
    %this case arise some times
    if(sum(config.test_gold_y_labels(:,i)) == 0)
%         sum(predicted_y_labels)
%         sum(config.test_gold_y_labels(:,i))
               f_score = -3;

        return;
    end
    
    %% get cpe's from libsvm
    %the y_labels are given ones as we don't need the accuracy of svm
%     [predictions, accuracy_trn, cpe] = svmpredict(ones(config.test_no_of_snts,1), config.test_feature_vect, config.models(i), '-b 1');
    [predictions, accuracy_trn, cpe] = predict(ones(config.test_no_of_snts,1), sparse(config.test_feature_vect), model, '-b 1');

    
    %% make cpes > thresh = 1
    cpe_binary = cpe.*0;
    cpe_binary(cpe>curr_thresholds) = 1;
    
    count=0;
    predicted_y_labels = zeros(ent_mntn_cnt_row,1);
    
    
    for j=1:ent_mntn_cnt_row
        
        %the atleast one assumption
        %check if any of the mention is 1 for curr reln for the curr ent_pair
        predicted_y_labels(j,1) = sum(cpe_binary(count+1:config.test_ent_mntn_cnt(j,1)+count))>0;
        
        %set the count to the last mention of the curr ent pair
        %in the next loop we start from count+1
        count = config.test_ent_mntn_cnt(j,1)+count;
        
        
    end

%     config.pstv_train_classes = config.pstv_train_classes+1;
    config.f_score_flag(i,1) = 1;
    %% f_score = 2 * ( sum (y'.*y) ) / ( sum (y') + sum (y) )
    config.f_score(i,1) = 2*sum(predicted_y_labels.*config.test_gold_y_labels(:,i)) ...
                        /(sum(predicted_y_labels) + sum(config.test_gold_y_labels(:,i)));
                    
    
    
  TP = sum(predicted_y_labels.*config.test_gold_y_labels(:,i));
   FP = sum(predicted_y_labels.*(1-config.test_gold_y_labels(:,i)));
    FN = sum((1-predicted_y_labels).*config.test_gold_y_labels(:,i));

  precision=TP/(TP+FP);
    recall=TP/(TP+FN);
    f_score=2*precision*recall/(precision+recall);


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%