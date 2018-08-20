function H = harmonicHalfplane(y,x, fct)
% Harmonic function which is zero for x<-y, and has the value fct(x) at the
% positive main diagonal x=y, x>=0. Furthermore, the function is symmetric
% with respect to y=x. This completely determines the harmonic function.

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
if nargin < 1 || isempty(x)
    N = 6;
    x=repmat(-N:N, 2*N+1, 1);
end
if nargin < 2 || isempty(y)
    y = x';
end
if nargin < 3 || isempty(fct)
    fct = @(diag) diag+1;
end

minX = min(min(min(x)), 0);
maxX = max(max(x));
minY = min(min(min(y)), 0);
maxY = max(max(y));

N = max([-minX, maxX, -minY, maxY]);

% we keep a one vertex wide empty border around H, simplifies calculation
H = zeros(2*N+3, 2*N+3);
idx = @(y,x)sub2ind(size(H), y+N+2, x+N+2);
D = @(H, y,x) H(idx(y+1, x)) + H(idx(y-1, x)) + H(idx(y, x+1)) + H(idx(y, x-1)) - 4*H(idx(y, x));


for diag = 0:0.5:N
    if mod(diag, 1) == 0
        H(idx(diag, diag)) = fct(diag);
        for k=1:N-diag
            H(idx(diag+k, diag-k)) = -D(H, diag+k-1, diag-k);
            H(idx(diag-k, diag+k)) = -D(H, diag-k, diag+k-1);
        end
    else
        H(idx(diag+0.5, diag-0.5)) = -D(H, diag-0.5, diag-0.5)/2;
        H(idx(diag-0.5, diag+0.5)) = H(idx(diag+0.5, diag-0.5));
        for k=1:N-diag-0.5
            H(idx(diag+k+0.5, diag-k-0.5)) = -D(H, diag+k-0.5, diag-k-0.5);
            H(idx(diag-k-0.5, diag+k+0.5)) = -D(H, diag-k-0.5, diag+k-0.5);
        end
    end
end

H = H(N+minY+2:maxY+N+2, N+minX+2:maxX+N+2);