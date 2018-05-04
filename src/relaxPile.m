function S = relaxPile(S)
if nargin <1
    S = ones(5,5)*3;
    S(3,3) = 4;
    S(2,2) = 4;
end
addFilter = zeros(3,3);
addFilter(1, 2)= 1;
addFilter(2, 1)= 1;
addFilter(2, 3)= 1;
addFilter(3, 2)= 1;
if nargout == 0
    fgh = plotSandPile(S);
end
overflow = floor(max(S, 0)/4);
while any(any(overflow))
    add = imfilter(overflow, addFilter);
    S = S -overflow*4+add;
    overflow = floor(max(S, 0)/4);
    if nargout == 0
        fgh = plotSandPile(S, fgh);
    end
end
end