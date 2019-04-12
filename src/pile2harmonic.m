function H = pile2harmonic(S, varargin)

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
addOptional(p,'numericThreshold', 1e-3);
addOptional(p,'typeName', typeName);
addOptional(p,'returnTypeName', Types.gettype(S));
parse(p,varargin{:});

numericThreshold = p.Results.numericThreshold;
typeName = p.Results.typeName;
if isempty(p.Results.returnTypeName)
    returnTypeName = typeName;
else
    returnTypeName = p.Results.returnTypeName;
end

[c1, c2, time] = pile2coord(S, ...
    'numericThreshold', numericThreshold,...
    'typeName', typeName,...
    'returnTypeName', typeName);


N = size(S, 1);
M = size(S, 2);

X=repmat(( 0:M+1) - (M+1)/2,   N+2, 1);
Y=repmat(((0:N+1) - (N+1)/2)', 1, M+2);
X=round(X+0.5);
Y=round(Y+0.5);
X = X(1:N+2, 1:N+2);
Y = Y(1:N+2, 1:N+2);

Hint = periodicHarmonic(Y, X, c1, c2, 'returnTypeName', typeName, 'typeName', typeName);
H = Types.cast2type(Hint*time(1)/time(2), returnTypeName);
end