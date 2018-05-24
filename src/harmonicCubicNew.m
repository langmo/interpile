function S = harmonicCubicNew(height, width )
if nargin < 1
    width = 5;
    height = 6;
end
N = height;
S = zeros(N, N);

% x0=ceil(sqrt(3)*(N+1)/2)-1;
% y0 = -(N+1)/2;
% F = @(y,x) ((x+x0).^3-3*(x+x0).*(y+y0).^2);


x0=ceil(sqrt(3)*(N+1)/2)-1;
y0 = -(N+1)/2;
F = @(y,x) ((x+x0).^3-3*(x+x0).*(y+y0).^2);

S(:, 1) = S(:, 1)+F((1:N)', 0);
S(:, end) = S(:, end)+F((1:N)', N+1);
S(1, :) = S(1, :) + F(0, 1:N);
S(end, :) = S(end, :) + F(N+1, 1:N);
S=(4*S);
S = (S-floor(S(1,1)/2)*harmonicO(N,N));
end

