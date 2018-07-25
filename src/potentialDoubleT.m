function S = potentialDoubleT(height, width )

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
    width = 10;
    height = 6;
end
assert(mod(width, 2)==0&&mod(height, 2)==0, 'Only NxM domains supported for N and M even.');

S = zeros(height, width);

S(1, 1:width/2) = S(1, 1:width/2) + (1:width/2);
S(end, 1:width/2) = S(end, 1:width/2) + (1:width/2);

S(1, width/2+1:1:end) = S(1, width/2+1:1:end) + (width/2:-1:1);
S(end, width/2+1:1:end) = S(end, width/2+1:1:end) + (width/2:-1:1);

S(1:end, width/2) = S(1:end, width/2)+1;
S(1:end, width/2+1) = S(1:end, width/2+1)+1;
end

