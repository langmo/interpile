function P = pile2potential(S, positive)

% Copyright (C) 2019 Moritz Lang
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
    S = 3*ones(14,14);
end
if nargin < 2
    positive = false;
end
Delta = cast([0,1,0;1,-4,1;0,1,0], class(S));

S = [zeros(1, size(S, 2)+2); ...
    zeros(size(S, 1), 1), S-cast(nullPile(size(S, 1), size(S, 2)), class(S)), zeros(size(S, 1), 1);...
    zeros(1, size(S, 2)+2)];

N = size(S, 1);
M = size(S, 2);

for dx = 0: ceil(M/2)-3

    x = floor(M/2)+1+dx;
    for dy = -dx-~mod(N,2):dx
        y = floor(N/2)+dy+1;
        S(y-1:y+1, x:x+2) = S(y-1:y+1, x:x+2) - S(y,x) * Delta;
    end
end

for dx = 1: ceil(M/2)-3+~mod(M,2)

    x = floor(M/2)+1-dx;
    for dy = -dx-~mod(N,2):dx
        y = floor(N/2)+dy+1;
        S(y-1:y+1, x-2:x) = S(y-1:y+1, x-2:x) - S(y,x) * Delta;
    end
end

for dy = 1: ceil(N/2)-3

    y = floor(N/2)+1+dy;
    for dx = -dy:dy + ~mod(M,2)
        x = floor(M/2)+dx+1;
        S(y:y+2, x-1:x+1) = S(y:y+2, x-1:x+1) - S(y,x) * Delta;
    end
end

for dy = 1: ceil(N/2)-3+~mod(N,2)

    y = floor(N/2)+1-dy;
    for dx = -dy-~mod(M,2):dy
        x = floor(M/2)+dx+1;
        S(y-2:y, x-1:x+1) = S(y-2:y, x-1:x+1) - S(y,x) * Delta;
    end
end
P = S(2:end-1, 2:end-1);
if positive
    minP = min(min(P));
    P(1, :) = P(1, :)-minP;
    P(end, :) = P(end, :)-minP;
    P(:, 1) = P(:, 1)-minP;
    P(:, end) = P(:, end)-minP;
end
end