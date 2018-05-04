function S = harmonicCross(height, width )
if nargin < 1
    width = 12;
    height = 6;
end
assert(mod(width, 2)==0&&mod(height, 2)==0);

S = zeros(height, width);
S(height/2, 1:width/2) = S(height/2, 1:width/2) + (1:width/2);
S(height/2+1, 1:width/2) = S(height/2+1, 1:width/2) + (1:width/2);

S(height/2, width/2+1:end) = S(height/2, width/2+1:end) + (width/2:-1:1);
S(height/2+1, width/2+1:end) = S(height/2+1, width/2+1:end) + (width/2:-1:1);

S(1:height/2, width/2) = S(1:height/2, width/2) + (1:height/2)';
S(1:height/2, width/2+1) = S(1:height/2, width/2+1) + (1:height/2)';

S(height/2+1:end, width/2) = S(height/2+1:end, width/2) + (height/2:-1:1)';
S(height/2+1:end, width/2+1) = S(height/2+1:end, width/2+1) + (height/2:-1:1)';
end

