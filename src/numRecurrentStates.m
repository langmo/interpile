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
%   factors = numRecurrentStates(..., method)
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

i = 1;
if numel(varargin{i}) > 1
    mask = varargin{i};
    i = i+1;
else
    N = varargin{i};
    i = i+1;
    if numel(varargin) >= i && isnumeric(varargin{i}) && numel(varargin{i}) == 1
        M = varargin{i};
        i = i+1;
    else
        M = N;
    end
    mask = ones(N, M);
end

if numel(varargin) >= i && ischar(varargin{i})
    methodString = varargin{i};
    if strcmpi(methodString, 'laplacian')
        method = 0;
    elseif strcmpi(methodString, 'potential')
        method = 1;
    elseif strcmpi(methodString, 'potentialPolynoms')
        method = 2;
    else
        error('InterPile:UnknownAlgorithm', 'The algorithm %s for the calculation of the number of recurrent states is unknown.', methodString);
    end
    i = i+1;
else
    methodString = 'potential';
    method = 1;
end
if numel(varargin) >= i
    error('InterPile:TooManyArguments', 'Too many arguments provided for the calculation of the number of recurrent states.');
end
if nargout > 1
    error('InterPile:TooManyReturnValues', 'The function either returns zero or one value.');
end
if method == 1
    % Calculate via potentials.
    startTime = tic();
    maskExtended = zeros(size(mask, 1)+2, size(mask, 2)+2);
    maskExtended(2:end-1, 2:end-1) = mask;
    boundary = filter2([0,1,0;1,0,1;0,1,0], ~maskExtended);
    boundary = boundary(2:end-1, 2:end-1);
    boundary = boundary ~=0 & mask;
    boundaryIdx = find(boundary);
    P = NaN(length(boundaryIdx));
    H0 = diagHarmonic(0,1);
    P0 = generateDropZone(H0, size(mask, 1), size(mask, 2), mask, false, false);
    P(1, : ) = P0(boundaryIdx);
    nextIdx = 2;
    h = 1;
    while nextIdx <= size(P, 1)
        for sign = [-1, 1]
            for type = 1:2
                if type==1 && h==1 && sign== 1
                    continue;
                end
                Hi = diagHarmonic(sign*h, type);
                Pi = generateDropZone(Hi, size(mask, 1), size(mask, 2), mask, false, false);
                Pbound = Pi(boundaryIdx);
                if any(Pbound)
                    P(nextIdx, :) = Pbound;
                    nextIdx = nextIdx+1;
                    if nextIdx > size(P, 1)
                        break;
                    end
                end
            end
        end
        h = h+1;
    end
    % Calculate determinant. Symbolic toolbox seems to be more precise...
    factors = double(factor(abs(det(sym(P)))));
    calculationTime = toc(startTime);
elseif method == 2    
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
    factors = double(factor(abs(det(sym(P))))); 
    calculationTime = toc(startTime);
else
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
    factors = double(factor(abs(det(sym(Delta)))));
    calculationTime = toc(startTime);
end

% Return or print results.
if nargout > 0
    varargout{1} = factors;
else
    factorsString = '';
    for f = unique(factors)
        factorsString = sprintf('%s%1.0f^%1.0f ', factorsString, f, sum(factors==f));
    end
    numStates = sum(log10(factors));
    if numStates < 8
        numStatesString = sprintf('%g', 10^numStates);
    else
        numStatesString = sprintf('%ge+%02.0g', 10^mod(numStates, 1), floor(numStates));
    end
    
    fprintf('Method:\t\t\t\t\t%s\n', methodString);
    fprintf('#recurrent:\t\t\t\t%s\n', numStatesString);
    fprintf('Factorization:\t\t\t%s\n', factorsString);
    fprintf('Calculation Time:\t\t%.2fs\n', calculationTime);
end

end

