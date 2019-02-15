function harmonic = evenDiagHarmonic(dz, direction, varargin)

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
addOptional(p,'symbolicCalculations', false);
parse(p,varargin{:});
if p.Results.symbolicCalculations
    typeName = 'sym';
else
    typeName = p.Results.typeName;
end

if direction == 1
    dz = dz+1;
    if mod(dz, 2) == 0
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
    if mod(dz, 2) == 0
        if dz <= 0
            harmonic = @(Y,X) -harmonicOdd(+Y+dz/2, -X+dz/2+1, typeName);
        else
            harmonic = @(Y,X) +harmonicOdd(-Y-dz/2+1, X-dz/2, typeName);
        end
    else 
        if dz <= 0
            harmonic = @(Y,X) harmonicEven(+Y+(dz-1)/2, -X+(dz+1)/2, typeName);
        else
            harmonic = @(Y,X) harmonicEven(-Y-(dz-1)/2, X-(dz+1)/2, typeName);
        end
    end
else
    error('InterPile:InvalidDirection', 'Argument direction must be either 1 or 2.');
end
end

function H = harmonicEven(Y,X, typeName)
maxY = max(abs(Y(:)));
maxX = max(abs(X(:)));

H = arrayfun(@(y,x) harmonicEvenValue(y, x, maxY, maxX, typeName), Y, X);
end

function H = harmonicOdd(Y,X, typeName)
maxY = max(abs(Y(:)));
maxX = max(abs(X(:)));

H = arrayfun(@(y,x) harmonicOddValue(y, x, maxY, maxX, typeName), Y, X);
end

function h = harmonicEvenValue(y,x, maxY, maxX, typeName)
persistent HsaveEven;

maxY = max([maxY, (size(HsaveEven, 1)-1)/2, abs(y)]);
maxX = max([maxX, (size(HsaveEven, 2)-1)/2, abs(x)]);

if isempty(HsaveEven) || ~checkType(HsaveEven, typeName)
    % create new matrix to store already known values.
    HsaveEven = repmat(nanValue(typeName), 2*maxY+1, 2*maxX+1);
elseif size(HsaveEven, 1)<2*maxY+1 || size(HsaveEven, 2)<2*maxX+1
    % Extend matrix to store already known values.
    Hnew = repmat(nanValue(typeName), 2*maxY+1, 2*maxX+1);
    dy = maxY - (size(HsaveEven, 1)-1)/2;
    dx = maxX - (size(HsaveEven, 2)-1)/2;
    Hnew(1+dy:2*maxY+1-dy, 1+dx:2*maxX+1-dx) = HsaveEven;
    HsaveEven = Hnew;
end

% check if value already known
oldVal = HsaveEven(maxY+y+1, maxX+x+1);
if ~isNanValue(oldVal, typeName)
    h = loadValue(oldVal, typeName);
    return;
end

% calculate value.
if y < -x
    % default case 1
    h = cast2type(0, typeName);
elseif x==0 && y==0
    % default case 2
    h = cast2type(1, typeName);
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
                -harmonicEvenValue(y,x-2, maxY, maxX, typeName);
        else
            h = cast2type(0, typeName);
        end
    else
        e = (x-y)/2;
        if e < 0
            e = e + 0.5;
            if e == 0
                h = (4*harmonicEvenValue(y-1,x, maxY, maxX, typeName)...
                    -harmonicEvenValue(y-1,x-1, maxY, maxX, typeName)...
                    -harmonicEvenValue(y-2,x, maxY, maxX, typeName))/2;
            else
                h = 4*harmonicEvenValue(y-1,x, maxY, maxX, typeName)...
                    -harmonicEvenValue(y-1,x-1, maxY, maxX, typeName)...
                    -harmonicEvenValue(y-1,x+1, maxY, maxX, typeName)...
                    -harmonicEvenValue(y-2,x, maxY, maxX, typeName);
            end
        else
            e = e - 0.5;
            if e == 0
                h = (4*harmonicEvenValue(y,x-1, maxY, maxX, typeName)...
                    -harmonicEvenValue(y-1,x-1, maxY, maxX, typeName) ...
                    - harmonicEvenValue(y,x-2, maxY, maxX, typeName))/2;
            else
                h = 4*harmonicEvenValue(y,x-1, maxY, maxX, typeName)...
                    -harmonicEvenValue(y-1,x-1, maxY, maxX, typeName)...
                    -harmonicEvenValue(y+1,x-1, maxY, maxX, typeName)...
                    -harmonicEvenValue(y,x-2, maxY, maxX, typeName);
            end
        end
    end
end

% store value in matrix
HsaveEven(maxY+y+1, maxX+x+1) = saveValue(h, typeName);
end




function h = harmonicOddValue(y,x, maxY, maxX, typeName)
persistent HsaveOdd;

maxY = max([maxY, (size(HsaveOdd, 1)-1)/2, abs(y)]);
maxX = max([maxX, (size(HsaveOdd, 2)-1)/2, abs(x)]);

if isempty(HsaveOdd) || ~checkType(HsaveOdd, typeName)
    % create new matrix to store already known values.
    HsaveOdd = repmat(nanValue(typeName), 2*maxY+1, 2*maxX+1);
elseif size(HsaveOdd, 1)<2*maxY+1 || size(HsaveOdd, 2)<2*maxX+1
    % Extend matrix to store already known values.
    Hnew = repmat(nanValue(typeName), max(2*maxY+1, size(HsaveOdd, 1)), max(2*maxX+1, size(HsaveOdd, 2)));
    
    dy = maxY - (size(HsaveOdd, 1)-1)/2;
    dx = maxX - (size(HsaveOdd, 2)-1)/2;
    Hnew(1+dy:2*maxY+1-dy, 1+dx:2*maxX+1-dx) = HsaveOdd;
    HsaveOdd = Hnew;
end

% check if value already known
oldVal = HsaveOdd(maxY+y+1, maxX+x+1);
if ~isNanValue(oldVal, typeName)
    h = loadValue(oldVal, typeName);
    return;
end

% calculate value.
if y <= -x
    % default case 1
    h = cast2type(0, typeName);
elseif x==1 && y==0
    % default case 2
    h = cast2type(-1, typeName);
elseif x==0 && y==1
    % default case 3
    h = cast2type(1, typeName);
else
    % calculate recursively.
    d = y+x;
    if mod(d,2)==0
        e = (x-y)/2;
        if e < 0
            h = 4*harmonicOddValue(y-1,x, maxY, maxX, typeName)...
                -harmonicOddValue(y-1,x-1, maxY, maxX, typeName)...
                -harmonicOddValue(y-1,x+1, maxY, maxX, typeName)...
                -harmonicOddValue(y-2,x, maxY, maxX, typeName);
        elseif e > 0
            h = 4*harmonicOddValue(y,x-1, maxY, maxX, typeName)...
                -harmonicOddValue(y-1,x-1, maxY, maxX, typeName)...
                -harmonicOddValue(y+1,x-1, maxY, maxX, typeName)...
                -harmonicOddValue(y,x-2, maxY, maxX, typeName);
        else
            h = cast2type(0, typeName);
        end
    else
        e = (x-y)/2;
        if e < 0
            e = e + 0.5;
            if e == 0
                h = (4*harmonicOddValue(y-1,x, maxY, maxX, typeName)...
                    -harmonicOddValue(y-1,x-1, maxY, maxX, typeName)...
                    -harmonicOddValue(y-2,x, maxY, maxX, typeName))/2;
            else
                h = 4*harmonicOddValue(y-1,x, maxY, maxX, typeName)...
                    -harmonicOddValue(y-1,x-1, maxY, maxX, typeName)...
                    -harmonicOddValue(y-1,x+1, maxY, maxX, typeName)...
                    -harmonicOddValue(y-2,x, maxY, maxX, typeName);
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

% store value in matrix
HsaveOdd(maxY+y+1, maxX+x+1) = saveValue(h, typeName);

end

function value = nanValue(typeName)
if strcmpi(typeName, 'double') || strcmpi(typeName, 'single')
    value = NaN;
elseif strcmpi(typeName, 'sym')
    value = {[]};
else
    value = intmax(typeName);
end
end
function result = checkType(value, typeName)
    if strcmpi(typeName, 'sym')
        result = iscell(value);
    else
        result = strcmpi(class(value), typeName);
    end
end
function value = loadValue(value, typeName)
    if strcmpi(typeName, 'sym')
        value = value{1};        
    end
end
function value = saveValue(value, typeName)
    if strcmpi(typeName, 'sym')
        value = {value};        
    end
end
function result = isNanValue(value, typeName)
if strcmpi(typeName, 'double') || strcmpi(typeName, 'single')
    result = isnan(value);
elseif strcmpi(typeName, 'sym')
    result = isnan(value{1});
else
    result = value == intmax(typeName);
end
end
function result = cast2type(value, typeName)
    if strcmpi(typeName, 'sym')
        result = sym(value);
    else
        result = cast(value, typeName);
    end
end