function [indices, T] = toDistributionReal(S)
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
    S = harmonicO(3, 3);
end

T = sum(sum(S));
nI = sum(sum(S>0));
indices = NaN(nI, 3);

t=0;
idx = 1;
for y = 1 : size(S, 1)
    for x = 1 : size(S, 2)
        if S(y,x)<=0
            continue;
        end
        t = t+S(y,x)/T;
        indices(idx, :) = [y, x, t];
        idx = idx+1;
    end
end

end

