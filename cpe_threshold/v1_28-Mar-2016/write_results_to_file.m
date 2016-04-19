function [ ] = write_results_to_file( config )

fid_parameters = fopen(config.result_file_name, 'a');

fprintf(fid_parameters,'\n---------------------------------\n');


%% prints F-Score for each class
fprintf(fid_parameters, 'Thresh \t F_score\n');
for i=1:config.no_of_relns
    
    fprintf(fid_parameters, '%f \t %f\n',config.thresholds(1,i), config.f_score(i,1));
    
end

%% prints total F-Score (sum_f_score/no_of_relns)

fprintf(fid_parameters,'---------\n');
fprintf(fid_parameters, '%f', sum(config.f_score(:,1))/config.pstv_train_classes);
fprintf(fid_parameters, ' ( %d )', config.pstv_train_classes);
fprintf(fid_parameters,'\n---------\n');

%% close the file

fclose(fid_parameters);


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
