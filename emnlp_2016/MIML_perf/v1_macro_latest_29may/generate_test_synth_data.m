%%%
%%%
%%%

function [ config ] = generate_test_synth_data( config )

% sentence label (1000 snts X 10 dim)
config.test_feature_vect = rand(200,10)*10;

% ent label (ent_pair X relns)
config.test_gold_y_labels = round(rand(50,5));

% mentions/ent_pair (5 each here)
config.test_ent_mntn_cnt = zeros(50,1) + 4;

end

