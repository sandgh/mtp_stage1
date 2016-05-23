function [ config ] = read_sparse_naacl_data( config )

filename = config.file_name;
fid = fopen(filename);
num_egs=fscanf(fid,'%d',1);
NO_OF_RELN=fscanf(fid,'%d',1);

% max_feature=56648;
count_of_sentences=0;
config.gold_y_labels=zeros(num_egs,NO_OF_RELN+1);                        %%%%%%%%%%%%%%%%% gold_db_matrix x vs y

% config.feature_vect = sparse(1,1);
config.train_bags = cell(num_egs,1);
for n = 1:num_egs
%     config.bags(n,1) = {};
    no_of_relations_in_current_example=fscanf(fid, '%d',1);
    for r=1:no_of_relations_in_current_example
        relationid=fscanf(fid,'%d',1);
        config.gold_y_labels(n,relationid)=1;
    end
    
    no_of_sentences_in_current_example=fscanf(fid, '%d',1);
%     config.ent_mntn_cnt(n,1)=no_of_sentences_in_current_example;
    
    str = fgetl(fid);
    feature_vect = sparse(1,1);
    curr_cnt = 0;
    for s=1:no_of_sentences_in_current_example
        [n s]
        count_of_sentences=count_of_sentences+1;
        curr_cnt = curr_cnt+1;
        str = fgetl(fid);
        [no_of_features remaining]=strtok(str);
        no_of_features= str2num(no_of_features);
        features_to_triggered=strread(remaining,'%s','delimiter',' ');
        for idx = 1:numel(features_to_triggered)
            [feature weight] = strtok(features_to_triggered(idx),':');
            weight = strrep(weight,':','');
            feature=str2double(strtrim(feature));
            weight=str2double(strtrim(weight));
%             config.feature_vect(count_of_sentences,feature)=weight;
            feature_vect(curr_cnt,feature)=weight;
        end
    end
    config.train_bags(n,1) = {feature_vect};
end

gold_y_labels = config.gold_y_labels;
% feature_vect = config.feature_vect;
% ent_mntn_cnt = config.ent_mntn_cnt;
train_bags = config.train_bags;

save([config.file_name, '_gold_y_labels.mat'],'gold_y_labels');
% save([config.file_name, '_feature_vect.mat'],'feature_vect');
% save([config.file_name, '_ent_mntn_cnt.mat'],'ent_mntn_cnt');
save([config.file_name, '_train_bags.mat'],'train_bags', '-v7.3');


end

