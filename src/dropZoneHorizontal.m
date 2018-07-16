function S = dropZoneHorizontal(height, width )

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
    width = 4;
    height = 4;
end
N = height;
S = zeros(height, height);
if mod(N, 2) == 1
    F = @(y,x) -(y-(N+1)/2).^2+(x+(N+1)/2-1).^2;
else
    F = @(y,x) (-(y-(N+1)/2).^2+(x+(N+1)/2-1).^2)./2;
end


S(1, 1:N) = S(1, 1:N) + F(0, 1:N);
S(N, 1:N) = S(N, 1:N) + F(N+1, 1:N);

S(1:N, 1) = S(1:N, 1) + F((1:N)', 0);
S(1:N, N) = S(1:N, N) + F((1:N)', N+1);
end

