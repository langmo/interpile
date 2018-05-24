function [indices, T] = toDistributionReal(S)

if nargin == 0
    S = harmonicO(3, 3);
end

T = sum(sum(S));
nI = sum(sum(S>0));
indices = NaN(nI, 3);

t=0;
idx = 1;
for y = 1 : size(S, 1)
    for x = 1 : size(S, 2)
        if S(y,x)<=0
            continue;
        end
        t = t+S(y,x)/T;
        indices(idx, :) = [y, x, t];
        idx = idx+1;
    end
end

end

