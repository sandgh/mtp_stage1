function [f_score] = amp_latent_test(config, gold_db_matrix_test, feature_vect_test,Theta_micro_test)
    
    %%%Testing for each relation
    for i=1:config.NO_OF_RELNS
        [predicted_label_test(:,i), accuracy, decision_values] = svmpredict(gold_db_matrix_test(:,i), feature_vect_test, config.model_final(i));
    end

   [TP_micro, TN_micro] = find_TP_TN_micro(gold_db_matrix_test, predicted_label_test);

   %%% F-Score
   f_score = find_FScore_micro(config, TP_micro, TN_micro, Theta_micro_test)

end