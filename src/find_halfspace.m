function X = find_halfspace(Y,T)
    % returns the number of the last sample
    % in the ASCENDING array data that is
    % <x using a simple half space search
    L = 1;
    R = length(Y);
    while L < R
        M = floor((L + R)/2);
        if T < Y(M)
            R = M;
        elseif T > Y(M)
            L = M + 1;
        else
            X = M;
            return;
        end
    end
    X = L;
end