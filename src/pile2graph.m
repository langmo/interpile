function G = pile2graph(S)
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

burning = true(size(S));
burning(2:end-1, 2:end-1) = false;
remaining = ~burning;

% Filter to count number of remaining neighbours
neighbourFilter = [0,1,0;1,0,1;0,1,0];
% how much we have to add to the idx of a vertex to get each of its
% neigbors, in the order: top, left, bottom, right (which is also the order
% in which we choose the parent node in case we have multiple choices).
neigbhourIdxDelta = [-1, -size(S, 1), 1, size(S, 1)];

sinkInd = numel(Sorg)+1;
startEdges = NaN(1, numel(Sorg)*4);
endEdges = NaN(1, numel(Sorg)*4);
nextEdgeId = 1;
while any(any(remaining))
    lastBurning = burning;
    lastRemaining = remaining;
    % Calculate number of non-burnt neigbors for each vertex
    numNeigbors = imfilter(double(remaining), neighbourFilter);
    remaining = lastRemaining & (S < numNeigbors);
    burning = lastRemaining & ~remaining; % newly burning in current step.
    burningIdx = find(burning)';
    
    if isempty(burningIdx)
        break;
    end
    for idx = burningIdx
        neigbourIdx = idx+neigbhourIdxDelta;
        lastBurningNeigbourIdx = neigbourIdx(lastBurning(neigbourIdx) | burning(neigbourIdx));
        [y, x]= ind2sub(size(burning), idx);
        startInd = sub2ind(size(Sorg), y-1, x-1);
        [endY, endX] = ind2sub(size(burning), lastBurningNeigbourIdx);
        isSink = endY == 1 | endY == size(burning, 1) | endX == 1 | endX == size(burning, 1);
        endInd = (endY-1) + (endX-2)*size(Sorg, 1);
        endInd(isSink) = sinkInd;
        startEdges(nextEdgeId:nextEdgeId+length(endInd)-1) = startInd;
        endEdges(nextEdgeId:nextEdgeId+length(endInd)-1) = endInd;
        nextEdgeId = nextEdgeId+length(endInd);
    end
end
G = graph(startEdges(1:nextEdgeId-1), endEdges(1:nextEdgeId-1), [], sinkInd);
return;
