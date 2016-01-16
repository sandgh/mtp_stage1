function [theta] = calculateTheta(matrix)

theta = nnz(matrix==0)/nnz(matrix==1);

end