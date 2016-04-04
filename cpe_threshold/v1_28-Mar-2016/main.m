clc; 
config = setConfig();

%% read synth data
% config = generate_synth_data(config);

%% read naacl files
config = read_naacl_data(config);


%% read stored data (to skip already read data)
% config = load_naacl_data(config);


%% set params

config.no_of_relns = size(config.gold_y_labels,2);
config.no_of_snts = size(config.feature_vect,1);

% initialize
config.cpe=zeros(config.no_of_snts,config.no_of_relns);
config.thresholds=zeros(1,config.no_of_relns);


%% the initial guess of ylabels

% sentence label hidden vars (1000 snts X relations [binary labels])
y_labels = round(rand(config.no_of_snts,config.no_of_relns));

%@todo? - read the infer latent var result??



%% train the model

NO_OF_RELN = size(y_labels,2);

%%call cpe with initial labels
[config]  = cpe_train(config, y_labels);


%% update mentionlabels as per the curr thresh & cpe

%@todo - decide the stopping criteria
for i = 1:config.EPOCHS_COUNT
    
    %update y labels as per the curr thresholds
    
    y_labels = config.cpe.*0;
    
    for r = 1:NO_OF_RELN
        y_labels(config.cpe(:,r)>config.thresholds(1,r),r) = 1;
    end
    
    [config]  = cpe_train(config, y_labels);
    
end


%% @todo - write the testing code





%% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%