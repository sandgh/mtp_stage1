function [ config ] = find_test_F_Score( config )


[ent_mntn_cnt_row, ent_mntn_cnt_col] = size(config.test_ent_mntn_cnt);

%% loop over all relns
config.pstv_train_classes = 0;
for i=1:config.no_of_relns
    
    if(i>size(config.models,2) || size(config.models(i).SVs , 1) == 0)
%     if(i>size(config.models,2) || size(config.models(i).w , 1) == 0)
%         config.f_score(i,1)=0;
        config.f_score(i,1) = -1;
        config.f_score_flag(i,1) = 0;
        continue;
    end

        
    %this case arise some times
    if(sum(config.test_gold_y_labels(:,i)) == 0)
%         sum(predicted_y_labels)
%         sum(config.test_gold_y_labels(:,i))
        config.f_score(i,1) = -2;
        config.f_score_flag(i,1) = 0;
        continue;
    end
    
    %% get cpe's from libsvm
    %the y_labels are given ones as we don't need the accuracy of svm
    [predictions, accuracy_trn, cpe] = svmpredict(ones(config.test_no_of_snts,1), config.test_feature_vect, config.models(i), '-b 1');
%     [predictions, accuracy_trn, cpe] = predict(ones(config.test_no_of_snts,1), sparse(config.test_feature_vect), config.models(i), '-b 1');

    
    %% make cpes > thresh = 1
    cpe_binary = cpe.*0;
    cpe_binary(cpe>config.thresholds(1,i)) = 1;
    
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
    
    config.TP = config.TP + sum(predicted_y_labels.*config.test_gold_y_labels(:,i));
    config.FP = config.FP + sum(predicted_y_labels.*(1-config.test_gold_y_labels(:,i)));
    config.FN = config.FN + sum((1-predicted_y_labels).*config.test_gold_y_labels(:,i));

end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%