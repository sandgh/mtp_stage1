function [f_score] = amp_latent_test(config, gold_db_matrix_test, feature_vect_test,Theta_micro_test)



%%%Testing for each relation
for i=1:config.NO_OF_RELNS
    nz_row = find(gold_db_matrix_test(:,i),1);
    [predicted_matrix_test_temp, accuracy_test, decision_values_test_temp] = svmpredict([1;gold_db_matrix_test(:,i)], [feature_vect_test(nz_row,:);feature_vect_test], config.model_final(i));
    predicted_label_test(i,:) = predicted_matrix_test_temp(2:end,:);
    decision_values_test(i,:) = decision_values_test_temp(2:end,:);
    %         [predicted_label_test(:,i), accuracy, decision_values] = svmpredict(gold_db_matrix_test(:,i), feature_vect_test, config.model_final(i));
end

[TP_micro, TN_micro] = find_TP_TN_micro(gold_db_matrix_test, predicted_label_test');

%%% F-Score
f_score = find_FScore_micro(config, TP_micro, TN_micro, Theta_micro_test)

end

