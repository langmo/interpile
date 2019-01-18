function harmonic = diagHarmonic(dz, direction)

if direction == 1
    if mod(dz, 2) == 0
        if dz <= 0
            harmonic = @(Y,X) harmonicEven(-Y+dz/2, -X+dz/2);
        else
            harmonic = @(Y,X) harmonicEven(Y-dz/2, X-dz/2);
        end
    else 
        if dz <= 0
            harmonic = @(Y,X) harmonicOdd(-Y+(dz+1)/2, -X+(dz+1)/2);
        else
            harmonic = @(Y,X) harmonicOdd(Y-(dz-1)/2, X-(dz-1)/2);
        end
    end
elseif direction == 2
    if mod(dz, 2) == 0
        if dz <= 0
            harmonic = @(Y,X) -harmonicOdd(+Y+dz/2, -X+dz/2+1);
        else
            harmonic = @(Y,X) -harmonicOdd(-Y-dz/2+1, X-dz/2);
        end
    else 
        if dz <= 0
            harmonic = @(Y,X) harmonicEven(+Y+(dz-1)/2, -X+(dz+1)/2);
        else
            harmonic = @(Y,X) harmonicEven(-Y-(dz-1)/2, X-(dz+1)/2);
        end
    end
else
    error('InterPile:InvalidDirection', 'Argument direction must be either 1 or 2.');
end
end

function H = harmonicEven(Y,X)
maxY = max(abs(Y(:)));
maxX = max(abs(X(:)));

H = arrayfun(@(y,x) harmonicEvenValue(y, x, maxY, maxX), Y, X);
end

function H = harmonicOdd(Y,X)
maxY = max(abs(Y(:)));
maxX = max(abs(X(:)));

H = arrayfun(@(y,x) harmonicOddValue(y, x, maxY, maxX), Y, X);
end

function h = harmonicEvenValue(y,x, maxY, maxX)
persistent HsaveEven;

if isempty(HsaveEven)
    % create new matrix to store already known values.
    HsaveEven = NaN(2*maxY+1, 2*maxX+1);
elseif size(HsaveEven, 1)<2*maxY+1 || size(HsaveEven, 2)<2*maxX+1
    % Extend matrix to store already known values.
    Hnew = NaN(2*maxY+1, 2*maxX+1);
    dy = maxY - (size(HsaveEven, 1)-1)/2;
    dx = maxX - (size(HsaveEven, 2)-1)/2;
    Hnew(1+dy:2*maxY+1-dy, 1+dx:2*maxX+1-dx) = HsaveEven;
    HsaveEven = Hnew;
else
    % Correct max values in case matrix of already known values is bigger
    % than the max values needed during current call.
    maxY = (size(HsaveEven, 1)-1)/2;
    maxX = (size(HsaveEven, 2)-1)/2;
end

% check if value already known
if ~isnan(HsaveEven(maxY+y+1, maxX+x+1))
    h = HsaveEven(maxY+y+1, maxX+x+1);
    return;
end

% calculate value.
if y < -x
    % default case 1
    h = 0;
elseif x==0 && y==0
    % default case 2
    h = 1;
else
    % calculate recursively.
    d = y+x;
    if mod(d,2)==0
        e = (x-y)/2;
        if e < 0
            h = 4*harmonicEvenValue(y-1,x, maxY, maxX)-harmonicEvenValue(y-1,x-1, maxY, maxX)-harmonicEvenValue(y-1,x+1, maxY, maxX) - harmonicEvenValue(y-2,x, maxY, maxX);
        elseif e > 0
            h = 4*harmonicEvenValue(y,x-1, maxY, maxX)-harmonicEvenValue(y-1,x-1, maxY, maxX)-harmonicEvenValue(y+1,x-1, maxY, maxX) - harmonicEvenValue(y,x-2, maxY, maxX);
        else
            h = harmonicEvenValue(y,x-1, maxY, maxX)/2;%4*harmonicEvenValue(y,x-1)-harmonicEvenValue(y-1,x-1) - harmonicEvenValue(y,x-2);
        end
    else
        e = (x-y)/2;
        if e < 0
            e = e + 0.5;
            if e == 0
                h = (4*harmonicEvenValue(y-1,x, maxY, maxX)-harmonicEvenValue(y-1,x-1, maxY, maxX)- harmonicEvenValue(y-2,x, maxY, maxX))/2;
            else
                h = 4*harmonicEvenValue(y-1,x, maxY, maxX)-harmonicEvenValue(y-1,x-1, maxY, maxX)-harmonicEvenValue(y-1,x+1, maxY, maxX) - harmonicEvenValue(y-2,x, maxY, maxX);
            end
        else
            e = e - 0.5;
            if e == 0
                h = (4*harmonicEvenValue(y,x-1, maxY, maxX)-harmonicEvenValue(y-1,x-1, maxY, maxX) - harmonicEvenValue(y,x-2, maxY, maxX))/2;
            else
                h = 4*harmonicEvenValue(y,x-1, maxY, maxX)-harmonicEvenValue(y-1,x-1, maxY, maxX)-harmonicEvenValue(y+1,x-1, maxY, maxX) - harmonicEvenValue(y,x-2, maxY, maxX);
            end
        end
    end
end

% store value in matrix
HsaveEven(maxY+y+1, maxX+x+1) = h;
end




function h = harmonicOddValue(y,x, maxY, maxX)
persistent HsaveOdd;

if isempty(HsaveOdd)
    % create new matrix to store already known values.
    HsaveOdd = NaN(2*maxY+1, 2*maxX+1);
elseif size(HsaveOdd, 1)<2*maxY+1 || size(HsaveOdd, 2)<2*maxX+1
    % Extend matrix to store already known values.
    Hnew = NaN(2*maxY+1, 2*maxX+1);
    dy = maxY - (size(HsaveOdd, 1)-1)/2;
    dx = maxX - (size(HsaveOdd, 2)-1)/2;
    Hnew(1+dy:2*maxY+1-dy, 1+dx:2*maxX+1-dx) = HsaveOdd;
    HsaveOdd = Hnew;
else
    % Correct max values in case matrix of already known values is bigger
    % than the max values needed during current call.
    maxY = (size(HsaveOdd, 1)-1)/2;
    maxX = (size(HsaveOdd, 2)-1)/2;
end

% check if value already known
if ~isnan(HsaveOdd(maxY+y+1, maxX+x+1))
    h = HsaveOdd(maxY+y+1, maxX+x+1);
    return;
end

% calculate value.
if y <= -x
    % default case 1
    h = 0;
elseif x==1 && y==0
    % default case 2
    h = -1;
elseif x==0 && y==1
    % default case 3
    h = 1;
else
    % calculate recursively.
    d = y+x;
    if mod(d,2)==0
        e = (x-y)/2;
        if e < 0
            h = 4*harmonicOddValue(y-1,x, maxY, maxX)-harmonicOddValue(y-1,x-1, maxY, maxX)-harmonicOddValue(y-1,x+1, maxY, maxX) - harmonicOddValue(y-2,x, maxY, maxX);
        elseif e > 0
            h = 4*harmonicOddValue(y,x-1, maxY, maxX)-harmonicOddValue(y-1,x-1, maxY, maxX)-harmonicOddValue(y+1,x-1, maxY, maxX) - harmonicOddValue(y,x-2, maxY, maxX);
        else
            h = 0;
        end
    else
        e = (x-y)/2;
        if e < 0
            e = e + 0.5;
            if e == 0
                h = (4*harmonicOddValue(y-1,x, maxY, maxX)-harmonicOddValue(y-1,x-1, maxY, maxX)- harmonicOddValue(y-2,x, maxY, maxX))/2;
            else
                h = 4*harmonicOddValue(y-1,x, maxY, maxX)-harmonicOddValue(y-1,x-1, maxY, maxX)-harmonicOddValue(y-1,x+1, maxY, maxX) - harmonicOddValue(y-2,x, maxY, maxX);
            end
        else
            e = e - 0.5;
            if e == 0
                h = (4*harmonicOddValue(y,x-1, maxY, maxX)-harmonicOddValue(y-1,x-1, maxY, maxX) - harmonicOddValue(y,x-2, maxY, maxX))/2;
            else
                h = 4*harmonicOddValue(y,x-1, maxY, maxX)-harmonicOddValue(y-1,x-1, maxY, maxX)-harmonicOddValue(y+1,x-1, maxY, maxX) - harmonicOddValue(y,x-2, maxY, maxX);
            end
        end
    end
end

% store value in matrix
HsaveOdd(maxY+y+1, maxX+x+1) = h;

end


