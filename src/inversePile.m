function S = inversePile( S )
% inversePile - returns the inverse of the provided sandpile
% Usage:
%   Sinv = inversePile(S)
% Note:
%   The algorithm assumes that S is recurrent.
% Algorithm: adding 6-6° and relaxing is the same as adding (6-6°)° and
%   relaxing, where the latter is the null element. Note that 6-6° is >=3
%   everywhere.
%   Thus, 2*(6-6°) is >= 6 everywhere.
%   Thus, 2*(6-6°)-S is >=3 everywhere, since S is <=3 everywhere.
%   Thus, (2*(6-6°)-S)^* = (-S)

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

S=relaxPile(2*(6*ones(size(S))-relaxPile(6*ones(size(S))))-S);
end

