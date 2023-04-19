function varargout = numRecurrentStates(varargin)
% Calculates the number of recurrent states.
% Usage:
%   factors = numRecurrentStates(N)
%       Calculates the number of recurrent states for an NxN square domain.
%       Instead of the number of recurrent states, the factorization is
%       returned. This is usually more precise for large numbers of
%       recurrent states due to rounding errors due to finite precision of
%       double values. The number of recurrent states can be obtained by
%       prod(factors).
%   factors = numRecurrentStates(N, M)
%       Calculates the number of recurrent states for an NxM rectangular domain.
%   factors = numRecurrentStates(mask)
%       Calculates the number of recurrent states for a domain
%       corresponding to the non-zero values of the mask.
%   factors = numRecurrentStates(..., 'method', method)
%       Defines the method how the number of recurrent states is
%       determined. 
%       Options:
%        'potential' (default). The number of states is determined by the absolute
%           value of the determinant of the matrix P, where each column of
%           P corresponds to the potential of one (non-zero) harmonic
%           diagonal function, restricted to the boundary of the domain.
%        'potentialPolynoms'. Same as 'potential', only with harmonics of
%           polynomial type.
%        'laplacian'. The number of states is determined by
%           the absolute value of the determinant of the graph laplacian.
%       

% Copyright (C) 2018, 2019 Moritz Lang
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

inputIdx = 1;
if numel(varargin{inputIdx}) > 1
    mask = varargin{inputIdx};
    N = size(mask, 1);
    M = size(mask, 2);
    inputIdx = inputIdx+1;
else
    N = varargin{inputIdx};
    inputIdx = inputIdx+1;
    if numel(varargin) >= inputIdx && isnumeric(varargin{inputIdx}) && numel(varargin{inputIdx}) == 1
        M = varargin{inputIdx};
        inputIdx = inputIdx+1;
    else
        M = N;
    end
    mask = ones(N, M);
end

if ~isempty(which('sym'))
    typeName = 'sym';
elseif ~isempty(which('vpi'))
    typeName = 'vpi';
else
    typeName = 'double';
end
p = inputParser;
addOptional(p,'method', 'potential');
addOptional(p,'typeName', typeName);
if nargout < 1
    returnTypeName = typeName;
else
    returnTypeName = 'double';
end
addOptional(p,'returnTypeName', returnTypeName);
parse(p,varargin{inputIdx:end});
typeName = p.Results.typeName;
returnTypeName = p.Results.returnTypeName;
method = p.Results.method;

if nargout > 1
    error('InterPile:TooManyReturnValues', 'The function either returns zero or one value.');
end
if strcmpi(method, 'potential')
    % Calculate via potentials.
    startTime = tic();
    maskExtended = false(size(mask, 1)+2, size(mask, 2)+2);
    maskExtended(2:end-1, 2:end-1) = mask;
    
    X=ceil(repmat((0:M+1) - (M+1)/2, N+2, 1));
    Y=ceil(repmat(((0:N+1) - (N+1)/2)', 1, M+2));
    
    outerBoundary = filter2([0,1,0;1,0,1;0,1,0], maskExtended)>0;
    outerBoundary(maskExtended) = false;
    innerBoundary = filter2([0,1,0;1,0,1;0,1,0], ~maskExtended)>0;
    innerBoundary(~maskExtended) = false;
    
    outerX = X(outerBoundary);
    outerY = Y(outerBoundary);
    
    innerX = X(innerBoundary);
    innerY = Y(innerBoundary);
    
    outer2inner = Types.cast2type(abs(repmat(innerX,1, length(outerX)) - repmat(outerX',length(innerX), 1))...
        +abs(repmat(innerY,1, length(outerY)) - repmat(outerY',length(innerY), 1)) == 1, typeName);
    
    
    P = Types.zeros(sum(innerBoundary(:)), typeName); % potential matrix
    nextIdx = 1;
    h = 1;
    while nextIdx <= size(P, 1)
        for sign = [-1, 1]
            for direction = 1:2
                harmonic = evenDiagHarmonic(sign*h, direction, 'typeName', typeName);
                Pi = outer2inner * harmonic(outerY,outerX);
                if any(Pi ~= 0)
                    P(nextIdx, :) = Pi;
                    nextIdx = nextIdx+1;
                    if nextIdx > size(P, 1)
                        break;
                    end
                end
            end
            if nextIdx > size(P, 1)
                break;
            end
        end
        h = h+1;
    end
    % Calculate determinant. Symbolic toolbox seems to be more precise...
    numStates = abs(det(P));
    factors = Types.cast2type(factor(numStates), returnTypeName);
    numStates = Types.cast2type(numStates, returnTypeName);
    calculationTime = toc(startTime);
elseif strcmpi(method, 'potentialPolynoms')
    % Calculate via potential polynoms.
    startTime = tic();
    maskExtended = zeros(size(mask, 1)+2, size(mask, 2)+2);
    maskExtended(2:end-1, 2:end-1) = mask;
    boundary = filter2([0,1,0;1,0,1;0,1,0], ~maskExtended);
    boundary = boundary(2:end-1, 2:end-1);
    boundary = boundary ~=0 & mask;
    boundaryIdx = find(boundary);
    P = NaN(length(boundaryIdx));
    H0 = @(y,x) ones(size(y));
    P0 = generateDropZone(H0, size(mask, 1), size(mask, 2), mask, false, false);
    P(1, : ) = P0(boundaryIdx);
    nextIdx = 2;
    h = 1;
    while nextIdx <= size(P, 1)
        HR = realHarmonicMonomial(h);
        PR = generateDropZone(HR, size(mask, 1), size(mask, 2), mask, false, false);
        PBound =  PR(boundaryIdx);
        if any(PBound)
            P(nextIdx, :) = PBound;
            if rank(P(1:nextIdx, :)) == nextIdx
                nextIdx = nextIdx+1;
                if nextIdx > size(P, 1)
                    break;
                end
            end
        end

        HI = imagHarmonicMonomial(h);
        PI = generateDropZone(HI, size(mask, 1), size(mask, 2), mask, false, false);
        PBound =  PI(boundaryIdx);
        if any(PBound)
            P(nextIdx, :) = PBound;
            if rank(P(1:nextIdx, :)) == nextIdx
                nextIdx = nextIdx+1;
                if nextIdx > size(P, 1)
                    break;
                end
            end
        end
        h = h+1;
    end
    % Calculate determinant. Symbolic toolbox seems to be more precise...
    numStates = abs(det(Types.cast2type(P, typeName)));
    factors = Types.cast2type(factor(numStates), returnTypeName); 
    numStates = Types.cast2type(numStates, returnTypeName);
    calculationTime = toc(startTime);
elseif strcmpi(method, 'laplacian')
    % Calculate via graph laplacian.
    startTime = tic();
    maskIDs = find(mask);
    Delta = zeros(length(maskIDs));
    for i=1:length(maskIDs)
        M = zeros(size(mask, 1), size(mask, 2));
        M(maskIDs(i))=1;
        A = filter2([0,1,0;1,-4,1;0,1,0], M);
        Delta(i, :) = A(maskIDs);
    end
    % Calculate determinant. Symbolic toolbox seems to be more precise...
    numStates = abs(det(Types.cast2type(Delta, typeName)));
    factors = Types.cast2type(factor(numStates), returnTypeName);
    numStates = Types.cast2type(numStates, returnTypeName);
    calculationTime = toc(startTime);
else
    error('InterPile:UnknownAlgorithm', 'The method %s for the calculation of the number of recurrent states is unknown.', method);
end

% Return or print results.
if nargout > 0
    varargout{1} = factors;
else
    factorsString = '';
    for f = unique(factors)
        numF = sum(arrayfun(@(x)isequal(x, f), factors, 'UniformOutput', true));
        valString = Types.tostring(f);
        factorsString = sprintf('%s%s^%1.0f ', factorsString, valString, numF);
    end
    
    fprintf('Method:\t\t\t\t\t%s\n', method);
    fprintf('#recurrent:\t\t\t\t%s\n', Types.tostring(numStates));
    fprintf('Factorization:\t\t\t%s\n', factorsString);
    fprintf('Calculation Time:\t\t%.2fs\n', calculationTime);
end

end

