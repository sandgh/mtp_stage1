%%% This function
%%%
%%%


function[threshold , max_f_score] = find_best_thresh(config, cpe,c)

%% sort cpes (1st col of CPE is the +ve class)
sort_cpe = sort(cpe(:,1));

%get the threshold ranges (mid val of every pair)
sort_cpe_thresh = unique((sort_cpe + [sort_cpe(2:end,1);0 ])/2);

[thr_row, thr_col] = size(sort_cpe_thresh);


%% find max f-score from all the thresholds
temp_f_sc_thresh = zeros(length(sort_cpe_thresh),1);
max_f_score = 0;
thersh_idx = 1;

temp_var = zeros(thr_row, 2);


for i=1:thr_row
    
    temp_fsc = find_F_Score_threshold(config, cpe, sort_cpe_thresh(i,1),c);
    temp_f_sc_thresh(i,1) = temp_fsc;
    if(temp_fsc > max_f_score)
        thersh_idx = i;
        max_f_score = temp_fsc;
    end
    [config.epoch_curr config.current_c config.current_reln i thr_row sort_cpe_thresh(i,1)  temp_fsc max_f_score]
end
threshold =  sort_cpe_thresh(thersh_idx,1);

figure;
plot(sort_cpe_thresh', temp_f_sc_thresh');%, 'b--o'


%% With 4d prec
% sort_cpe_thresh1 = (sort_cpe + [sort_cpe(2:end,1);0 ])/2;
% sort_cpe_thresh = unique(round(sort_cpe_thresh1*1000))/1000;
% 
% 
% [thr_row, thr_col] = size(sort_cpe_thresh);
% 
% 
% %% find max f-score from all the thresholds
% temp_f_sc_thresh = zeros(length(sort_cpe_thresh),1);
% max_f_score = 0;
% thersh_idx = 1;
% 
% temp_var = zeros(thr_row, 2);
% 
% 
% for i=1:thr_row
%     
%     temp_fsc = find_F_Score_threshold(config, cpe, sort_cpe_thresh(i,1),c);
%     temp_f_sc_thresh(i,1) = temp_fsc;
%     if(temp_fsc > max_f_score)
%         thersh_idx = i;
%         max_f_score = temp_fsc;
%     end
%     [config.epoch_curr config.current_c config.current_reln i thr_row sort_cpe_thresh(i,1)  temp_fsc max_f_score]
% end
% threshold =  sort_cpe_thresh(thersh_idx,1);
% 
% figure;
% plot(sort_cpe_thresh', temp_f_sc_thresh');%, 'b--o'

%% search for only thresh lmt

sort_cpe_thresh1 = unique((sort_cpe + [sort_cpe(2:end,1);0 ])/2);
sort_cpe_thresh = sort_cpe_thresh1(sort_cpe_thresh1<=(threshold+.01) & sort_cpe_thresh1>=(threshold-.01));

[thr_row, thr_col] = size(sort_cpe_thresh);


%%find max f-score from all the thresholds
temp_f_sc_thresh = zeros(length(sort_cpe_thresh),1);
max_f_score = 0;
thersh_idx = 1;

for i=1:thr_row
    
    temp_fsc= find_F_Score_threshold(config, cpe, sort_cpe_thresh(i,1),c);
    temp_f_sc_thresh(i,1) = temp_fsc;
    if(temp_fsc > max_f_score)
        thersh_idx = i;
        max_f_score = temp_fsc;
    end
    [config.epoch_curr config.current_c config.current_reln i sort_cpe_thresh(i,1) thr_row temp_fsc max_f_score]
    
end


disp(max_f_score);
threshold =  sort_cpe_thresh(thersh_idx,1);

figure;
plot(sort_cpe_thresh', temp_f_sc_thresh'); %, 'b-x'
end



%% binary search code
% 
% mid = ceil(thr_row/2);
% last = thr_row - 1;
% start = 1;
% 
% 
% while(1)
%     
%     temp_fsc= find_F_Score_threshold(config, cpe, sort_cpe_thresh(mid,1),c);
%     temp_fsc1 = temp_fsc;
%     temp_var(mid,:) = [sort_cpe_thresh(mid,1), temp_fsc];
%     
%     if(temp_fsc == 1)
%         thersh_idx = mid;
%         max_f_score = temp_fsc;
%         
%         break;
%     end
%     
%     i = 1;
%     while(temp_fsc1 == temp_fsc && mid+i <= last)
%        temp_fsc1= find_F_Score_threshold(config, cpe, sort_cpe_thresh(mid+i,1),c);
%         temp_var(mid+i,:) = [sort_cpe_thresh(mid+i,1), temp_fsc1];
%         i=i+1;
%     end
%     j = 1;
%     temp_fsc2 = temp_fsc;
%     
%     while(temp_fsc2 == temp_fsc && mid-j >= start)
%         temp_fsc2= find_F_Score_threshold(config, cpe, sort_cpe_thresh(mid-j,1),c);
%         temp_var(mid-j,:) = [sort_cpe_thresh(mid-j,1), temp_fsc2];
%         j=j+1;
%     end
%     
%     if(temp_fsc1 > temp_fsc)
%         start = mid+i-1;
%         mid = ceil(mid+i-1 + (last - (mid+i-1))/2);
%         continue;
%     end
%     if(temp_fsc2 > temp_fsc)
%         last = mid-j+1;
%         mid = ceil((start+ mid-j+1)/2);
%         continue;
%     end
%     if(temp_fsc2 <= temp_fsc && temp_fsc1 <= temp_fsc)
%         thersh_idx = mid;
%         max_f_score = temp_fsc;
%        
%         break;
%     end
%     
%     
% end
% 
