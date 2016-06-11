
% config.pred_y_lbl(config.epoch_curr, i, :) = predicted_y_labels';

pred_y_lbl(:,:)=config.pred_y_lbl(2,:,:);


TP=0;
FN=0;
FP=0;


for i=1:config.no_of_relns
    predicted_y_labels=pred_y_lbl(i,:);
    
    TP = TP + sum(predicted_y_labels'.*config.test_gold_y_labels(:,i));
    FP = FP + sum(predicted_y_labels'.*(1-config.test_gold_y_labels(:,i)));
    FN = FN + sum((1-predicted_y_labels').*config.test_gold_y_labels(:,i));
    
end

precision=TP/(TP+FP)
recall=TP/(TP+FN)
f_micro=2*precision*recall/(precision+recall)


% precision =
% 
% 
%  0.7278
% 
% 
% recall =
% 
%     0.5992
% 
% 
% f_micro =
% 
%     0.6573