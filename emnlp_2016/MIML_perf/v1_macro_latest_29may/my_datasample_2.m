% An accelerated method for the wswor problem
% Pavlos S. Efraimidis and Paul G. Spirakis, Weighted random sampling with a reservoir
% Information Processing Letters 97 (2006) 181�185

function selected_idx = my_datasample_2(wts, k)

if min(wts) < 0
    error('Items with negative probabilites present');
end

% Find the indices with positive probabilities and discard the rest
posidx = find(wts > 0);
poswts = wts(wts > 0);
np = length(posidx);

if(np < k)
    error('Not enough items with positive probabilities');
end

if(np == k)
    selected_idx = posidx;
    return;
end

u = exprnd(1,1,np);
key = u./poswts;
[dummy,idx] = sort(key,'ascend');

selected_idx = posidx(idx(1:k));

end