function S = harmonicCubicSym(height, width )
if nargin < 1
    width = 5;
    height = 7;
end
N = height;
S = zeros(N, N);
if 0
F = @(y,x) (x-(N+1)/2).^3-3*(x-(N+1)/2).*(y-(N+1)/2).^2;

S(1:N, 1)=S(1:N, 1)+F((1:N)',0);
 S(1:N, end)=S(1:N, end)+F((1:N)',N+1);
 S(1, 1:N)=S(1, 1:N)+F(0,1:N);
 S(end, 1:N)=S(end, 1:N)+F(N+1,1:N);
% k = ceil(-min(min(S))/2);
% S=(S+k*harmonicO(N,N));
% k = ceil(-min(min(S)));
% S=(S+k*harmonicO(N,N));
k = -S(1, end-1);
S=(S+k*harmonicO(N,N));
end

FC = @(y,x) x.^3 -3*x.*y.^2 ;
 FH = @(y,x) -(y).^2+(x).^2;
 
F = @(y,x) FC(y,x)-(N+1)*FH(y,x-(N+1)/2)+((N+1)/2)^2*(N+1-x);

S(1:N, 1)=S(1:N, 1)+F((-(N-1)/2:(N-1)/2)',0);
 S(1:N, end)=S(1:N, end)+F((-(N-1)/2:(N-1)/2)',N+1);
 S(1, 1:N)=S(1, 1:N)+F(-(N+1)/2,1:N);
 S(end, 1:N)=S(end, 1:N)+F((N+1)/2,1:N);
 
  x = 0:(N+1);
 y=(-(N+1)/2:(N+1)/2)';
  X = repmat(x, length(y), 1);
 Y = repmat(y, 1, length(x));
 F(Y,X)
end

