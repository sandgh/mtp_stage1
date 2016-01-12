%% read examples
disp('Train read start');
% filename = 'train-riedel-10p.1.data';
filename = 'dataset/train-riedel-10p.1.data1';
fid = fopen(filename);
num_egs=fscanf(fid,'%d',1);
NO_OF_RELNS=fscanf(fid,'%d',1);
NO_OF_RELNS=NO_OF_RELNS+1;

TEST_RELATIONS = NO_OF_RELNS;
%%%%%%%%%%%%%%%    to store no of sentences in each example
no_sentences_per_example=zeros(1,num_egs);                           
max_feature=0;
count_of_sentences=0;
%%%%%%%%%%%%%%%%% gold_db_matrix x vs y
gold_db_matrix=zeros(num_egs,NO_OF_RELNS);                       
for n = 1:num_egs
    
    %Reading Relations for Entity Pairs
    no_of_relations_in_current_example=fscanf(fid, '%d',1);
    for r=1:no_of_relations_in_current_example
        relationid=fscanf(fid,'%d',1);
        gold_db_matrix(n,relationid+1)=1;
    end
    
    %Reading Features for Sentences
    no_of_sentences_in_current_example=fscanf(fid, '%d',1);
    no_sentences_per_example(1,n)=no_of_sentences_in_current_example;
    
    %Read Feature String
    str = fgetl(fid);
    for s=1:no_of_sentences_in_current_example
        count_of_sentences=count_of_sentences+1;
        str = fgetl(fid);
        [no_of_features remaining]=strtok(str);
        no_of_features= str2num(no_of_features);
        features_to_triggered=strread(remaining,'%s','delimiter',' ');
        for idx = 1:no_of_features-1
            [feature weight] = strtok(features_to_triggered(idx),':');
            weight = strrep(weight,':',' ');
            feature=str2double(strtrim(feature));
            weight=str2double(strtrim(weight));
            feature_vect(count_of_sentences,feature)=weight;
        end    
    end    
end
[x1, max_feature] = size(feature_vect)
fclose(fid);
disp('Train read done');