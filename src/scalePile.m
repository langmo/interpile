function S = scalePile(S, scaling, varargin)

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

p = inputParser;
addOptional(p,'typeName', typeName);
addOptional(p,'returnTypeName', []);
parse(p,varargin{:});

typeName = p.Results.typeName;
if isempty(p.Results.returnTypeName)
    returnTypeName = typeName;
else
    returnTypeName = p.Results.returnTypeName;
end

S = Types.cast2type(S, typeName);

if ~exist('scaling', 'var') || isempty(scaling)
    scaling = 3;
end

H = pile2harmonic(S, 'typeName', typeName, 'returnTypeName', typeName);
H = scaleHarmonic(H, scaling, 'typeName', typeName, 'returnTypeName', typeName);
N = size(H, 1)-2;
M = size(H, 2)-2;
Pt = H(1, 2:end-1);
Pb = H(end, 2:end-1);
Pl = H(2:end-1, 1); 
Pr = H(2:end-1, end);
minVal = min([min(Pt), min(Pb), min(Pl), min(Pr)]);
Pt = Pt - minVal;
Pb = Pb - minVal;
Pl = Pl - minVal;
Pr = Pr - minVal;

S = nullPile(N, M);
S(1, :) = S(1, :) + Pt;
S(end, :) = S(end, :) + Pb;
S(:, 1) = S(:, 1) + Pl;
S(:, end) = S(:, end) + Pr;
S= Types.cast2type(relaxPile(S), returnTypeName);
end