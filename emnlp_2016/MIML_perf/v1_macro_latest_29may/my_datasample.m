function [ selected_idxs ] = my_datasample( probabilities, k )


%% find the cdf
cdf = cumsum(probabilities);


%% maintain the original index positions
org_idx = 1:size(probabilities,2);
count = 0;
selected_idxs = zeros(1,k);


%% loop while k values are not selected
while count < k
    
    
    %% generate a random no. in the range (in our case cum sum can be <> 1)
    r = rand*sum(probabilities);
    
    
    %% take the first index which crosses the random no.
    idx = find(cdf>r);
    if(size(idx,2)>0)
        
        %the selected index should be the original index
        %must not be the modified index after deleting the selected values
        selected_idxs(1,count+1) =  org_idx(1,idx(1));
        
        %we need to sample without replacement, 
        %hence deleting the already selected values
        probabilities(idx(1)) = [];
        org_idx(idx(1)) = [];
        
        %recalculate the cdf
        %a bit confused about this step, 
        %what will happen if we skip this ( need to check )
        cdf = cumsum(probabilities);
        count = count+1;
    end
    
    
end

end

