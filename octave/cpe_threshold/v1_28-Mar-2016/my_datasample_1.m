function selected_idx = my_datasample_1(wts, k)

if min(wts) < 0
    error('Items with negative probabilites present');
end

selected_idx = zeros(1,k);

% Start
for i = 1:k
    % Find the indices with positive probabilities and discard the rest
    posidx = find(wts > 0);
    poswts = wts(wts > 0);
    
    % Find the CDF
    cdf = cumsum(poswts);
    
    % Generate a random  number in the range
    r = rand*sum(cdf(end));
    
    sampleId = find(cdf >= r,1);
    
    % Put this sample in the selected set
    selected_idx(i) = posidx(sampleId);
    
    % Remove this from future consideration
    wts(selected_idx(i)) = 0;
end

end