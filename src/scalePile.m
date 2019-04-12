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

typeName = Types.gettype(S);

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
P = [H(1, 2:end-1); H(end, 2:end-1); H(2:end-1, 1)'; H(2:end-1, end)'];
P = P-min(min(P));
S = nullPile(N, M);
S(1, :) = S(1, :) + P(1, :);
S(end, :) = S(end, :) + P(2, :);
S(:, 1) = S(:, 1) + P(3, :)';
S(:, end) = S(:, end) + P(4, :)';
S= Types.cast2type(relaxPile(S), returnTypeName);
end