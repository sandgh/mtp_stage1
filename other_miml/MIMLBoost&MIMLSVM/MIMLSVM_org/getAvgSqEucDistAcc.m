% Get the average squared Euclidean distance between a set of points
% [avgSED] = getAvgSqEucDistAcc(X,n)
%   Output:
%       avgED: average Euclidean distance between a set of points
%   Input:
%       X: the set of points, each row is one data point
%		n: number of data points being sent in

function [avgSED] = getAvgSqEucDistAcc(X,n)
    n1 = size(X,1);
	if n1 ~= n
        error('Check your data matrix. Number of points does not match. Each row of the matrix should contain one data point.\n')
	end
    
    normsum = sum(sum(X.^2));
    vecsum = sum(X);
    dotsum = vecsum*vecsum';
    
    avgSED = 2*(n*normsum - dotsum)/(n*(n-1));
end