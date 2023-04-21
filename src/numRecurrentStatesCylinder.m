function varargout = numRecurrentStatesCylinder(N,M,C, varargin)
% Calculates the number of recurrent states of an NxM cylinder with shift C.
% That is: take a NxM rectangular domain. Denote by (n,m) the index of a
% vertex, where n=1..N and m=1..M. Glue the vertex (i,1) to
% (i+c, M). Let k be the number of direct neighbors of a vertex in the
% resulting domain. The vertex has than 4-k additional edges to the sink.

% Copyright (C) 2018-2023 Moritz Lang
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

p = inputParser;
inputIdx = 1;
addOptional(p,'typeName', typeName);
addOptional(p,'returnTypeName', []);
addOptional(p,'debug', false);
parse(p,varargin{inputIdx:end});
typeName = p.Results.typeName;
returnTypeName = p.Results.returnTypeName;
if isempty(returnTypeName)
    returnTypeName = typeName;
end
debug = p.Results.debug;

if nargout > 1
    error('InterPile:TooManyReturnValues', 'The function either returns zero or one value.');
end

%% Calculate via graph laplacian.
startTime = tic();
% Do it a bit more complicated to allow for potential future extensions.
mask = ones(N, M);
maskIDs = find(mask);
Delta = zeros(length(maskIDs));
for i=1:length(maskIDs)
    Morg = zeros(size(mask, 1), size(mask, 2));
    Morg(maskIDs(i))=1;
    Mex = [zeros(N, 1), Morg, zeros(N, 1)];
    Aex = filter2([0,1,0;1,-4,1;0,1,0], Mex);
    Aex(max(1,1+C):min(N, N+C), end-1) = Aex(max(1,1+C):min(N, N+C), end-1)+Aex(max(1,1-C):min(N, N-C), 1);
    Aex(max(1,1-C):min(N, N-C), 2) = Aex(max(1,1-C):min(N, N-C), 2)+Aex(max(1,1+C):min(N, N+C), end);
    Aorg = Aex(:, 2:end-1);
    Delta(i, :) = Aorg(maskIDs);
    
    if debug
        fprintf('------------------\n');
        fprintf('Vertex which topples:\n');
        fprintf([repmat('%2g ',1,size(Morg,2)) '\n'],Morg')
        fprintf('Result of toppling:\n');
        fprintf([repmat('%2g ',1,size(Aorg,2)) '\n'],Aorg')
    end
end
% Calculate determinant. Symbolic toolbox seems to be more precise...
numStates = abs(det(Types.cast2type(Delta, typeName)));
factors = Types.cast2type(factor(numStates), returnTypeName);
numStates = Types.cast2type(numStates, returnTypeName);
calculationTime = toc(startTime);


%% Return or print results.
if nargout > 0
    varargout{1} = factors;
else
    factorsString = '';
    for f = unique(factors)
        numF = sum(arrayfun(@(x)isequal(x, f), factors, 'UniformOutput', true));
        valString = Types.tostring(f);
        factorsString = sprintf('%s%s^%1.0f ', factorsString, valString, numF);
    end
    
    fprintf('Cylinder height:\t%g\n', N);
    fprintf('Cylinder width:\t\t%g\n', M);
    fprintf('Cylinder glued:\t\tLeft&right sides with shift %g\n', C);
    fprintf('#recurrent:\t\t\t%s\n', Types.tostring(numStates));
    fprintf('Factorization:\t\t%s\n', factorsString);
    fprintf('Calculation Time:\t%.2fs\n', calculationTime);
end

end

