clc;
format shortG;
config = setConfig();
% 
% %% READ TRAININTG DATA
% disp('Reading training data...');
% %%read synth data
% % config = generate_sparse_synth_data(config);
% 
% %%read naacl files
% % config = read_naacl_data(config);
% 
% %%read naacl files in sparse format
% % config = read_sparse_naacl_data(config);
% 
% %%read stored data (to skip already read data)
% config = load_naacl_data(config);
% 
% disp('Reading validation data...');
% 
% % config = read_sparse_validation_naacl_data(config);
% config = load_validation_naacl_data(config);
% 
% %% READ TESTING DATA
% 
% disp('Reading test data...');
% %%read synth data
% % config = generate_sparse_test_synth_data(config);
% 
% %%read naacl files
% config = read_test_naacl_data(config);
% 
% %%read naacl files in sparse format
% % config = read_sparse_test_naacl_data(config);
% 
% %%read stored data (to skip already read data)
% config = load_test_naacl_data(config);
config = read_image_miml(config);

disp('data reading done...');

%% the k% loop
for k_percent = config.sntnce_k_prcnt
    
    config.sntnce_k_prcnt = k_percent;
    
    fid_parameters_thresh = fopen([config.result_file_name, '_thresh_', num2str(config.sntnce_k_prcnt), '.txt'], 'w');
    fid_parameters_fsc_cls = fopen([config.result_file_name, '_fsc_cls_', num2str(config.sntnce_k_prcnt), '.txt'], 'w');
    fid_parameters_fsc_all = fopen([config.result_file_name, '_fsc_all_', num2str(config.sntnce_k_prcnt), '.txt'], 'w');
    fid_parameters_precision_cls = fopen([config.result_file_name, '_precision_cls_', num2str(config.sntnce_k_prcnt), '.txt'], 'w');
    fid_parameters_recall_cls = fopen([config.result_file_name, '_recall_cls_', num2str(config.sntnce_k_prcnt), '.txt'], 'w');
    
    
    fclose(fid_parameters_thresh);
    fclose(fid_parameters_fsc_cls);
    fclose(fid_parameters_fsc_all);
    fclose(fid_parameters_precision_cls);
    fclose(fid_parameters_recall_cls);
    %% set params
    
    config.no_of_relns = size(config.gold_y_labels,2);
    config.no_of_snts = size(config.feature_vect,1);
    
    config.test_no_of_snts = size(config.test_feature_vect,1);
    
    % initialize
    config.cpe=zeros(config.no_of_snts,config.no_of_relns);
    config.thresholds=zeros(1,config.no_of_relns);
    config.test_fsc=zeros(1,config.no_of_relns);
    
    
    
    %% the initial guess of ylabels
    
    %initialize CPEs as 0.5
    config.cpe = zeros(config.no_of_snts, config.no_of_relns) + 0.5;
    config.epoch_curr = 1;
    config.thresholds = zeros(1,config.no_of_relns);
    % sentence label hidden vars (1000 snts X relations [binary labels])
    % y_labels = round(rand(config.no_of_snts,config.no_of_relns));
    
    config.pred_y_lbl = zeros(config.EPOCHS_COUNT, config.no_of_relns, length(config.test_ent_mntn_cnt));
    config.c_fsc_train = zeros(config.EPOCHS_COUNT, config.no_of_relns, length(config.c_range));
    config.TP=0;
    config.FN=0;
    config.FP=0;
    
    
     
       
    
    time_counter = 1;
    config.trn_time_counter = 1;
   
    %sentence label hidden vars (1000 snts X relations [binary labels])
    [ y_labels ] = gen_latent_rand_k( config );
    
    %@todo? - read the infer latent var result??
    
    
    %% open the results file
    
    % fid_parameters = fopen(config.result_file_name, 'w');
    % fprintf(fid_parameters,'\n-------------------- Start --------------------\n');
    % fclose(fid_parameters);
    
    
    %% train the model
    
    NO_OF_RELN = size(y_labels,2);
    
    %%call cpe with initial labels
    [config]  = cpe_train(config, y_labels);
    %find f-score
    
     t = clock;
    [config] = find_test_F_Score(config);
    test_time = etime(clock,t);
    config.time_results_test(time_counter, :) = [config.epoch_curr-1, test_time];
    time_counter = time_counter+1;
    time_results_test = config.time_results_test;
    save([config.result_file_name, '_time_test.mat'], 'time_results_test');
    
    
    
    %write the final f-scores to file
    write_results_to_file( config );
    
    
    config.TP=0;
    config.FN=0;
    config.FP=0;
    
    %% update mentionlabels as per the curr thresh & cpe
    
    %@todo - decide the stopping criteria
    for i = 1:config.EPOCHS_COUNT
        
        %% update y labels as per the curr thresholds
        
        %     y_labels = config.cpe.*0;
        %     for r = 1:NO_OF_RELN
        %         y_labels(config.cpe(:,r)>config.thresholds(1,r),r) = 1;
        %     end
        
        %find sentence label hidden vars
        %     [ y_labels ] = gen_latent_rand_k( config );
        
        %choose k senceses from the ent_pair
        %k depends on how many sntnces >thresh
        [ y_labels ] = gen_latent_cpe_k( config );
        
        
        [config]  = cpe_train(config, y_labels);
        
        
        %% testing
        
        t = clock;
        [config] = find_test_F_Score(config);
        test_time = etime(clock,t);
        config.time_results_test(time_counter, :) = [config.epoch_curr-1, test_time];
        time_counter = time_counter+1;
        time_results_test = config.time_results_test;
        save([config.result_file_name, '_time_test.mat'], 'time_results_test');
        
        
        write_results_to_file( config );
        
        config.TP=0;
        config.FN=0;
        config.FP=0;
        
        
    end  %% end of epochs
    
    save_pred_y_lbls = config.pred_y_lbl;
    save([config.result_file_name , num2str(k_percent) ,'_pred_y_lbls.mat'], 'save_pred_y_lbls');
    
    
    save_c_fsc = config.c_fsc_train;
    save([config.result_file_name , num2str(k_percent) ,'_save_c_fsc.mat'], 'save_c_fsc');
    
end %% end of the k% loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
