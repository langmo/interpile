function indices = toDistribution(S)

indices = NaN(sum(sum(S)), 2);
idx = 1;
for y = 1 : size(S, 1)
    for x = 1 : size(S, 2)
        for k = 1:S(y,x)
            indices(idx, :) = [y, x];
            idx = idx+1;
        end
    end
end
end

