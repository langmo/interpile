function S = harmonicT(height, width )
if nargin < 1
    width = 9;
    height = 8;
end

S = zeros(height, width);
S(1:height/2, width) = S(1:height/2, width) + (width+1) * (1:height/2)';
S(height/2+1:1:end, width) = S(height/2+1:1:end, width) + (width+1) * (height/2:-1:1)';

S(height/2, 1:width) = S(height/2, 1:width) + (1:width);
S(height/2+1, 1:width) = S(height/2+1, 1:width) + (1:width);
end

