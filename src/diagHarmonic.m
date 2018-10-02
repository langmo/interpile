function harmonic = diagHarmonic(dz, direction)

if direction == 1
    if mod(dz, 2) == 0
        if dz < 0
            harmonic = @(Y,X) harmonicEven(-Y+dz/2, -X+dz/2);
        else
            harmonic = @(Y,X) harmonicEven(Y-dz/2, X-dz/2);
        end
    else 
        if dz < 0
            harmonic =@(Y,X) harmonicOdd(-Y+(dz+1)/2, -X+(dz+1)/2);
        else
            harmonic = @(Y,X) harmonicOdd(Y-(dz-1)/2, X-(dz-1)/2);
        end
    end
elseif direction == 2
    if mod(dz, 2) == 0
        if dz < 0
            harmonic = @(Y,X) harmonicEven(+Y+dz/2, -X+dz/2);
        else
            harmonic = @(Y,X) harmonicEven(-Y-dz/2, X-dz/2);
        end
    else 
        if dz < 0
            harmonic = @(Y,X) harmonicOdd(+Y+(dz+1)/2, -X+(dz+1)/2);
        else
            harmonic = @(Y,X) harmonicOdd(-Y-(dz-1)/2, X-(dz-1)/2);
        end
    end
else
    error('InterPile:InvalidDirection', 'Argument direction must be either 1 or 2.');
end
end

function H = harmonicEven(Y,X)
H = zeros(size(Y));
for i = 1:numel(Y)
    H(i) = harmonicEvenValue(Y(i),X(i));
end
end

function h = harmonicEvenValue(y,x)
% default cases
if y < -x
    h = 0;
    return;
elseif x==0 && y==0
    h = 1;
    return;
end

d = y+x;
if mod(d,2)==0
    e = (x-y)/2;
    if e < 0
        h = 4*harmonicEvenValue(y-1,x)-harmonicEvenValue(y-1,x-1)-harmonicEvenValue(y-1,x+1) - harmonicEvenValue(y-2,x);
    elseif e > 0
        h = 4*harmonicEvenValue(y,x-1)-harmonicEvenValue(y-1,x-1)-harmonicEvenValue(y+1,x-1) - harmonicEvenValue(y,x-2);
    else
        h = 4*harmonicEvenValue(y,x-1)-harmonicEvenValue(y-1,x-1) - harmonicEvenValue(y,x-2);
    end
else
    e = (x-y)/2;
    if e < 0
        e = e + 0.5;
        if e == 0
            h = (4*harmonicEvenValue(y-1,x)-harmonicEvenValue(y-1,x-1)- harmonicEvenValue(y-2,x))/2;
        else
            h = 4*harmonicEvenValue(y-1,x)-harmonicEvenValue(y-1,x-1)-harmonicEvenValue(y-1,x+1) - harmonicEvenValue(y-2,x);
        end
    else
        e = e - 0.5;
        if e == 0
            h = (4*harmonicEvenValue(y,x-1)-harmonicEvenValue(y-1,x-1) - harmonicEvenValue(y,x-2))/2;
        else
            h = 4*harmonicEvenValue(y,x-1)-harmonicEvenValue(y-1,x-1)-harmonicEvenValue(y+1,x-1) - harmonicEvenValue(y,x-2);
        end
    end
end

end


function H = harmonicOdd(Y,X)
H = zeros(size(Y));
for i = 1:numel(Y)
    H(i) = harmonicOddValue(Y(i),X(i));
end
end

function h = harmonicOddValue(y,x)
% default cases
if y <= -x
    h = 0;
    return;
elseif x==1 && y==0
    h = -1;
    return;
elseif x==0 && y==1
    h = 1;
    return;
end

d = y+x;
if mod(d,2)==0
    e = (x-y)/2;
    if e < 0
        h = 4*harmonicOddValue(y-1,x)-harmonicOddValue(y-1,x-1)-harmonicOddValue(y-1,x+1) - harmonicOddValue(y-2,x);
    elseif e > 0
        h = 4*harmonicOddValue(y,x-1)-harmonicOddValue(y-1,x-1)-harmonicOddValue(y+1,x-1) - harmonicOddValue(y,x-2);
    else
        h = 0;
    end
else
    e = (x-y)/2;
    if e < 0
        e = e + 0.5;
        if e == 0
            h = (4*harmonicOddValue(y-1,x)-harmonicOddValue(y-1,x-1)- harmonicOddValue(y-2,x))/2;
        else
            h = 4*harmonicOddValue(y-1,x)-harmonicOddValue(y-1,x-1)-harmonicOddValue(y-1,x+1) - harmonicOddValue(y-2,x);
        end
    else
        e = e - 0.5;
        if e == 0
            h = (4*harmonicOddValue(y,x-1)-harmonicOddValue(y-1,x-1) - harmonicOddValue(y,x-2))/2;
        else
            h = 4*harmonicOddValue(y,x-1)-harmonicOddValue(y-1,x-1)-harmonicOddValue(y+1,x-1) - harmonicOddValue(y,x-2);
        end
    end
end

end


