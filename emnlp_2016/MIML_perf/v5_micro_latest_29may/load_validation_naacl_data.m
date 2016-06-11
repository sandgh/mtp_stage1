function [ config ] = load_validation_naacl_data( config )


load([config.validation_file_name, '_gold_y_labels.mat']);
load([config.validation_file_name, '_feature_vect.mat']);
load([config.validation_file_name, '_ent_mntn_cnt.mat']);

config.validation_gold_y_labels = gold_y_labels;
config.validation_feature_vect = feature_vect;
config.validation_ent_mntn_cnt = ent_mntn_cnt;

end

