function [ config ] = load_test_naacl_data( config )


load([config.test_file_name, '_gold_y_labels.mat']);
load([config.test_file_name, '_test_bags.mat']);
% load([config.test_file_name, '_ent_mntn_cnt.mat']);

config.test_gold_y_labels = gold_y_labels;
config.test_bags = test_bags; 
% config.test_feature_vect = feature_vect;
% config.test_ent_mntn_cnt = ent_mntn_cnt;

end

