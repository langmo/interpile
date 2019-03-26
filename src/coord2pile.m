function [S, varargout] = coord2pile(coeff1, coeff2, time, scaleFactor, varargin)

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

if ~exist('time', 'var') || isempty(time)
    time = 1;
end
if length(time) == 1
    time = [time, 1];
end
if ~exist('scaleFactor', 'var') || isempty(scaleFactor)
    scaleFactor = 1;
end
p = inputParser;
addOptional(p,'typeName', 'int64');
addOptional(p,'returnTypeName', []);
parse(p,varargin{:});
typeName = p.Results.typeName;
if isempty(p.Results.returnTypeName)
    returnTypeName = typeName;
else
    returnTypeName = p.Results.returnTypeName;
end

Nbase = (length(coeff1)-1)/2;
N = scaleFactor*(Nbase+1)-1;
Nodd = (scaleFactor+mod(scaleFactor+1,2))*(Nbase+1)-1;
Modd = Nodd;

X=repmat(( 0:Modd+1) - (Modd+1)/2,   Nodd+2, 1);
Y=repmat(((0:Nodd+1) - (Nodd+1)/2)', 1, Modd+2);
if mod(Modd,2) ~= 1
    X=round(X+0.5);
end
if mod(Nodd,2) ~= 1
    Y=round(Y+0.5);
end
X = X(1:N+2, 1:N+2);
Y = Y(1:N+2, 1:N+2);


X = [X(2:end-1, 1), X(2:end-1, end), X(1, 2:end-1)', X(end, 2:end-1)'];
Y = [Y(2:end-1, 1), Y(2:end-1, end), Y(1, 2:end-1)', Y(end, 2:end-1)'];

[Hbase, totalCoeff1, totalCoeff2] = periodicHarmonic(Y, X, coeff1, coeff2, 'typeName', typeName);
H = (time(1)*Hbase);
assert(~any(any(double(mod(H, time(2))))), 'InterPile:HarmonicFunctionDivisibility', 'Harmonic function not divisible by time!');
H = H / time(2);
% minimum is anyways at the boundary...
H = H -min(H(:));
if ~strcmpi(class(H), typeName)
    Hold = H;
    H = arrayfun(@(v)cast(v, typeName), Hold);
    assert(~any(any(Hold-H)), 'Rounding error during conversion from %s to %s!', class(Hold), class(H));
end

S = Types.cast2type(nullPile(N, N), typeName);
S(:, 1) = S(:, 1) + H(:, 1);
S(:, end) = S(:, end) + H(:, 2);
S(1, :) = S(1, :) + H(:, 3)';
S(end, :) = S(end, :) + H(:, 4)';

S = Types.cast2type(relaxPile(S), returnTypeName);

if nargout >= 3
    varargout{1} = totalCoeff1;
    varargout{2} = totalCoeff2;
end
if nargout >= 4
    varargout{3} = time;
end
end

function result = cast2type(value, typeName)
    if strcmpi(typeName, 'sym')
        result = sym(value);
    elseif strcmpi(typeName, 'vpi')
        result = vpi(value);
    else
        result = cast(value, typeName);
    end
end