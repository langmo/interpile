function S = scaleEpiPile(S, scaling, varargin)

% Copyright (C) 2020 Moritz Lang
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

returnTypeName = Types.gettype(S);
Norg = size(S, 1);
Morg = size(S, 2);

p = inputParser;
addOptional(p,'typeName', typeName);
addOptional(p,'returnTypeName', returnTypeName);
parse(p,varargin{:});

typeName = p.Results.typeName;
if isempty(p.Results.returnTypeName)
    returnTypeName = typeName;
else
    returnTypeName = p.Results.returnTypeName;
end

Sorg = Types.cast2type(toNonRecurrent(S), typeName);

if ~exist('scaling', 'var') || isempty(scaling)
    scaling = 3;
end

N=(Norg+1)/scaling-1;
M=(Morg+1)/scaling-1;
S = Types.zeros(N,M, typeName);
idxNorigin = ceil(scaling/2);
idxMorigin = ceil(scaling/2);
for idxN = 1:scaling
    for idxM = 1:scaling
        flipN = mod(idxN-idxNorigin, 2)+1;
        flipM = mod(idxM-idxMorigin, 2)+1;
        
        tile = Sorg((idxN-1)*(N+1)+(1:N), (idxM-1)*(M+1)+(1:M));
        if flipN ~= 1
            tile = -flipud(tile);
        end
        if flipM ~= 1
            tile = -fliplr(tile);
        end
        S=S+tile;
    end
end
S = toRecurrent(S);

S= Types.cast2type(relaxPile(S), returnTypeName);
end