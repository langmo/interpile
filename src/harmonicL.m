function S = harmonicL(height, width )
if nargin < 1
    width = 7;
    height = 6;
end

S = zeros(height, width);
S(1:height, width) = S(1:height, width) + (width+1) * (1:height)';

S(height, 1:width) = S(height, 1:width) + (height+1) * (1:width);
end

