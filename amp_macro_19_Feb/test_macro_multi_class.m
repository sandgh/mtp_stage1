function [f_score] = test_macro_multi_class(config, gold_db_matrix_test, feature_vect_test,Theta_macro_test_vect)

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

predicted_label_test_plot = predicted_label_test;

figure;
plot(feature_vect_test(find(predicted_label_test_plot(1,:)),1),feature_vect_test(find(predicted_label_test_plot(1,:)),2),'ro');
title(['iteration = ', num2str(config.c)]);
hold on;
plot(feature_vect_test(find(predicted_label_test_plot(2,:)),1),feature_vect_test(find(predicted_label_test_plot(2,:)),2),'b+');
plot(feature_vect_test(find(predicted_label_test_plot(3,:)),1),feature_vect_test(find(predicted_label_test_plot(3,:)),2),'y*');
%%uncomment for 4 labels
plot(feature_vect_test(find(predicted_label_test_plot(4,:)),1),feature_vect_test(find(predicted_label_test_plot(4,:)),2),'gx');
hold off;
drawnow;

%% Find F-Score
%%%uncomment for multiclass
for i=1:config.NO_OF_RELNS
    [TP_macro_test, TN_macro_test] = find_TP_TN_macro(gold_db_matrix_test(:,i), predicted_label_test(i,:)')
    f_score_class(i) = find_FScore_macro(config, TP_macro_test, TN_macro_test, Theta_macro_test_vect(i,1));
end
f_score = sum(f_score_class)/config.NO_OF_RELNS
end