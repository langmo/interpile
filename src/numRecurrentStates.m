function varargout = numRecurrentStates(varargin)
% Calculates the number of recurrent states.
% Usage:
%   numRecurrentStates(N)
%       Calculates the number of recurrent states for an NxN square domain.
%   numRecurrentStates(N, M)
%       Calculates the number of recurrent states for an NxM rectangular domain.
%   numRecurrentStates(mask)
%       Calculates the number of recurrent states for a domain
%       corresponding to the non-zero values of the mask.
%   numRecurrentStates(..., method)
%       Defines the method how the number of recurrent states is
%       determined. 
%       Options:
%        'laplacian' (default). The number of states is determined by
%           the absolute value of the determinant of the graph laplacian.
%        'potential'. The number of states is determined by the absolute
%           value of the determinant of the matrix P, where each column of
%           P corresponds to the potential of one (non-zero) harmonic
%           function, restricted to the boundary of the domain.
%   nRecturrent = numRecurrentStates(...)
%       Returns the number of recurrent states. If no return value is
%       requested, the number is displayed in the console.

% Copyright (C) 2018 Moritz Lang
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
    if strcmpi(varargin{i}, 'laplacian')
        overPotential = false;
    elseif strcmpi(varargin{i}, 'potential')
        overPotential = true;
    else
        error('InterPile:UnknownAlgorithm', 'The algorithm %s for the calculation of the number of recurrent states is unknown.', varargin{i});
    end
    i = i+1;
else
    overPotential = false;
end
if numel(varargin) >= i
    error('InterPile:TooManyArguments', 'Too many arguments provided for the calculation of the number of recurrent states.');
end
if nargout > 1
    error('InterPile:TooManyReturnValues', 'The function either returns zero or one value.');
end

if overPotential
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
        if any(any(PR))
            P(nextIdx, :) = PR(boundaryIdx);
            nextIdx = nextIdx+1;
            if nextIdx > size(P, 1)
                break;
            end
        end

        HI = imagHarmonicMonomial(h);
        PI = generateDropZone(HI, size(mask, 1), size(mask, 2), mask, false, false);
        if any(any(PI))
            P(nextIdx, :) = PI(boundaryIdx);
            nextIdx = nextIdx+1;
            if nextIdx > size(P, 1)
                break;
            end
        end
        h = h+1;
    end
    % Calculate determinant. Symbolic toolbox seems to be more precise...
    nStates = abs(double(det(sym(P))));
else
    maskIDs = find(mask);
    Delta = zeros(length(maskIDs));
    for i=1:length(maskIDs)
        M = zeros(size(mask, 1), size(mask, 2));
        M(maskIDs(i))=1;
        A = filter2([0,1,0;1,-4,1;0,1,0], M);
        Delta(i, :) = A(maskIDs);
    end
    % Calculate determinant. Symbolic toolbox seems to be more precise...
    nStates = abs(double(det(sym(Delta))));
end

if nargout > 0
    varargout{1} = nStates;
else
    fprintf('Number of recurrent states: %.0f\n', nStates);
end

end

