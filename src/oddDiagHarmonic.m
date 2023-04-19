function harmonic = oddDiagHarmonic(dz, direction, varargin)

% Copyright (C) 2019 Moritz Lang
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% For more information, visit the project's website at 
% https://langmo.github.io/interpile/

p = inputParser;
addOptional(p,'typeName', 'double');
parse(p,varargin{:});
typeName = p.Results.typeName;

if direction == 1
    if dz == 0
        harmonic = @(Y,X) harmonicNull(Y, X, typeName);
    elseif mod(dz, 2) == 0
        if dz <= 0
            harmonic = @(Y,X) harmonicEven(-Y+dz/2, -X+dz/2, typeName);
        else
            harmonic = @(Y,X) harmonicEven(Y-dz/2, X-dz/2, typeName);
        end
    else 
        if dz <= 0
            harmonic = @(Y,X) -harmonicOdd(-Y+(dz+1)/2, -X+(dz+1)/2, typeName);
        else
            harmonic = @(Y,X) harmonicOdd(Y-(dz-1)/2, X-(dz-1)/2, typeName);
        end
    end
elseif direction == 2
    if dz == 0
        harmonic = @(Y,X) harmonicNull(Y, X, typeName);
    elseif mod(dz, 2) == 1
        if dz <= 0
            harmonic = @(Y,X) -harmonicOdd(+Y+(dz+1)/2, -X+(dz-1)/2+1, typeName);
        else
            harmonic = @(Y,X) +harmonicOdd(-Y-(dz+1)/2+1, X-(dz-1)/2, typeName);
        end
    else 
        if dz <= 0
            harmonic = @(Y,X) harmonicEven(+Y+(dz)/2, -X+(dz)/2, typeName);
        else
            harmonic = @(Y,X) harmonicEven(-Y-(dz)/2, X-(dz)/2, typeName);
        end
    end
else
    error('InterPile:InvalidDirection', 'Argument direction must be either 1 or 2.');
end
end

function H = harmonicEven(Y,X, typeName)
maxY = max(abs(Y(:)));
maxX = max(abs(X(:)));
if strcmpi(typeName, 'vpi')
    H = vpi(zeros(size(Y)));
    for i=1:numel(Y)
        H(i) = harmonicEvenValue(Y(i), X(i), maxY, maxX, typeName);
    end
else
    H = arrayfun(@(y,x) harmonicEvenValue(y, x, maxY, maxX, typeName), Y, X);
end
end

function H = harmonicNull(Y,X, typeName)
maxY = max(abs(Y(:)));
maxX = max(abs(X(:)));
if strcmpi(typeName, 'vpi')
    H = vpi(zeros(size(Y)));
    for i=1:numel(Y)
        H(i) = harmonicNullValue(Y(i), X(i), maxY, maxX, typeName);
    end
else
    H = arrayfun(@(y,x) harmonicNullValue(y, x, maxY, maxX, typeName), Y, X);
end
end

function H = harmonicOdd(Y,X, typeName)
maxY = max(abs(Y(:)));
maxX = max(abs(X(:)));
if strcmpi(typeName, 'vpi')
    H = vpi(zeros(size(Y)));
    for i=1:numel(Y)
        H(i) = harmonicOddValue(Y(i), X(i), maxY, maxX, typeName);
    end
else
    H = arrayfun(@(y,x) harmonicOddValue(y, x, maxY, maxX, typeName), Y, X);
end
end

function h = harmonicEvenValue(y,x, maxY, maxX, typeName)
persistent HsaveEven HsaveEvenType;
maxY = max([maxY, (size(HsaveEven, 1)-1)/2, abs(y)]);
maxX = max([maxX, (size(HsaveEven, 2)-1)/2, abs(x)]);
if isempty(HsaveEven) || ~strcmpi(HsaveEvenType, typeName)
    % create new matrix to store already known values.
    HsaveEven = Types.container(2*maxY+1, 2*maxX+1, typeName);
    HsaveEvenType = typeName;
elseif size(HsaveEven, 1)<2*maxY+1 || size(HsaveEven, 2)<2*maxX+1
    % Extend matrix to store already known values.
    Hnew = Types.container(2*maxY+1, 2*maxX+1, typeName);
    dy = maxY - (size(HsaveEven, 1)-1)/2;
    dx = maxX - (size(HsaveEven, 2)-1)/2;
    Hnew(1+dy:2*maxY+1-dy, 1+dx:2*maxX+1-dx) = HsaveEven;
    HsaveEven = Hnew;
end

% check if value already known
h = Types.getElem(HsaveEven, maxY+y+1, maxX+x+1);
if ~Types.isEmptyElem(h, typeName)
    return;
end

% calculate value.
if y < -x
    % default case 1
    h = Types.cast2type(0, typeName);
elseif x==0 && y==0
    % default case 2
    h = Types.cast2type(1, typeName);
else
    % calculate recursively.
    d = y+x;
    if mod(d,2)==0
        e = (x-y)/2;
        if e < 0
            h = 4*harmonicEvenValue(y-1,x, maxY, maxX, typeName)...
                -harmonicEvenValue(y-1,x-1, maxY, maxX, typeName)...
                -harmonicEvenValue(y-1,x+1, maxY, maxX, typeName)...
                -harmonicEvenValue(y-2,x, maxY, maxX, typeName);
        elseif e > 0
            h = 4*harmonicEvenValue(y,x-1, maxY, maxX, typeName)...
                -harmonicEvenValue(y-1,x-1, maxY, maxX, typeName)...
                -harmonicEvenValue(y+1,x-1, maxY, maxX, typeName)...
                - harmonicEvenValue(y,x-2, maxY, maxX, typeName);
        else
            h = Types.cast2type(0, typeName);
        end
    else
        e = (x-y)/2;
        if e < 0
            e = e + 0.5;
            if e == 0
                h = (4*harmonicEvenValue(y-1,x, maxY, maxX, typeName)...
                    -harmonicEvenValue(y-1,x-1, maxY, maxX, typeName)...
                    - harmonicEvenValue(y-2,x, maxY, maxX, typeName))/2;
            else
                h = 4*harmonicEvenValue(y-1,x, maxY, maxX, typeName)...
                    -harmonicEvenValue(y-1,x-1, maxY, maxX, typeName)...
                    -harmonicEvenValue(y-1,x+1, maxY, maxX, typeName)...
                    - harmonicEvenValue(y-2,x, maxY, maxX, typeName);
            end
        else
            e = e - 0.5;
            if e == 0
                h = (4*harmonicEvenValue(y,x-1, maxY, maxX, typeName)...
                    -harmonicEvenValue(y-1,x-1, maxY, maxX, typeName)...
                    - harmonicEvenValue(y,x-2, maxY, maxX, typeName))/2;
            else
                h = 4*harmonicEvenValue(y,x-1, maxY, maxX, typeName)...
                    -harmonicEvenValue(y-1,x-1, maxY, maxX, typeName)...
                    -harmonicEvenValue(y+1,x-1, maxY, maxX, typeName)...
                    - harmonicEvenValue(y,x-2, maxY, maxX, typeName);
            end
        end
    end
end

% Calculate these values again, since HsaveEven might have changed in inner
% loop
maxY = max([maxY, (size(HsaveEven, 1)-1)/2, abs(y)]);
maxX = max([maxX, (size(HsaveEven, 2)-1)/2, abs(x)]);

% store value in matrix
HsaveEven(maxY+y+1, maxX+x+1) =  Types.toElem(h, typeName);
end


function h = harmonicNullValue(y,x, maxY, maxX, typeName)
persistent HsaveNull HsaveNullType;
maxY = max([maxY, (size(HsaveNull, 1)-1)/2, abs(y)]);
maxX = max([maxX, (size(HsaveNull, 2)-1)/2, abs(x)]);
x = abs(x); % completely symmetric
y = abs(y);
if isempty(HsaveNull) || ~strcmpi(HsaveNullType, typeName)
    % create new matrix to store already known values.
    HsaveNull = Types.container(2*maxY+1, 2*maxX+1, typeName);
    HsaveNullType = typeName;
elseif size(HsaveNull, 1)<2*maxY+1 || size(HsaveNull, 2)<2*maxX+1
    % Extend matrix to store already known values.
    Hnew = Types.container(2*maxY+1, 2*maxX+1, typeName);
    dy = maxY - (size(HsaveNull, 1)-1)/2;
    dx = maxX - (size(HsaveNull, 2)-1)/2;
    Hnew(1+dy:2*maxY+1-dy, 1+dx:2*maxX+1-dx) = HsaveNull;
    HsaveNull = Hnew;
end

% check if value already known
h = Types.getElem(HsaveNull, maxY+y+1, maxX+x+1);
if ~Types.isEmptyElem(h, typeName)
    return;
end

% calculate value.
if x==0 && y==0
    % default case 1
    h = Types.cast2type(1, typeName);
elseif y == x
    % default case 2
    h = Types.cast2type(0, typeName);
elseif y == x-1
    % default case 3
    h = Types.cast2type((-1).^y, typeName);
elseif y == x+1
    % default case 4
    h = Types.cast2type((-1).^x, typeName);
else
    % calculate recursively.
    d = y+x;
    if mod(d,2)==0
        e = (x-y)/2;
        if e < 0
            h = 4*harmonicNullValue(y-1,x, maxY, maxX, typeName)...
                    -harmonicNullValue(y-1,x-1, maxY, maxX, typeName)...
                    -harmonicNullValue(y-1,x+1, maxY, maxX, typeName)...
                    - harmonicNullValue(y-2,x, maxY, maxX, typeName);
        elseif e > 0
            h = 4*harmonicNullValue(y,x-1, maxY, maxX, typeName)...
                    -harmonicNullValue(y-1,x-1, maxY, maxX, typeName)...
                    -harmonicNullValue(y+1,x-1, maxY, maxX, typeName)...
                    - harmonicNullValue(y,x-2, maxY, maxX, typeName);
        else
            h = Types.cast2type(0, typeName);
        end
    else
        e = (x-y)/2;
        if e < 0
            e = e + 0.5;
            if e == 0
                h = (4*harmonicNullValue(y-1,x, maxY, maxX, typeName)...
                    -harmonicNullValue(y-1,x-1, maxY, maxX, typeName)...
                    - harmonicNullValue(y-2,x, maxY, maxX, typeName))/2;
            else
                h = 4*harmonicNullValue(y-1,x, maxY, maxX, typeName)...
                    -harmonicNullValue(y-1,x-1, maxY, maxX, typeName)...
                    -harmonicNullValue(y-1,x+1, maxY, maxX, typeName)...
                    - harmonicNullValue(y-2,x, maxY, maxX, typeName);
            end
        else
            e = e - 0.5;
            if e == 0
                h = (4*harmonicNullValue(y,x-1, maxY, maxX, typeName)...
                    -harmonicNullValue(y-1,x-1, maxY, maxX, typeName)...
                    - harmonicNullValue(y,x-2, maxY, maxX, typeName))/2;
            else
                h = 4*harmonicNullValue(y,x-1, maxY, maxX, typeName)...
                    -harmonicNullValue(y-1,x-1, maxY, maxX, typeName)...
                    -harmonicNullValue(y+1,x-1, maxY, maxX, typeName)...
                    - harmonicNullValue(y,x-2, maxY, maxX, typeName);
            end
        end
    end
end

% Calculate these values again, since HsaveEven might have changed in inner
% loop
maxY = max([maxY, (size(HsaveNull, 1)-1)/2, abs(y)]);
maxX = max([maxX, (size(HsaveNull, 2)-1)/2, abs(x)]);

% store value in matrix
HsaveNull(maxY+y+1, maxX+x+1) =  Types.toElem(h, typeName);
end

function h = harmonicOddValue(y,x, maxY, maxX, typeName)
persistent HsaveOdd HsaveOddType;
maxY = max([maxY, (size(HsaveOdd, 1)-1)/2, abs(y)]);
maxX = max([maxX, (size(HsaveOdd, 2)-1)/2, abs(x)]);
if isempty(HsaveOdd) || ~strcmpi(HsaveOddType, typeName)
    % create new matrix to store already known values.
    HsaveOdd = Types.container(2*maxY+1, 2*maxX+1, typeName);
    HsaveOddType = typeName;
elseif size(HsaveOdd, 1)<2*maxY+1 || size(HsaveOdd, 2)<2*maxX+1
    % Extend matrix to store already known values.
    Hnew = Types.container(2*maxY+1, 2*maxX+1, typeName);
    dy = maxY - (size(HsaveOdd, 1)-1)/2;
    dx = maxX - (size(HsaveOdd, 2)-1)/2;
    Hnew(1+dy:2*maxY+1-dy, 1+dx:2*maxX+1-dx) = HsaveOdd;
    HsaveOdd = Hnew;
end

% check if value already known
h = Types.getElem(HsaveOdd, maxY+y+1, maxX+x+1);
if ~Types.isEmptyElem(h, typeName)
    return;
end

% calculate value.
if y <= -x
    % default case 1
    h = Types.cast2type(0, typeName);
elseif x==1 && y==0
    % default case 2
    h = Types.cast2type(-1, typeName);
elseif x==0 && y==1
    % default case 3
    h = Types.cast2type(1, typeName);
else
    % calculate recursively.
    d = y+x;
    if mod(d,2)==0
        e = (x-y)/2;
        if e < 0
            h = 4*harmonicOddValue(y-1,x, maxY, maxX, typeName)...
                    -harmonicOddValue(y-1,x-1, maxY, maxX, typeName)...
                    -harmonicOddValue(y-1,x+1, maxY, maxX, typeName)...
                    - harmonicOddValue(y-2,x, maxY, maxX, typeName);
        elseif e > 0
            h = 4*harmonicOddValue(y,x-1, maxY, maxX, typeName)...
                    -harmonicOddValue(y-1,x-1, maxY, maxX, typeName)...
                    -harmonicOddValue(y+1,x-1, maxY, maxX, typeName)...
                    - harmonicOddValue(y,x-2, maxY, maxX, typeName);
        else
            h = Types.cast2type(0, typeName);
        end
    else
        e = (x-y)/2;
        if e < 0
            e = e + 0.5;
            if e == 0
                h = (4*harmonicOddValue(y-1,x, maxY, maxX, typeName)...
                    -harmonicOddValue(y-1,x-1, maxY, maxX, typeName)...
                    - harmonicOddValue(y-2,x, maxY, maxX, typeName))/2;
            else
                h = 4*harmonicOddValue(y-1,x, maxY, maxX, typeName)...
                    -harmonicOddValue(y-1,x-1, maxY, maxX, typeName)...
                    -harmonicOddValue(y-1,x+1, maxY, maxX, typeName)...
                    - harmonicOddValue(y-2,x, maxY, maxX, typeName);
            end
        else
            e = e - 0.5;
            if e == 0
                h = (4*harmonicOddValue(y,x-1, maxY, maxX, typeName)...
                    -harmonicOddValue(y-1,x-1, maxY, maxX, typeName)...
                    - harmonicOddValue(y,x-2, maxY, maxX, typeName))/2;
            else
                h = 4*harmonicOddValue(y,x-1, maxY, maxX, typeName)...
                    -harmonicOddValue(y-1,x-1, maxY, maxX, typeName)...
                    -harmonicOddValue(y+1,x-1, maxY, maxX, typeName)...
                    - harmonicOddValue(y,x-2, maxY, maxX, typeName);
            end
        end
    end
end

% Calculate these values again, since HsaveEven might have changed in inner
% loop
maxY = max([maxY, (size(HsaveOdd, 1)-1)/2, abs(y)]);
maxX = max([maxX, (size(HsaveOdd, 2)-1)/2, abs(x)]);

% store value in matrix
HsaveOdd(maxY+y+1, maxX+x+1) = Types.toElem(h, typeName);

end