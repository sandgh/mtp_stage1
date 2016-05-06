function [ config ] = load_naacl_data( config )


load([config.file_name, '_gold_y_labels.mat']);
load([config.file_name, '_feature_vect.mat']);
load([config.file_name, '_ent_mntn_cnt.mat']);

config.gold_y_labels = gold_y_labels;
config.feature_vect = feature_vect;
config.ent_mntn_cnt = ent_mntn_cnt;

end

