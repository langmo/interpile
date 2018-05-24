function S = harmonicHorizontal(height, width )
if nargin < 1
    width = 4;
    height = 4;
end
N = height;
S = zeros(height, height);
if mod(N, 2) == 1
    F = @(y,x) -(y-(N+1)/2).^2+(x+(N+1)/2-1).^2;
else
    F = @(y,x) (-(y-(N+1)/2).^2+(x+(N+1)/2-1).^2)./2;
end


S(1, 1:N) = S(1, 1:N) + F(0, 1:N);
S(N, 1:N) = S(N, 1:N) + F(N+1, 1:N);

S(1:N, 1) = S(1:N, 1) + F((1:N)', 0);
S(1:N, N) = S(1:N, N) + F((1:N)', N+1);
end

