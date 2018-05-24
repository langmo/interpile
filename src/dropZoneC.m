function S = harmonicC(height, width )
if nargin < 1
    width = 9;
    height = 6;
end

S = zeros(height, width);

S(1, 1:width) = S(1, 1:width) + (1:width);
S(end, 1:width) = S(end, 1:width) + (1:width);
S(1:end, width) = S(1:end, width) + (width+1);

end

