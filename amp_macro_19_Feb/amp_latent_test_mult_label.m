function [f_score] = amp_latent_test_mult_label(config, gold_db_matrix_test, feature_vect_test,Theta_micro_test)
    
    %%%Testing for each relation
    for i=1:config.NO_OF_RELNS
        [predicted_label_test(:,i), accuracy, decision_values(:,i)] = svmpredict(gold_db_matrix_test(:,i), feature_vect_test, config.model_final(i));
    end
    
    %%%uncomment for multiclass
    [x, max_i] = max(decision_values');
    predicted_label_test = zeros(config.NO_OF_RELNS,size(gold_db_matrix_test,1));
    for i=1:config.NO_OF_RELNS
        predicted_label_test(i,max_i==i) = 1;
    end
    
    %%%uncomment for multilabel
%     predicted_label_test_plot = predicted_label_test';
    %%%uncomment for multiclass
    predicted_label_test_plot = predicted_label_test;

    figure;
    plot(feature_vect_test(find(predicted_label_test_plot(1,:)),1),feature_vect_test(find(predicted_label_test_plot(1,:)),2),'ro');
    hold on;
    plot(feature_vect_test(find(predicted_label_test_plot(2,:)),1),feature_vect_test(find(predicted_label_test_plot(2,:)),2),'b+');
    plot(feature_vect_test(find(predicted_label_test_plot(3,:)),1),feature_vect_test(find(predicted_label_test_plot(3,:)),2),'y*');
    %%uncomment for 4 labels
    plot(feature_vect_test(find(predicted_label_test_plot(4,:)),1),feature_vect_test(find(predicted_label_test_plot(4,:)),2),'gx');
    hold off;
    drawnow;
    %%%uncomment for multilabel
%    [TP_micro, TN_micro] = find_TP_TN_micro(gold_db_matrix_test, predicted_label_test);
    %%%uncomment for multiclass
   [TP_micro, TN_micro] = find_TP_TN_micro(gold_db_matrix_test, predicted_label_test');

   %%% F-Score
   f_score = find_FScore_micro(config, TP_micro, TN_micro, Theta_micro_test)

end