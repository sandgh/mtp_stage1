%%% This function
%%%
%%%



function [f_score] = find_F_Score_threshold(config, cpe, thresh,relation)


%% make cpes > thresh = 1
cpe_binary = cpe.*0;
cpe_binary(cpe>thresh) = 1;


%% find the f_score for this classs
[ent_mntn_cnt_row, ent_mntn_cnt_col] = size(config.ent_mntn_cnt);

count=0;
predicted_y_labels = zeros(ent_mntn_cnt_row,1);


for i=1:ent_mntn_cnt_row
   
    %the atleast one assumption
    %check if any of the mention is 1 for curr reln for the curr ent_pair
    %%@todo find the MAX
    predicted_y_labels(i,1) = sum(cpe_binary(count+1:config.ent_mntn_cnt(i,1)+count))>0;
    
    %set the count to the last mention of the curr ent pair
    %in the next loop we start from count+1
    count = config.ent_mntn_cnt(i,1)+count;
    
    
end

%% f_score = 2 * ( sum (y'.*y) ) / ( sum (y') + sum (y) )
f_score = 2*sum(predicted_y_labels.*config.gold_y_labels(:,relation))/(sum(predicted_y_labels) + sum(config.gold_y_labels(:,relation)));


end