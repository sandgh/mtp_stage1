%%% This function
%%%
%%%


function[threshold , max_f_score,precision,recall] = find_best_thresh_micro(config, cpe,c)

%% sort cpes (1st col of CPE is the +ve class)

global_cpe= reshape(cpe,size(cpe,1)*size(cpe,2),1);
sort_cpe = unique(sort(global_cpe(:,1)));

%get the threshold ranges (mid val of every pair)
% sort_cpe_thresh = unique((sort_cpe + [sort_cpe(2:end,1);0 ])/2);
sort_cpe_thresh1 = (sort_cpe + [sort_cpe(2:end,1);0 ])/2;
sort_cpe_thresh = unique(round(sort_cpe_thresh1*10000))/10000;


[thr_row, thr_col] = size(sort_cpe_thresh);


%% find max f-score from all the thresholds
temp_f_sc_thresh = zeros(length(sort_cpe_thresh),1);
max_f_score = 0;
thersh_idx = 1;

for i=1:thr_row
    
    [temp_fsc, p ,r]= find_F_Score_threshold(config, cpe, sort_cpe_thresh(i,1),c);
    temp_f_sc_thresh(i,1) = temp_fsc;
    if(temp_fsc > max_f_score)
        thersh_idx = i;
        max_f_score = temp_fsc;
        precision=p;
        recall=r;
    end
    [config.epoch_curr config.current_c i thr_row sort_cpe_thresh(i,1) temp_fsc max_f_score]
    
end
% disp(max_f_score);
threshold =  sort_cpe_thresh(thersh_idx,1);




%% search for only thresh lmt

sort_cpe_thresh1 = unique((sort_cpe + [sort_cpe(2:end,1);0 ])/2);
sort_cpe_thresh = sort_cpe_thresh1(sort_cpe_thresh1<=(threshold+.01) & sort_cpe_thresh1>=(threshold-.01));

[thr_row, thr_col] = size(sort_cpe_thresh);


%%find max f-score from all the thresholds
temp_f_sc_thresh = zeros(length(sort_cpe_thresh),1);
max_f_score = 0;
thersh_idx = 1;

for i=1:thr_row
    
    [temp_fsc, p ,r]= find_F_Score_threshold(config, cpe, sort_cpe_thresh(i,1),c);
    temp_f_sc_thresh(i,1) = temp_fsc;
    if(temp_fsc > max_f_score)
        thersh_idx = i;
        max_f_score = temp_fsc;
        precision=p;
        recall=r;
    end
    [config.epoch_curr config.current_c i sort_cpe_thresh(i,1) thr_row temp_fsc max_f_score]
    
end



%% plot graph

% figure;
% plot(sort_cpe_thresh', temp_f_sc_thresh', 'b-x');

end

