function S = harmonicCubicTest(height, width )
if nargin < 1
    width = 5;
    height = 7;
end
N = height;
S = harmonicCubic(N,N)+(N+1)*harmonicHorizontal(N);
end

