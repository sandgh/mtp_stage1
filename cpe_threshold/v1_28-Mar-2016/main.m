clc; 
config = setConfig();

%% READ TRAININTG DATA

%%read synth data
config = generate_synth_data(config);

%%read naacl files
% config = read_naacl_data(config);


%%read stored data (to skip already read data)
% config = load_naacl_data(config);


%% READ TESTING DATA

%%read synth data
config = generate_test_synth_data(config);

%%read naacl files
% config = read_test_naacl_data(config);


%%read stored data (to skip already read data)
% config = load_test_naacl_data(config);


%% set params

config.no_of_relns = size(config.gold_y_labels,2);
config.no_of_snts = size(config.feature_vect,1);

config.test_no_of_snts = size(config.test_feature_vect,1);

% initialize
config.cpe=zeros(config.no_of_snts,config.no_of_relns);
config.thresholds=zeros(1,config.no_of_relns);
config.test_fsc=zeros(1,config.no_of_relns);



%% the initial guess of ylabels

% sentence label hidden vars (1000 snts X relations [binary labels])
y_labels = round(rand(config.no_of_snts,config.no_of_relns));

%@todo? - read the infer latent var result??


%% open the results file

fid_parameters = fopen(config.result_file_name, 'a');
fprintf(fid_parameters,'\n-------------------- Start --------------------\n');
fclose(fid_parameters);


%% train the model

NO_OF_RELN = size(y_labels,2);

%%call cpe with initial labels
[config]  = cpe_train(config, y_labels);
%find f-score
[config] = find_test_F_Score(config);
%write the final f-scores to file
write_results_to_file( config );

%% update mentionlabels as per the curr thresh & cpe

%@todo - decide the stopping criteria
for i = 1:config.EPOCHS_COUNT
    
    %% update y labels as per the curr thresholds
    
    y_labels = config.cpe.*0;
    
    for r = 1:NO_OF_RELN
        y_labels(config.cpe(:,r)>config.thresholds(1,r),r) = 1;
    end
    
    [config]  = cpe_train(config, y_labels);
    
    
   %% testing
   
   [config] = find_test_F_Score(config);
   
   %write the final f-scores to file
   write_results_to_file( config );
   
   
   
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%