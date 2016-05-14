function [ ] = write_results_to_file( config )

fid_parameters_thresh = fopen([config.result_file_name, '_thresh_', num2str(config.sntnce_k_prcnt), '.txt'], 'a');
fid_parameters_fsc_cls = fopen([config.result_file_name, '_fsc_cls_', num2str(config.sntnce_k_prcnt), '.txt'], 'a');
fid_parameters_fsc_all = fopen([config.result_file_name, '_fsc_all_', num2str(config.sntnce_k_prcnt), '.txt'], 'a');

% fprintf(fid_parameters,'\n---------------------------------\n');


%% prints F-Score for each class
% fprintf(fid_parameters, 'Thresh \t F_score\n');
for i=1:config.no_of_relns
    
    fprintf(fid_parameters_fsc_cls, '%f,',config.f_score(i,1));
    fprintf(fid_parameters_thresh, '%f,',config.thresholds(1,i));
        
end

fprintf(fid_parameters_fsc_cls, '\n');
fprintf(fid_parameters_thresh, '\n');

%% prints total F-Score (sum_f_score/no_of_relns)

precision=config.TP/(config.TP+config.FP);
recall=config.TP/(config.TP+config.FN);
f_micro=2*precision*recall/(precision+recall);

fprintf(fid_parameters_fsc_all,'\n');
% fprintf(fid_parameters, '%f', sum(config.f_score(:,1))/config.pstv_train_classes);
fprintf(fid_parameters_fsc_all, '%f', sum(config.f_score(:,1).*config.f_score_flag(:,1))/sum(config.f_score_flag(:,1)));
fprintf(fid_parameters_fsc_all, ' ( %d )', sum(config.f_score_flag(:,1)));
fprintf(fid_parameters_fsc_all, ' precision %f ', precision);
fprintf(fid_parameters_fsc_all, ' recall %f ', recall);
fprintf(fid_parameters_fsc_all, ' f-micro %f ', f_micro);
% fprintf(fid_parameters,'\n---------\n');

%% close the file

fclose(fid_parameters_thresh);
fclose(fid_parameters_fsc_cls);
fclose(fid_parameters_fsc_all);

config.TP=0;
config.FN=0;
config.FP=0;


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
