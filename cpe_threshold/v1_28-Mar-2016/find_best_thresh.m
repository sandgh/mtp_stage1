%%% This function
%%%
%%%


function[threshold , max_f_score] = find_best_thresh(config, cpe,relation)

    %% sort cpes (1st col of CPE is the +ve class)
    sort_cpe = sort(cpe(:,1));
    
    %get the threshold ranges (mid val of every pair)
    sort_cpe_thresh = (sort_cpe + [sort_cpe(2:end,1);0 ])/2; 
    
    [thr_row, thr_col] = size(sort_cpe_thresh);
    
    
    %% find max f-score from all the thresholds
    
    max_f_score = 0;
    thersh_idx = 1;
    
    
    for i=1:thr_row
        
        temp_fsc = find_F_Score_threshold(config, cpe, sort_cpe_thresh(i,1),relation);
        if(temp_fsc > max_f_score)
            thersh_idx = i;
            max_f_score = temp_fsc;
        end
            
    end
   max_f_score
   threshold =  sort_cpe_thresh(thersh_idx,1);
    
end