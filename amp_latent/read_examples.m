filename = 'v.small.dat';
fid = fopen(filename);
num_egs=fscanf(fid,'%d',1);
NO_OF_RELNS=fscanf(fid,'%d',1);

no_sentences_per_example=zeros(1,num_egs);                           %%%%%%%%%%%%%%%    to store no of sentences in each example
max_feature=56648;
count_of_sentences=0;
gold_db_matrix=zeros(num_egs,NO_OF_RELNS+1);                        %%%%%%%%%%%%%%%%% gold_db_matrix x vs y
for n = 1:num_egs
    no_of_relations_in_current_example=fscanf(fid, '%d',1);
    for r=1:no_of_relations_in_current_example
        relationid=fscanf(fid,'%d',1)
        gold_db_matrix(n,relationid)=1;
    end
    no_of_sentences_in_current_example=fscanf(fid, '%d',1);
    no_sentences_per_example(1,n)=no_of_sentences_in_current_example;
    str = fgetl(fid)
    for s=1:no_of_sentences_in_current_example
        count_of_sentences=count_of_sentences+1;
        str = fgetl(fid)
        [no_of_features remaining]=strtok(str);
        no_of_features= str2num(no_of_features);
        features_to_triggered=strread(remaining,'%s','delimiter',' ');
        for idx = 1:numel(features_to_triggered)
            [feature weight] = strtok(features_to_triggered(idx),':');
            weight = strrep(weight,':','');
            feature=str2double(strtrim(feature));
            weight=str2double(strtrim(weight));
            feature_sentence_matrix(count_of_sentences,feature)=weight;
        end    
    end    
end

