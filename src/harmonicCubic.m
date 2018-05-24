function S = harmonicCubic(height, width )
if nargin < 1
    width = 5;
    height = 4;
end
N = height;
S = zeros(N, N);

F = @(y,x) x.^3-3*x.*y.^2;

N0=ceil(sqrt(3)*(N+1)/2)-1;

% x=N0:N0+N+1;
% y=(-(N+1)/2:(N+1)/2)';
% 
% X = repmat(x, length(y), 1);
% Y = repmat(y, 1, length(x));
% F(Y, X)

S(:, 1) = S(:, 1)+F((-(N-1)/2:(N-1)/2)', N0);
S(:, end) = S(:, end)+F((-(N-1)/2:(N-1)/2)', N0+N+1);
S(1, :) = S(1, :) + F(-(N+1)/2, N0+1:N0+N);
S(end, :) = S(end, :) + F(+(N+1)/2, N0+1:N0+N);
end

