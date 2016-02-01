function [gold_db_matrix_trn, gold_db_matrix_cv, feature_vect_trn, feature_vect_cv] = createValidationSet(gold_db_matrix, feature_vect, config)
    
    %% Create Cross validation set
    rand_smpl_cv = randsample([1:size(gold_db_matrix,1)],ceil(size(gold_db_matrix,1)/config.vc_fold_size));
    feature_vect_cv = feature_vect(rand_smpl_cv,:);
    gold_db_matrix_cv = gold_db_matrix(rand_smpl_cv,:);
    
    %% Create Training set
    rand_smpl_trn=setdiff([1:size(gold_db_matrix,1)],rand_smpl_cv);
    feature_vect_trn = feature_vect(rand_smpl_trn,:);
    gold_db_matrix_trn = gold_db_matrix(rand_smpl_trn,:);
    

end