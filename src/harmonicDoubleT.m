function S = harmonicDoubleT(height, width )
if nargin < 1
    width = 10;
    height = 6;
end
assert(mod(width, 2)==0&&mod(height, 2)==0);

S = zeros(height, width);

S(1, 1:width/2) = S(1, 1:width/2) + (1:width/2);
S(end, 1:width/2) = S(end, 1:width/2) + (1:width/2);

S(1, width/2+1:1:end) = S(1, width/2+1:1:end) + (width/2:-1:1);
S(end, width/2+1:1:end) = S(end, width/2+1:1:end) + (width/2:-1:1);

S(1:end, width/2) = S(1:end, width/2)+1;
S(1:end, width/2+1) = S(1:end, width/2+1)+1;
end

