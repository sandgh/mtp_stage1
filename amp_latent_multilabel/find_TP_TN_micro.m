function [TP_micro, TN_micro] = find_TP_TN_micro(gold_db_matrix, predicted_db_matrix)

    [a b]=size(gold_db_matrix);

    %Find cumulative TP
    TP_micro=sum(sum(gold_db_matrix.*predicted_db_matrix))/sum(sum(gold_db_matrix))

    %Find cumulative TN
    c=zeros(a,b);
    d=zeros(a,b);
    c(gold_db_matrix==0) = 1;
    d(predicted_db_matrix==0) = 1;
    TN_micro=sum(sum(c.*d))/sum(sum(c))

%% Old Way
%     [a b]=size(gold_db_matrix);
% 
%     %Find cumulative TP
%     TP_micro=sum(sum(gold_db_matrix.*predicted_db_matrix))/(a*b)
% 
%     %Find cumulative TN
%     c=zeros(a,b);
%     d=zeros(a,b);
%     c(gold_db_matrix==0) = 1;
%     d(predicted_db_matrix==0) = 1;
%     TN_micro=sum(sum(c.*d))/(a*b)

end