function [ f_score ] = find_validation_F_Score( config,models,curr_thresholds)


[ent_mntn_cnt_row, ent_mntn_cnt_col] = size(config.validation_ent_mntn_cnt);

TP = 0;
FP = 0;
FN = 0;

% config.pstv_train_classes = 0;
for i=1:config.no_of_relns
    
    if((strcmp(config.svmtype,'rbf') && (i>size(models,2) || (size(models(i).SVs , 1) == 0)))...
            || (strcmp(config.svmtype,'lin') && (i>size(models,2) || (size(models(i).w , 1) == 0))))
        
        continue;
    end
    
    
    %this case arise some times
    if(sum(config.validation_gold_y_labels(:,i)) == 0)
        continue;
    end
    
    %% get cpe's from libsvm
    %the y_labels are given ones as we don't need the accuracy of svm
    if(strcmp(config.svmtype,'rbf'))
        [predictions, accuracy_trn, cpe] = svmpredict(ones(size(config.validation_feature_vect,1),1), config.validation_feature_vect, models(i), '-b 1');
    else
        [predictions, accuracy_trn, cpe] = predict(ones(size(config.validation_feature_vect,1),1), sparse(config.validation_feature_vect), models(i), '-q -b 1');
    end
    
    
    %% make cpes > thresh = 1
    cpe_binary = cpe.*0;
    cpe_binary(cpe>curr_thresholds) = 1;
%     cpe_binary(round(cpe*10000)/10000>=curr_thresholds) = 1;
    count=0;
    predicted_y_labels = zeros(ent_mntn_cnt_row,1);
    
    
    for j=1:ent_mntn_cnt_row
        
        %the atleast one assumption
        %check if any of the mention is 1 for curr reln for the curr ent_pair
        predicted_y_labels(j,1) = sum(cpe_binary(count+1:config.validation_ent_mntn_cnt(j,1)+count))>0;
        
        %set the count to the last mention of the curr ent pair
        %in the next loop we start from count+1
        count = config.validation_ent_mntn_cnt(j,1)+count;
        
        
    end
    
    %     config.pstv_train_classes = config.pstv_train_classes+1;
    TP = TP + sum(predicted_y_labels.*config.validation_gold_y_labels(:,i));
    FP = FP + sum(predicted_y_labels.*(1-config.validation_gold_y_labels(:,i)));
    FN = FN + sum((1-predicted_y_labels).*config.validation_gold_y_labels(:,i));
    
    
    
end

precision=TP/(TP+FP);
recall=TP/(TP+FN);
f_score=2*precision*recall/(precision+recall);

if (precision+recall)==0
    f_score=0;
end

end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%