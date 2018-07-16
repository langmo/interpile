function S = dropZoneCubic(height, width )

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

if nargin < 1
    width = 5;
    height = 4;
end
N = height;
S = zeros(N, N);

F = @(y,x) x.^3-3*x.*y.^2;

N0=ceil(sqrt(3)*(N+1)/2)-1;

% x=N0:N0+N+1;
% y=(-(N+1)/2:(N+1)/2)';
% 
% X = repmat(x, length(y), 1);
% Y = repmat(y, 1, length(x));
% F(Y, X)

S(:, 1) = S(:, 1)+F((-(N-1)/2:(N-1)/2)', N0);
S(:, end) = S(:, end)+F((-(N-1)/2:(N-1)/2)', N0+N+1);
S(1, :) = S(1, :) + F(-(N+1)/2, N0+1:N0+N);
S(end, :) = S(end, :) + F(+(N+1)/2, N0+1:N0+N);
end

