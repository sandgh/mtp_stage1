clc; 
setConfig();

%% generate synth data
% sentence label (1000 snts X 10 dim)
config.feature_vect = rand(1000,10)*10;
% sentence label hidden vars (1000 snts X relations [binary labels])
y_labels = round(rand(1000,5));
% ent label (ent_pair X relns)
config.gold_y_labels = round(rand(200,5));
% mentions/ent_pair (5 each here)
config.ent_mntn_cnt = zeros(200,1) + 5;


%% train the model
[models, thresholds]  = cpe_train(config, y_labels);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%