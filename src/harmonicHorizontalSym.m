function S = harmonicHorizontalSym(height, width )
if nargin < 1
    width = 4;
    height = 7;
end
N = height;

 F = @(y,x) -(y-(N+1)/2).^2+(x-(N+1)/2).^2;
 S=zeros(N,N);
 S(1:N, 1)=S(1:N, 1)+F((1:N)',0);
 S(1:N, end)=S(1:N, end)+F((1:N)',N+1);
 S(1, 1:N)=S(1, 1:N)+F(0,1:N);
 S(end, 1:N)=S(end, 1:N)+F(N+1,1:N);
k = ceil(((N+1)/2)^2-(1/2)^2);
S=(S+k*harmonicO(N,N));
if mod(N,2)==0
    S = S/2;
end
end

