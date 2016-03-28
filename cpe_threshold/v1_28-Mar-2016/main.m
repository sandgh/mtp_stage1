clc; clear;


%% sert config vals
config.feature_vect = rand(1000,10)*10;
y_labels = round(rand(1000,5));
config.gold_y_labels = round(rand(200,5));
config.ent_mntn_cnt = zeros(200,1) + 5;



%% train the model
[models, thresholds]  = cpe_train(config, y_labels);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%