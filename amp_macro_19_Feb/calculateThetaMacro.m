function [theta_vect] = calculateThetaMacro(matrix)

[row, col] = size(matrix);
theta_vect = ((row-sum(matrix))./sum(matrix))';

end