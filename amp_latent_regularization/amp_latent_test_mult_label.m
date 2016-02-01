function [f_score] = amp_latent_test_mult_label(config, gold_db_matrix_test, feature_vect_test,Theta_micro_test)
    
    %%%Testing for each relation
    for i=1:config.NO_OF_RELNS
        [predicted_label_test(:,i), accuracy, decision_values] = svmpredict(gold_db_matrix_test(:,i), feature_vect_test, config.model_final(i));
    end
    
    predicted_label_test_plot = predicted_label_test';
    figure;
    plot(feature_vect_test(find(predicted_label_test_plot(1,:)),1),feature_vect_test(find(predicted_label_test_plot(1,:)),2),'ro');
    hold on;
    plot(feature_vect_test(find(predicted_label_test_plot(2,:)),1),feature_vect_test(find(predicted_label_test_plot(2,:)),2),'y*');
    plot(feature_vect_test(find(predicted_label_test_plot(3,:)),1),feature_vect_test(find(predicted_label_test_plot(3,:)),2),'b+');
    hold off;
    drawnow;

   [TP_micro, TN_micro] = find_TP_TN_micro(gold_db_matrix_test, predicted_label_test);

   %%% F-Score
   f_score = find_FScore_micro(config, TP_micro, TN_micro, Theta_micro_test)

end