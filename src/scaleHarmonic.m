function H = scaleHarmonic(H0, scaling, varargin)

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

if ~isempty(which('sym'))
    typeName = 'sym';
elseif ~isempty(which('vpi'))
    typeName = 'vpi';
else
    typeName = 'double';
end

returnTypeName = Types.gettype(H0);

p = inputParser;
addOptional(p,'typeName', typeName);
addOptional(p,'returnTypeName', returnTypeName);
addOptional(p,'verify', false);
parse(p,varargin{:});

typeName = p.Results.typeName;
verify = p.Results.verify;
if isempty(p.Results.returnTypeName)
    returnTypeName = typeName;
else
    returnTypeName = p.Results.returnTypeName;
end

H0 = Types.cast2type(H0, typeName);

if ~exist('scaling', 'var') || isempty(scaling)
    scalingX = 3;
    scalingY = 3;
elseif length(scaling)==1
    scalingX = scaling;
    scalingY = scaling;
else
    scalingX = scaling(2);
    scalingY = scaling(1);
end

N0 = size(H0, 1);
M0 = size(H0, 2);

N = (N0-1)*scalingY+1;
M = (M0-1)*scalingX+1;

H = Types.zeros(N, M, typeName);

orientationsX = (-1).^((1:scalingX)+ceil((scalingX+1)/2));
orientationsY = (-1).^((1:scalingY)+ceil((scalingY+1)/2));

for y=1:length(orientationsY)
    for x=1:length(orientationsX)
        Hi = H0(2:end-1, 2:end-1);
        if orientationsY(y) < 0
            Hi = -flipud(Hi);
        end
        if orientationsX(x) < 0
            Hi = -fliplr(Hi);
        end
        
        H(2+(y-1)*(N0-1):y*(N0-1), 2+(x-1)*(M0-1):x*(M0-1)) = Hi;
    end
end

%% correct internal boundaries at top
for topBoundaryY = 1:floor((scalingY-1)/2)+1
    Hcorr = Types.zeros(N, M, typeName);
    yIdx = 1+(topBoundaryY-1)*(N0-1);
    
    if orientationsY(topBoundaryY) > 0
        Hj = H0(1, 2:end-1);
    else
        Hj = -H0(end, 2:end-1);
    end
    
    for x=1:length(orientationsX)
        if orientationsX(x) > 0
            Hi = Hj;
        else
            Hi = -fliplr(Hj);
        end
        Hcorr(yIdx, 2+(x-1)*(M0-1):x*(M0-1)) = Hi;
    end
    
    if topBoundaryY == 1
        H = H+ Hcorr;
    else
        Hcorr = extendTop(Hcorr, yIdx);
        H = H+ Hcorr;
        H(1:end-2, :) = H(1:end-2, :) - Hcorr(3:end, :);
    end
end

%% correct internal boundaries at bottom
for bottomBoundaryY = scalingY:-1:floor((scalingY-1)/2)+1
    Hcorr = Types.zeros(N, M, typeName);
    yIdx = 1+(bottomBoundaryY)*(N0-1);
    
    if orientationsY(bottomBoundaryY) > 0
        Hj = H0(end, 2:end-1);
    else
        Hj = -H0(1, 2:end-1);
    end
    
    for x=1:length(orientationsX)
        if orientationsX(x) > 0
            Hi = Hj;
        else
            Hi = -fliplr(Hj);
        end
        Hcorr(yIdx, 2+(x-1)*(M0-1):x*(M0-1)) = Hi;
    end
    
    if bottomBoundaryY == scalingY
        H = H+ Hcorr;
    else
        Hcorr = extendBottom(Hcorr, yIdx);
        H = H+ Hcorr;
        H(3:end, :) = H(3:end, :) - Hcorr(1:end-2, :);
    end
end

%% correct internal boundaries at left
for leftBoundaryX = 1:floor((scalingX-1)/2)+1
    Hcorr = Types.zeros(N, M, typeName);
    xIdx = 1+(leftBoundaryX-1)*(M0-1);
    
    if orientationsX(leftBoundaryX) > 0
        Hj = H0(2:end-1, 1);
    else
        Hj = -H0(2:end-1, end);
    end
    
    for y=1:length(orientationsY)
        if orientationsY(y) > 0
            Hi = Hj;
        else
            Hi = -flipud(Hj);
        end
        Hcorr(2+(y-1)*(N0-1):y*(N0-1), xIdx) = Hi;
    end
    
    if leftBoundaryX == 1
        H = H+ Hcorr;
    else
        Hcorr = extendLeft(Hcorr, xIdx);
        H = H+ Hcorr;
        H(:, 1:end-2) = H(:, 1:end-2) - Hcorr(:, 3:end);
    end
end

%% correct internal boundaries at right
for rightBoundaryX = scalingX:-1:floor((scalingX-1)/2)+1
    Hcorr = Types.zeros(N, M, typeName);
    xIdx = 1+(rightBoundaryX)*(M0-1);
    
    if orientationsX(rightBoundaryX) > 0
        Hj = H0(2:end-1, end);
    else
        Hj = -H0(2:end-1, 1);
    end
    
    for y=1:length(orientationsY)
        if orientationsY(y) > 0
            Hi = Hj;
        else
            Hi = -flipud(Hj);
        end
        Hcorr(2+(y-1)*(N0-1):y*(N0-1), xIdx) = Hi;
    end
    
    if rightBoundaryX == scalingX
        H = H+ Hcorr;
    else
        Hcorr = extendRight(Hcorr, xIdx);
        H = H+ Hcorr;
        H(:, 3:end) = H(:, 3:end) - Hcorr(:, 1:end-2);
    end
end

%%
if verify
    test = 4*H;
    test(2:end, :) = test(2:end, :) - H(1:end-1, :);
    test(1:end-1, :) = test(1:end-1, :) - H(2:end, :);

    test(:, 2:end) = test(:, 2:end) - H(:, 1:end-1);
    test(:, 1:end-1) = test(:, 1:end-1) - H(:, 2:end);
    assert(all(all(abs(test(2:end-1, 2:end-1))<100*eps)), 'InterPile:ScalingFailed', 'Scaled harmonic is not harmonic.');
end

H = Types.cast2type(H, returnTypeName);
end
function Hcorr = extendTop(Hcorr, yIdx)
    for y = yIdx-1:-1:1
        for x = 2:size(Hcorr, 2)-1
            Hcorr(y,x) = 4*Hcorr(y+1,x)-Hcorr(y+2,x)-Hcorr(y+1,x-1)-Hcorr(y+1,x+1);
        end
    end
end
function Hcorr = extendBottom(Hcorr, yIdx)
    for y = yIdx+1:+1:size(Hcorr, 1)
        for x = 2:size(Hcorr, 2)-1
            Hcorr(y,x) = 4*Hcorr(y-1,x)-Hcorr(y-2,x)-Hcorr(y-1,x-1)-Hcorr(y-1,x+1);
        end
    end
end

function Hcorr = extendLeft(Hcorr, xIdx)
    for x = xIdx-1:-1:1
        for y = 2:size(Hcorr, 1)-1
            Hcorr(y,x) = 4*Hcorr(y,x+1)-Hcorr(y,x+2)-Hcorr(y-1,x+1)-Hcorr(y+1,x+1);
        end
    end
end

function Hcorr = extendRight(Hcorr, xIdx)
    for x = xIdx+1:+1:size(Hcorr, 2)
        for y = 2:size(Hcorr, 1)-1
            Hcorr(y,x) = 4*Hcorr(y,x-1)-Hcorr(y,x-2)-Hcorr(y-1,x-1)-Hcorr(y+1,x-1);
        end
    end
end

