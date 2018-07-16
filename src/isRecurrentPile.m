function isRecurrent = isRecurrentPile(S)
% isRecurrentPile - determines if sandpile is recurrent.
% Usage:
%   recurrent = isRecurrentPile(S)
%       Returns true if S is recurrent, and false otherwise.
% Algorithm: 
%   Algorithm according to Figur 6.3 in 
%   Járai, Antal A. "The Sandpile Cellular Automaton." Probabilistic
%   Cellular Automata. Springer, Cham, 2018. 79-88.

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

if nargin <1
    S = ones(15,15)*3;
    S(7,2) = 4;
    S(4,6) = 4;
    S = relaxPile(S);
    %S(5,5) = S(5,5) - 1;
    plotSandPile(S);
end

% Filter to count number of remaining neighbours
neighbourFilter = zeros(3,3);
neighbourFilter(1, 2)= 1;
neighbourFilter(2, 1)= 1;
neighbourFilter(2, 3)= 1;
neighbourFilter(3, 2)= 1;

% Initially, all nodes are remaining
isRecurrent = false;
remaining = ones(size(S));
lastRemaining = inf;
numRemaining = size(S, 1) * size(S, 2);
while numRemaining < lastRemaining
    lastRemaining = numRemaining;
    % Update remaining nodes
    remaining = double(S < imfilter(remaining, neighbourFilter));
    % check if no node is remaining anymore
    numRemaining = sum(sum(remaining));
    if numRemaining == 0
        isRecurrent = true;
        break;
    end
end

return;
