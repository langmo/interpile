function [S, varargout] = relaxPile(S, varargin)
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
typeName = Types.gettype(S);

p = inputParser;
addOptional(p,'returnTypeName', typeName);
parse(p,varargin{:});
returnTypeName = p.Results.returnTypeName;

if strcmpi(typeName, 'single') || strcmpi(typeName, 'int8') || strcmpi(typeName, 'uint8')
    S=double(S);
    typeName = 'double';
end

N = size(S, 1);
M = size(S, 2);
% how often do we topple in total?
H = Types.zeros(size(S), typeName);

if strcmpi(typeName, 'double')
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
    topplings = Types.idivide(max(S, Types.cast2type(0, typeName)), 4);
    switchThreshold = Types.cast2type(round(flintmax('double')/100), typeName);
    while any(any(topplings~=0))
        switchAlgo = true;
        for idx=1:numel(S)
           if S(idx) >= switchThreshold 
               switchAlgo = false;
               break;
           end
        end
        if switchAlgo
            [S, Ht] = relaxPile(Types.cast2type(S, 'double'));
            H = H+Types.cast2type(Ht, typeName);
            break;
        end
        H = H + topplings;
        S = S - 4*topplings ...
            +[Types.zeros(size(S, 1), 1, class(S)), topplings(:, 1:end-1)] ...
            +[topplings(:, 2:end), Types.zeros(size(S, 1), 1, class(S))] ...
            +[Types.zeros(1, size(S, 2), class(S)); topplings(1:end-1, :)] ...
            +[topplings(2:end, :); Types.zeros(1, size(S, 2), class(S))];
        topplings = Types.idivide(max(S, Types.cast2type(0, typeName)), 4);
    end
end

if nargout == 0
    S = Types.cast2type(S, 'double');
    printPile(S);
else
    S = Types.cast2type(S, returnTypeName);
    H = Types.cast2type(H, returnTypeName);
    if nargout > 1
        varargout{1} = H;
    end
end

end