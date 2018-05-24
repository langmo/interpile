function S = harmonicCubicNoRot(height, width )
if nargin < 1
    width = 5;
    height = 4;
end
N = height;
 S = (harmonicCubic(N, N)+(N+1)*harmonicHorizontal(N,N));%-17*harmonicO(N,N))./2
 S = S./2;
 S = S - floor(S(1,1)/2)*harmonicO(N,N);
end

