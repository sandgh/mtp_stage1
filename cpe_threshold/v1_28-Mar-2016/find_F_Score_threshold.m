%%% This function
%%%
%%%



function [f_score] = find_F_Score_threshold(config, cpe, thresh)


cpe_binary = cpe.*0;
cpe_binary(cpe>thresh) = 1;

[ent_mntn_cnt_row, ent_mntn_cnt_col] = size(config.ent_mntn_cnt);

count=0;
predicted_y_labels = zeros(ent_mntn_cnt_row,1);
for i=1:ent_mntn_cnt_row
   
    predicted_y_labels(i,1) = sum(cpe_binary(count+1:config.ent_mntn_cnt(i,1)+count))>0;
    
    %test print
%     count+1:config.ent_mntn_cnt(i,1)+count
    
    count = config.ent_mntn_cnt(i,1)+count;
    
    
end

f_score = 0;
end