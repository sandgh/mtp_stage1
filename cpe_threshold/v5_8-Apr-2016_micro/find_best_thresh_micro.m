%%% This function
%%%
%%%


function[threshold , max_f_score,precision,recall] = find_best_thresh_micro(config, cpe,c)

%% sort cpes (1st col of CPE is the +ve class)

global_cpe= reshape(cpe,size(cpe,1)*size(cpe,2),1);
sort_cpe = unique(sort(global_cpe(:,1)));

%get the threshold ranges (mid val of every pair)
sort_cpe_thresh = (sort_cpe + [sort_cpe(2:end,1);0 ])/2;

[thr_row, thr_col] = size(sort_cpe_thresh);


%% find max f-score from all the thresholds

max_f_score = 0;
thersh_idx = 1;

temp_var = zeros(thr_row, 2);

% for i=1:thr_row-1
%
%     [temp_fsc, p ,r]= find_F_Score_threshold(config, cpe, sort_cpe_thresh(i,1),c);
%
%     temp_var(i,:) = [sort_cpe_thresh(i,1), temp_fsc];
%
%     if(temp_fsc > max_f_score)
%         thersh_idx = i;
%         max_f_score = temp_fsc;
%         precision=p;
%         recall=r;
%     end
%
% end
%
mid = ceil(thr_row/2);
last = thr_row - 1;
start = 1;


while(1)
    
    [temp_fsc, p ,r]= find_F_Score_threshold(config, cpe, sort_cpe_thresh(mid,1),c);
    temp_fsc1 = temp_fsc;
    temp_var(mid,:) = [sort_cpe_thresh(mid,1), temp_fsc];
    
    if(temp_fsc == 1)
        thersh_idx = mid;
        max_f_score = temp_fsc;
        precision=p;
        recall=r;
        break;
    end
    
    i = 1;
    while(temp_fsc1 == temp_fsc && mid+i <= last)
        [temp_fsc1, p1 ,r1]= find_F_Score_threshold(config, cpe, sort_cpe_thresh(mid+i,1),c);
        temp_var(mid+i,:) = [sort_cpe_thresh(mid+i,1), temp_fsc1];
        i=i+1;
    end
    j = 1;
    temp_fsc2 = temp_fsc;
    
    while(temp_fsc2 == temp_fsc && mid-j >= start)
        [temp_fsc2, p2 ,r2]= find_F_Score_threshold(config, cpe, sort_cpe_thresh(mid-j,1),c);
        temp_var(mid-j,:) = [sort_cpe_thresh(mid-j,1), temp_fsc2];
        j=j+1;
    end
    
    if(temp_fsc1 > temp_fsc)
        start = mid+i-1;
        mid = ceil(mid+i-1 + (last - (mid+i-1))/2);
        continue;
    end
    if(temp_fsc2 > temp_fsc)
        last = mid-j+1;
        mid = ceil((start+ mid-j+1)/2);
        continue;
    end
    if(temp_fsc2 < temp_fsc && temp_fsc1 < temp_fsc)
        thersh_idx = mid;
        max_f_score = temp_fsc;
        precision=p;
        recall=r;
        break;
    end
    
    
end


disp(max_f_score);
threshold =  sort_cpe_thresh(thersh_idx,1);

end