clc; 
config = setConfig();

%% generate synth data

% sentence label (1000 snts X 10 dim)
config.feature_vect = rand(1000,10)*10;

% sentence label hidden vars (1000 snts X relations [binary labels])
y_labels = round(rand(1000,5));

% ent label (ent_pair X relns)
config.gold_y_labels = round(rand(200,5));

% mentions/ent_pair (5 each here)
config.ent_mntn_cnt = zeros(200,1) + 5;


%% @todo - read naacl files



%% train the model

NO_OF_RELN = size(y_labels,2);

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