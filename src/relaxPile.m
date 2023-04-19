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
% Maximal value of S in order to immediately switch to double data types
% (if we are not already doubles, anyway), since for doubles we can use the
% fastest algorithms, including the use of sparse matrices which, for
% whatever reason, seem not to be implemented for anything else than
% doubles.
switchThreshold = round(flintmax('double')/100);

p = inputParser;
addOptional(p,'returnTypeName', typeName);
addOptional(p,'toppleNegative', true);
parse(p,varargin{:});
returnTypeName = p.Results.returnTypeName;
toppleNegative = p.Results.toppleNegative;

if nargout > 1
    % how often do we topple in total?
    H = Types.zeros(size(S), returnTypeName);
end

if strcmpi(typeName, 'double')
    % Everything fine, that's the type where we are by far most efficient.
elseif strcmpi(typeName, 'single') ...
        || strcmpi(typeName, 'int8') || strcmpi(typeName, 'uint8')...
        || strcmpi(typeName, 'int16') || strcmpi(typeName, 'uint16')...
        || strcmpi(typeName, 'int32') || strcmpi(typeName, 'uint32')...
    % Just switch to doubles and convert back lateron. These types really
    % have no benefits for us here, since they cannot carry larger numbers
    % AND are also less efficient (no sparse matrices for them).
    S=double(S);
    typeName = 'double';
else
    maxS = max(S(:));
    if maxS < switchThreshold
        % we are small enough such that we can simply also not care for the
        % other types...
        S = Types.cast2type(S, 'double');
        typeName = 'double';
    else
        % Use a recursive approach. Essentially, we just put a certain
        % amount of "normal particles" into "big particles". We then topple only the
        % big particles, getting rid of a lot of them: after the recursive
        % relaxation, we have max 3 big particles per field left. Now, we
        % disassemble these big particles into small ones again, and topple
        % those. The advantage is that we thus can limit the maximal number of
        % particles of a certain size we have to care about at once to a number
        % double variables can handle, and we are way faster using doubles...
        S1 = Types.idivide(S, switchThreshold);
        % Calculating maxS is actually quite expensive for some data types.
        % While we could of course let recursion handle the casting, it can
        % thus pay of to reuse our knowledge of maxS to do the casting
        % already here, if this is possible.
        if Types.idivide(maxS, switchThreshold) < switchThreshold
            S1 = Types.cast2type(S1, 'double');
        end
        
        if nargout > 1
            [S1, H1] = relaxPile(S1, 'returnTypeName', 'double');
            H = H + Types.cast(switchThreshold, 'returnTypeName') * Types.cast(H1, 'returnTypeName');
        else
            S1 = relaxPile(S1, 'returnTypeName', 'double');
        end
        S = Types.cast2type(mod(S, switchThreshold), 'double')...
            +S1 * switchThreshold;
        typeName = 'double';
    end
end
    
N = size(S, 1);
M = size(S, 2);
identity = [];
if strcmpi(typeName, 'double')
    left = spdiags([ones(N,1),-4*ones(N,1), ones(N,1)], [-1,0,1], N, N);
    right = spdiags(ones(M,2), [-1,1], M, M);

    while true
        % how often do we topple in the current step?
        if toppleNegative
            topplings = floor(S/4);
        else
            topplings = max(floor(S/4), 0);
        end
        topplings(isinf(S))=0;
        if ~any(topplings(:))
            break;
        end
        minTopplings = min(topplings(:));
        if minTopplings > 1
            % every vertex topples at least twice. This means that there
            % are way too many particles in the system. It is now quicker
            % to remove a lot of them simply by substracting the identity
            if isempty(identity)
                mask = ~isinf(S);
                identity = nullPile(size(S, 1), size(S, 2), mask);
                identity(~mask)=0;
            end
            S = S - (minTopplings-1)*identity;
            topplings = topplings - (minTopplings-1);
        end
        if nargout > 1
            H = H + topplings;
        end
        S = S + left * topplings + topplings * right;
    end
elseif strcmpi(typeName, 'sym')
    left = sym(spdiags([ones(N,1),-4*ones(N,1), ones(N,1)], [-1,0,1], N, N));
    right = sym(spdiags(ones(M,2), [-1,1], M, M));
    while true
        % we don't need to check here if we topple at all, since if this is
        % not the case we will already have switched to the algorithm for
        % double types.
        if max(S(:)) < switchThreshold
            if nargout == 1
                S = relaxPile(Types.cast2type(S, 'double'));
            else
                [S, Ht] = relaxPile(Types.cast2type(S, 'double'));
                H = H+Types.cast2type(Ht, returnTypeName);
            end
            break;
        end
        
        % how often do we topple in the current step?
        if toppleNegative
            topplings = floor(S/4);
        else
            topplings = max(floor(S/4), 0);
        end
        minTopplings = min(topplings(:));
        if minTopplings > 1
            % every vertex topples at least twice. This means that there
            % are way too many particles in the system. It is now quicker
            % to remove a lot of them simply by substracting the identity
            if isempty(identity)
                mask = ~isinf(S);
                identity = nullPile(size(S, 1), size(S, 2), mask);
                identity(~mask)=0;
            end
            S = S - (minTopplings-1)*identity;
            topplings = topplings - (minTopplings-1);
        end
        if nargout > 1
            H = H + topplings;
        end
        S = S + left * topplings + topplings * right;
    end
else
    while true 
        % we don't need to check here if we topple at all, since if this is
        % not the case we will already have switched to the algorithm for
        % double types.
        if strcmpi(typeName, 'vpi')
            switchAlgo = true;
            for idx=1:numel(S)
               if S(idx) >= switchThreshold 
                   switchAlgo = false;
                   break;
               end
            end
        else
            switchAlgo = max(S(:)) < switchThreshold;
        end
        if switchAlgo
            if nargout == 1
                S = relaxPile(Types.cast2type(S, 'double'));
            else
                [S, Ht] = relaxPile(Types.cast2type(S, 'double'));
                H = H+Types.cast2type(Ht, returnTypeName);
            end
            break;
        end
        % how often do we topple in the current step?
        topplings = Types.idivide(S, 4);
        
        minTopplings = min(topplings(:));
        if minTopplings > 1
            % every vertex topples at least twice. This means that there
            % are way too many particles in the system. It is now quicker
            % to remove a lot of them simply by substracting the identity
            if isempty(identity)
                mask = ~isinf(S);
                identity = nullPile(size(S, 1), size(S, 2), mask);
                identity(~mask)=0;
                identity = Types.cast2type(identity, typeName);
            end
            S = S - (minTopplings-1)*identity;
            topplings = topplings - (minTopplings-1);
        end
        if nargout > 1
            H = H + topplings;
        end
        S = S - 4*topplings ...
            +[Types.zeros(size(S, 1), 1, class(S)), topplings(:, 1:end-1)] ...
            +[topplings(:, 2:end), Types.zeros(size(S, 1), 1, class(S))] ...
            +[Types.zeros(1, size(S, 2), class(S)); topplings(1:end-1, :)] ...
            +[topplings(2:end, :); Types.zeros(1, size(S, 2), class(S))];
    end
end

if nargout == 0
    S = Types.cast2type(S, 'double');
    printPile(S);
else
    S = Types.cast2type(S, returnTypeName);
    if nargout > 1
        varargout{1} = Types.cast2type(H, returnTypeName);
    end
end

end