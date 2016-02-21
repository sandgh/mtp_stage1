function [model] = trainSVM_macro(ylabels, classId, feature_vect, config)

%% On only those mentions which are true for the curr relation
temp_reln_labels = zeros(size(ylabels,1),1);
temp_reln_labels(ylabels==classId) = 1;

%% LibSVM Train

%% normal_svm-rbf
% params = ['-s 0 -t 2 -c ', num2str(2^config.c), ' -g ', num2str(2^config.g)];

%% weighted-rbf
params = ['-s 0 -t 2 -c ', num2str(2^config.c), ' -g ', num2str(2^config.g), ' -w1 ', num2str(config.w_1_cost),' -w0 ',num2str(config.w_0_cost)];

%% normal_svm-linear
% params = ['-s 0 -t 0 -c ', num2str(2^config.c)];

%% weighted-linear
% params = ['-s 0 -t 0 -c ', num2str(2^config.c), ' -w1 ', num2str(config.w_1_cost),' -w0 ',num2str(config.w_0_cost)];

%% return model
model = svmtrain(temp_reln_labels, feature_vect, params);

end