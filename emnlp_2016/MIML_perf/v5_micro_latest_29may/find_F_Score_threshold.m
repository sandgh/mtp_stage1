%%% This function
%%%
%%%



function [f_score, p, r] = find_F_Score_threshold(config, cpe, thresh ,c)


%% make cpes > thresh = 1
cpe_binary = cpe.*0;
cpe_binary(cpe>thresh) = 1;


%% find the f_score for this classs
[ent_mntn_cnt_row, ent_mntn_cnt_col] = size(config.ent_mntn_cnt);

count=0;
predicted_y_labels = zeros(ent_mntn_cnt_row,config.no_of_relns);

for j=1:size(cpe,2)
    for i=1:ent_mntn_cnt_row
        
        %the atleast one assumption
        %check if any of the mention is 1 for curr reln for the curr ent_pair
        %%@todo find the MAX
        predicted_y_labels(i,j) = sum(cpe_binary(count+1:config.ent_mntn_cnt(i,1)+count,j))>0;
        
        %set the count to the last mention of the curr ent pair
        %in the next loop we start from count+1
        count = config.ent_mntn_cnt(i,1)+count;
        
        
    end
    
    count=0;
end

%% f_score = 2 * ( sum (y'.*y) ) / ( sum (y') + sum (y) )
%f_score = 2*sum(predicted_y_labels.*config.gold_y_labels(:,relation))/(sum(predicted_y_labels) + sum(config.gold_y_labels(:,relation)));

TP =  sum(sum(predicted_y_labels.*config.gold_y_labels));
FP =  sum(sum(predicted_y_labels.*(1-config.gold_y_labels)));
FN = sum(sum((1-predicted_y_labels).*config.gold_y_labels));

% fid_parameters_fsc_all_training = fopen([config.result_file_name_train, '_train_all_.txt'], 'a');


precision=TP/(TP+FP);
recall=TP/(TP+FN);
f_micro=2*precision*recall/(precision+recall);
% 
% fprintf(fid_parameters_fsc_all_training,'\n');
% fprintf(fid_parameters_fsc_all_training, ' c %f ', c);
% 
% 
% % fprintf(fid_parameters, '%f', sum(config.f_score(:,1))/config.pstv_train_classes);
% fprintf(fid_parameters_fsc_all_training, ' threshold %f ', thresh);
% fprintf(fid_parameters_fsc_all_training, ' precision %f ', precision);
% fprintf(fid_parameters_fsc_all_training, ' recall %f ', recall);
% fprintf(fid_parameters_fsc_all_training, ' f-micro %f ', f_micro);

f_score=f_micro;
p=precision;
r=recall;
% fclose(fid_parameters_fsc_all_training);

end