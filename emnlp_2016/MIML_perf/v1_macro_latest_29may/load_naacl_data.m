function [ config ] = load_naacl_data( config )


load([config.file_name, '_gold_y_labels.mat']);
load([config.file_name, '_feature_vect.mat']);
load([config.file_name, '_ent_mntn_cnt.mat']);

trn_sz =  round(size(gold_y_labels,1)*75/100);
feature_sz = sum(ent_mntn_cnt(1:trn_sz,:));

config.gold_y_labels = gold_y_labels(1:trn_sz,:);
config.feature_vect = feature_vect(1:feature_sz,:);
config.ent_mntn_cnt = ent_mntn_cnt(1:trn_sz,:);

config.validation_gold_y_labels = gold_y_labels(trn_sz+1:end,:);
config.validation_feature_vect = feature_vect(feature_sz+1:end,:);
config.validation_ent_mntn_cnt = ent_mntn_cnt(trn_sz+1:end,:);


end

