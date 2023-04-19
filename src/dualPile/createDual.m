function Cd = createDual(C)
Cd = inf(size(C)+[1,1]);
for x=2:size(Cd, 2)-1
    for y=2:size(Cd, 1)-1
        if any(~isinf([C(y,x),C(y,x-1),C(y-1,x),C(y-1,x-1)]))
        %if any(~isinf([C(y,x-1),C(y-1,x)]))
            Cd(y,x)=0;
        end
    end
end
end

