function [S, varargout] = relaxPile(S)
% Relaxes and returns the provided sandpile S.
% Usage:
%   S = relaxPile(S)
%   [S, H] = relaxPile(S)
% Arguments:
%   S ... sandpile to relax
% Returns:
%   S ... relaxed sandpile
%   H ... toppling matrix

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


N = size(S, 1);
M = size(S, 2);
% how often do we topple in total?
H = zeros(size(S), class(S));

if strcmpi(class(S), 'double')
    left = spdiags([ones(N,1),-4*ones(N,1), ones(N,1)], [-1,0,1], N, N);
    right = spdiags(ones(M,2), [-1,1], M, M);

    % how often do we topple in the current step?
    topplings = floor(max(S, 0)/4);

    while any(any(topplings))
        H = H + topplings;
        S = S + left * topplings + topplings * right;
        topplings = floor(max(S, 0)/4);
    end
else
    % how often do we topple in the current step?
    topplings = idivide(max(S, 0), cast(4, class(S)),'floor');

    while any(any(topplings))
        H = H + topplings;
        S = S - 4*topplings ...
            +[zeros(size(S, 1), 1, class(S)), topplings(:, 1:end-1)] ...
            +[topplings(:, 2:end), zeros(size(S, 1), 1, class(S))] ...
            +[zeros(1, size(S, 2), class(S)); topplings(1:end-1, :)] ...
            +[topplings(2:end, :); zeros(1, size(S, 2), class(S))];
        topplings = idivide(max(S, 0), cast(4, class(S)),'floor');
    end
end
if nargout == 0
    printPile(S);
elseif nargout > 1
    varargout{1} = H;
end

end