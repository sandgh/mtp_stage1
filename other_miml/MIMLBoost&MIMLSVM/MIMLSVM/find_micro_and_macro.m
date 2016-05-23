function [ f_macro,precision,recall,f_micro ] = find_micro_and_macro( Pre_Labels ,config)

% load(filename);
no_of_relns=size(Pre_Labels,1);

TP = 0;
FP = 0;
FN = 0;


Pre_Labels=Pre_Labels';

Pre_Labels(Pre_Labels<0)=0;

for i=1:no_of_relns
    
    if(sum(Pre_Labels(:,i)) + sum(config.test_gold_y_labels(:,i)) == 0)
        config.f_score(i,1) = 0;
    else
        config.f_score(i,1) = 2*sum(Pre_Labels(:,i).*config.test_gold_y_labels(:,i)) ...
            /(sum(Pre_Labels(:,i)) + sum(config.test_gold_y_labels(:,i)));
    end
    
    %     config.pred_y_lbl(config.epoch_curr, i, :) = predicted_y_labels';
    
    TP = TP + sum(Pre_Labels(:,i).*config.test_gold_y_labels(:,i));
    FP = FP + sum(Pre_Labels(:,i).*(1-config.test_gold_y_labels(:,i)));
    FN = FN + sum((1-Pre_Labels(:,i)).*config.test_gold_y_labels(:,i));
    
end

% f-macro=sum(config.f_score(:,1))/config.pstv_train_classes)
f_macro=sum(config.f_score(:,1))/25

precision=TP/(TP+FP)
recall=TP/(TP+FN)
f_micro=2*precision*recall/(precision+recall)

end

