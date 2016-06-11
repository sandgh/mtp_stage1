config = setConfig();

%% READ TRAININTG DATA

disp('Reading training data...');
%%read synth data
% config = generate_sparse_synth_data(config);

%%read naacl files
% config = read_naacl_data(config);

%%read naacl files in sparse format
config = read_sparse_naacl_data(config);

%%read stored data (to skip already read data)
% config = load_naacl_data(config);


%% READ TESTING DATA

disp('Reading test data...');
%%read synth data
% config = generate_sparse_test_synth_data(config);

%%read naacl files
% config = read_test_naacl_data(config);

%%read naacl files in sparse format
% config = read_sparse_test_naacl_data(config);

%%read stored data (to skip already read data)
% config = load_test_naacl_data(config);


disp('data reading done...');
