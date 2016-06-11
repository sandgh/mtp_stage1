clc; 
config = setConfig();

%% read examples

filename = 'v.small.data';
fid = fopen(filename);
num_egs=fscanf(fid,'%d',1);
NO_OF_RELN=fscanf(fid,'%d',1);
config.cpe=zeros(count_of_sentences,NO_OF_RELN);
config.ent_mntn_cnt=zeros(num_egs,1);                           %%%%%%%%%%%%%%%    to store no of sentences in each example
max_feature=56648;
count_of_sentences=0;
config.gold_y_labels=zeros(num_egs,NO_OF_RELN+1);                        %%%%%%%%%%%%%%%%% gold_db_matrix x vs y
for n = 1:num_egs
    no_of_relations_in_current_example=fscanf(fid, '%d',1);
    for r=1:no_of_relations_in_current_example
        relationid=fscanf(fid,'%d',1);
        config.gold_y_labels(n,relationid)=1;
    end
    
    no_of_sentences_in_current_example=fscanf(fid, '%d',1);
    config.ent_mntn_cnt(n,1)=no_of_sentences_in_current_example;
    
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
            config.feature_vect(count_of_sentences,feature)=weight;
        end    
    end    
end
y_labels = round(rand(count_of_sentences,NO_OF_RELN));


% %% generate synth data
% % 
% % sentence label (1000 snts X 10 dim)
% config.feature_vect = rand(1000,10)*10;
% 
% % sentence label hidden vars (1000 snts X relations [binary labels])
% y_labels = round(rand(1000,5));
% 
% % ent label (ent_pair X relns)
% config.gold_y_labels = round(rand(200,5));
% 
% % mentions/ent_pair (5 each here)
% config.ent_mntn_cnt = zeros(200,1) + 5;
% 
% NO_OF_RELN=5;
%% @todo - read naacl files



%% train the model



%%call cpe with initial labels
[thresh, config]  = cpe_train(config, y_labels);


%% update mentionlabels as per the curr thresh & cpe

%@todo - decide the stopping criteria
for i = 1:config.EPOCHS_COUNT
    
    %update y labels as per the curr thresholds
    
    y_labels = config.cpe.*0;
    
    for r = 1:NO_OF_RELN
        y_labels(config.cpe(:,r)>thresh(1,r),r) = 1;
    end
    
    [thresh, config]  = cpe_train(config, y_labels);
    
end
%% @todo - write the tesing code





%% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%