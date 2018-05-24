function S = harmonicO(height, width )
if nargin < 1
    width = 7;
    height = 6;
end
if nargin < 2
    width=height;
end
S = zeros(height, width);
S(1:height, 1)      = S(1:height, 1) + 1;
S(1:height, width)  = S(1:height, width) + 1;
S(1, 1:width)       = S(1, 1:width) + 1;
S(height, 1:width)  = S(height, 1:width) + 1;

end

