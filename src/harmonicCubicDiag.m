function S = harmonicCubicDiag(height, width )
if nargin < 1
    width = 4;
    height = 4;
end
S = harmonicCubic(height, width);
S = S+S';
end

