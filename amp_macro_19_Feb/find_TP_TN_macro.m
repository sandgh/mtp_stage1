function [TP_macro, TN_macro] = find_TP_TN_macro(gold_db_matrix, predicted_db_matrix)

    [a b]=size(gold_db_matrix);

    %%  Find cumulative TP
    TP_macro=sum(gold_db_matrix.*predicted_db_matrix)/sum(gold_db_matrix);

    %% Find cumulative TN
    c=1-gold_db_matrix;
    d=1-predicted_db_matrix;
    TN_macro=sum((c.*d))/sum(c);

end