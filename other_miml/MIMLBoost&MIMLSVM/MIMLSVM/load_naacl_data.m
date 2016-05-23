function [ config ] = load_naacl_data( config )


load([config.file_name, '_gold_y_labels.mat']);
load([config.file_name, '_train_bags.mat']);
% load([config.file_name, '_ent_mntn_cnt.mat']);

config.gold_y_labels = gold_y_labels;
config.train_bags = train_bags;
% config.feature_vect = feature_vect;
% config.ent_mntn_cnt = ent_mntn_cnt;

end

