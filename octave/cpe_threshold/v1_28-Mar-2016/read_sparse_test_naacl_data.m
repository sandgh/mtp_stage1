function [ config ] = read_sparse_test_naacl_data( config )

filename = config.test_file_name;
fid = fopen(filename);
num_egs=fscanf(fid,'%d',1);
NO_OF_RELN=fscanf(fid,'%d',1);

% max_feature=56648;
count_of_sentences=0;
config.test_gold_y_labels=zeros(num_egs,NO_OF_RELN+1);                        %%%%%%%%%%%%%%%%% gold_db_matrix x vs y

config.test_feature_vect = sparse(1,1);

for n = 1:num_egs
    no_of_relations_in_current_example=fscanf(fid, '%d',1);
    for r=1:no_of_relations_in_current_example
        relationid=fscanf(fid,'%d',1);
        config.test_gold_y_labels(n,relationid)=1;
    end
    
    no_of_sentences_in_current_example=fscanf(fid, '%d',1);
    config.test_ent_mntn_cnt(n,1)=no_of_sentences_in_current_example;
    
    str = fgetl(fid);
    for s=1:no_of_sentences_in_current_example
        count_of_sentences=count_of_sentences+1;
        str = fgetl(fid);
        [no_of_features remaining]=strtok(str);
        no_of_features= str2num(no_of_features);
        features_to_triggered=strread(remaining,'%s','delimiter',' ');
        for idx = 1:numel(features_to_triggered)
            [feature weight] = strtok(features_to_triggered(idx),':');
            weight = strrep(weight,':','');
            feature=str2double(strtrim(feature));
            weight=str2double(strtrim(weight));
            config.test_feature_vect(count_of_sentences,feature)=weight;
        end
    end
end

gold_y_labels = config.test_gold_y_labels;
feature_vect = config.test_feature_vect;
ent_mntn_cnt = config.test_ent_mntn_cnt;

save([config.test_file_name, '_gold_y_labels.mat'],'gold_y_labels');
save([config.test_file_name, '_feature_vect.mat'],'feature_vect');
save([config.test_file_name, '_ent_mntn_cnt.mat'],'ent_mntn_cnt');

end

