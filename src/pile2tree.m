function varargout = pile2tree(S)
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

parent = NaN(size(S));
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
        lastBurningNeigbourIdx = neigbourIdx(lastBurning(neigbourIdx));
        [subY, subX]= ind2sub(size(burning), idx);
        parent(idx) = lastBurningNeigbourIdx(mod(subY+subX+S(idx)-numNeigbors(idx), length(lastBurningNeigbourIdx))+1);
    end
end

% translate indexes back into origninal size of domain
parent = parent(2:end-1, 2:end-1);
parentY = 1+mod(parent-1, size(S, 1));
parentX = 1+floor((parent-1)/size(S, 1));
%[parentY, parentX]=ind2sub(size(S), parent(:));
parentY = parentY-1;
parentX = parentX-1;
invalid = parentY<1 | parentY>size(Sorg, 1) | parentX<1 | parentX>size(Sorg, 2);
if nargout == 1
    varargout{1} = reshape(parentY+(parentX-1)*size(Sorg, 1), size(Sorg));
    varargout{1}(invalid) = 0;
else
    parentY(invalid) = 0;
    parentX(invalid) = 0;
    parentY = reshape(parentY, size(Sorg));
    parentX = reshape(parentX, size(Sorg));
    varargout{1} = parentY;
    varargout{2} = parentX;
    if nargout >= 3
        W = ones(size(Sorg));
        for yStart=1:size(Sorg, 1)
            for xStart=1:size(Sorg, 2)
                x=xStart;
                y=yStart;
                while parentX(y,x)>0
                    xOld = x;
                    yOld = y;
                    x=parentX(yOld,xOld);
                    y=parentY(yOld,xOld);
                    W(y,x) = W(y,x)+1;
                end
            end
        end
        varargout{3} = W;
    end
end

return;
