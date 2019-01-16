function varargout = pile2graph(S)
% parent - determines spanning tree of recurrent configuration. Returns
% empty vector if non-recurrent.
% Usage:
%   parentIdx = pile2tree(S)
%   [parentY, parentX] = pile2tree(S)
%   [parentY, parentX, weights] = pile2tree(S)
% Algorithm described in: 
%   Athreya, Siva R., and Antal A. Járai. 
%   "Infinite volume limit for the stationary distribution of Abelian sandpile models." 
%   Communications in mathematical physics 249.1 (2004): 197-213.

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

if nargin == 0
    S = nullPile(4,4);
end


% different to the org algo, we extend the sandpile in each directions by one vertex, and
% then assume that each of these additional vertices is burning at t=0.
% This allows us to avoid having to treat boundary vertices differently.
% Only at the end, we then condense all of these additional vertices to the
% root/sink (respectively, we delete all of them).
S = min(S, 3);
Sorg = S;
S = zeros(size(S)+[2,2]);
S(2:end-1, 2:end-1) = Sorg;

Norg = size(Sorg, 1);
N = size(S, 1);
M = size(S, 2);

burnStartInd = sub2ind([N, M], [2:N-1,            2:N-1,              2*ones(1, M-4), (N-1)*ones(1, M-4)], [2*ones(1, N-2),   (M-1)*ones(1, N-2), 3:M-2,          3:M-2]);
unburned = true(size(S));
unburned(1, 1) = false;
unburned(N, 1) = false;
unburned(1, M) = false;
unburned(N, M) = false;

boundary = true(N, M);
boundary(2:end-1, 2:end-1) = false;

% how much we have to add to the idx of a vertex to get each of its
% neigbors, in the order: top, left, bottom, right.
neigbhourIdxDelta = [-1, -size(S, 1), 1, size(S, 1)];


vertEdges = false(size(Sorg, 1)-1, size(Sorg, 2));
horEdges = false(size(Sorg, 1), size(Sorg, 2)-1);

anyBurned = true;
alreadyBurned = false(size(burnStartInd));
while anyBurned
    anyBurned = false;
    unburnedStart = unburned;
    for bId = 1:length(burnStartInd)
        if alreadyBurned(bId)
            continue;
        end
        burning = false(size(S));
        burning(burnStartInd(bId)+neigbhourIdxDelta) = true;
        burning = burning & boundary;
        
        subUnburned = unburnedStart & ~burning;
        [subVertEdges, subHorEdges, subUnburned] = burn(S, subUnburned, burning);
        subUnburned = subUnburned & ~boundary;
        if ~subUnburned(burnStartInd(bId))
            alreadyBurned(bId) = true;
            anyBurned = true;
            vertEdges = vertEdges | subVertEdges;
            horEdges = horEdges | subHorEdges;
            unburned = unburned & subUnburned;
        end
    end
end

numEdges = sum(sum(horEdges))+sum(sum(vertEdges));
startEdges = NaN(1, numEdges);
endEdges = NaN(1, numEdges);
nextEdge = 1;
for startY=1:size(vertEdges, 1)
    for startX=1:size(vertEdges, 2)
        if vertEdges(startY,startX)
            startEdges(nextEdge) = startY+(startX-1)*Norg;
            endEdges(nextEdge) = 1+startY+(startX-1)*Norg;
            nextEdge = nextEdge+1;
        end
    end
end
for startY=1:size(horEdges, 1)
    for startX=1:size(horEdges, 2)
        if horEdges(startY,startX)
            startEdges(nextEdge) = startY+(startX-1)*Norg;
            endEdges(nextEdge) = startY+startX*Norg;
            nextEdge = nextEdge+1;
        end
    end
end

varargout{1} = graph(startEdges, endEdges, [], numel(Sorg));
if nargout >= 2
    varargout{2} = unburned(2:end-1, 2:end-1);
end
end

function [vertEdges, horEdges, remaining] = burn(S, remaining, burning)
    % how much we have to add to the idx of a vertex to get each of its
    % neigbors, in the order: top, left, bottom, right.
    neigbhourIdxDelta = [-1, -size(S, 1), 1, size(S, 1)];

    N = size(S, 1);
    M = size(S, 2);
    left = spdiags([ones(N,1),ones(N,1)], [-1,1], N, N);
    right = spdiags(ones(M,2), [-1,1], M, M);
    
    orgSize = size(S)-[2,2];
    vertEdges = false(orgSize(1)-1, orgSize(2));
    horEdges = false(orgSize(1), orgSize(2)-1);
    while any(any(remaining)) && any(any(burning))
        lastBurning = burning;
        lastRemaining = remaining;
        % Calculate number of non-burnt neigbors for each vertex
        %numNeigbors = imfilter(double(remaining), neighbourFilter);
        numNeigbors = left * remaining + remaining * right;
        remaining = lastRemaining & (S < numNeigbors);
        burning = lastRemaining & ~remaining; % newly burning in current step.
        burningIdx = find(burning)';

        if isempty(burningIdx)
            break;
        end
        for idx = burningIdx
            y = 1+mod(idx-1, N);
            x = 1+floor((idx-1)./N);
            if y == 1 || y == size(burning, 1) || x == 1 || x == size(burning, 1)
                continue;
            end
            neigbourIdx = idx+neigbhourIdxDelta;
            lastBurningNeigbourIdx = neigbourIdx(lastBurning(neigbourIdx));
            
            delta = 1+S(idx)-numNeigbors(idx);
            if delta > length(lastBurningNeigbourIdx)
                continue;
            end
            SlastBurning = S(lastBurningNeigbourIdx);
            Ssort = sort(SlastBurning);
            Schosen = Ssort(delta);
            lastBurningNeigbourIdx = lastBurningNeigbourIdx(SlastBurning==Schosen);

            endY = 1+mod(lastBurningNeigbourIdx-1, N);
            endX = 1+floor((lastBurningNeigbourIdx-1)./N);
            isSink = endY == 1 | endY == size(burning, 1) | endX == 1 | endX == size(burning, 1);
            
            for endIdx = 1:length(isSink)
                if isSink(endIdx)
                    continue;
                elseif endY(endIdx) ~= y
                    % vertical edge
                    vertEdges(min(y, endY(endIdx))-1, x-1) = true;
                else
                    % horizontal edge
                    horEdges(y-1, min(x, endX(endIdx))-1) = true;
                end
            end
        end
    end
end