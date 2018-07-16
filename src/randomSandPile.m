function S = randomSandPile(n,m)
% randomSandPile - Returns a random, not necessarily recurrent, sandpile.
% Usage:
%   S = randomSandPile()
%       Returns a random 255x255 sandpile.
%   S = randomSandPile(N)
%       Returns a random NxN sandpile.
%   S = randomSandPile(N,M)
%       returns a random NxM sandpile.

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
    n = 255;
end
if nargin < 2
    m=n;
end
S = randi(4,n,m)-1;
end

