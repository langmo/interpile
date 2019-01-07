function S = tree2pile(varargin)
% parent - determines spanning tree of recurrent configuration. Returns
% empty vector if non-recurrent.
% Usage:
%   S = tree2pile(parentIdx)
%   S = tree2pile(parentY, parentX)
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


S = zeros(size(varargin{1})+[2,2]);
if nargin == 1
    parentIdx = varargin{1};
    invalid = parentIdx == 0;
    parentY = 1+mod(parentIdx-1, size(parentIdx, 1));
    parentX = 1+floor((parentIdx-1)/size(parentIdx, 1));
    parentY(invalid) = 0;
    parentX(invalid) = 0;
else
    parentY = varargin{1};
    parentX = varargin{2};
end

% extend domain by one pixel in each direction such that we don't have to care for special cases for
% boundary vertices anymore.
parentX = parentX +1;
parentY = parentY +1;
parentY = [zeros(1, size(parentY, 2)+2); zeros(size(parentY, 1), 1), parentY, zeros(size(parentY, 1), 1); zeros(1, size(parentY, 2)+2)];
parentX = [zeros(1, size(parentX, 2)+2); zeros(size(parentX, 1), 1), parentX, zeros(size(parentX, 1), 1); zeros(1, size(parentX, 2)+2)];
% Connect former boundary vertices to new boundary vertices, if they were
% connected to the sink before.
for i=2:size(parentX, 1)-1
    if parentX(i, 2) == 1 && parentY(i, 2) == 1
        parentX(i, 2) = 1;
        parentY(i, 2) = i;
    end    
    if parentX(i, end-1) == 1 && parentY(i, end-1) == 1
        parentX(i, end-1) = size(parentX, 2);
        parentY(i, end-1) = i;
    end    
end
for j=2:size(parentY, 2)-1
    if parentX(2, j) == 1 && parentY(2, j) == 1
        parentX(2, j) = j;
        parentY(2, j) = 1;
    end    
    if parentX(end-1, j) == 1 && parentY(end-1,j) == 1
        parentX(end-1, j) = j;
        parentY(end-1, j) = size(parentY, 1);
    end    
end

% determine levels of each vertex
levels = zeros(size(parentX));
levels(2:end-1, 2:end-1) = NaN;
childX = zeros(size(levels));
childY = zeros(size(levels));
for y = 2:size(levels, 1)-1
    for x = 2:size(levels, 2)-1
        if ~isnan(levels(y,x))
            continue;
        end
        
        childX(y,x) = 0;
        childY(y,x) = 0;
        
        currentY = y;
        currentX = x;
        while isnan(levels(currentY,currentX))
            pX = parentX(currentY, currentX);
            pY = parentY(currentY, currentX);
            childX(pY, pX) = currentX;
            childY(pY, pX) = currentY;
            currentY = pY;
            currentX = pX;
        end
        while childX(currentY, currentX) ~= 0
            cX = childX(currentY, currentX);
            cY = childY(currentY, currentX);
            levels(cY, cX) = levels(currentY, currentX)+1;
            currentX = cX;
            currentY = cY;
        end
    end
end

% determine value of each vertex
for y = 2:size(levels, 1)-1
    for x = 2:size(levels, 2)-1
        t = levels(y,x);
        
        dy = [-1,0,1,0];
        dx = [0,-1,0,1];
        rel = 0;
        for p = 1:length(dx)
            if levels(y+dy(p), x+dx(p)) == t-1
                if y+dy(p)==parentY(y,x) && x+dx(p)==parentX(y,x)
                    break;
                else
                    rel = rel+1;
                end
            end
        end
        
        m_t = (levels(y-1,x) >= t) + (levels(y+1,x) >= t) + (levels(y,x-1) >= t) + (levels(y,x+1) >= t);
        %m_tm = m_{t-1}
        m_tm = (levels(y-1,x) >= t-1) + (levels(y+1,x) >= t-1) + (levels(y,x-1) >= t-1) + (levels(y,x+1) >= t-1);
        possValues = m_t:(m_tm-1);
        S(y,x) = possValues(1+mod(rel-x-y, length(possValues)));
    end
end
S = S(2:end-1, 2:end-1);

end
