function harmonics = harmonicFunctions()
% Returns a cell array of harmonic functions up to an order of six.
% Usage:
%   harmonics = harmonicFunctions()
% Notes:
%   The first element of every element of the cell array is a text
%   representation of the harmonic function, the second is a function
%   handle representing the harmonic function.

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

harmonics = {...
    ... Order 0
    {'1', @(y,x)ones(size(x)), 'H0'},...
    ... Order 1
    {'x', @(y,x)x, 'H1a'},...
    {'y', @(y,x)y, 'H1b'},...
    ... Order 2
    {'x y', @(y,x)x.*y, 'H2a'},...
    {'x^2 - y^2', @(y,x)x.^2 - y.^2, 'H2b'},...
    ... Order 3
    {'x^3 - 3 x y^2', @(y,x) x.*(x.^2-3.*y.^2), 'H3a'},...
    {'y^3 - 3 y x^2', @(y,x) y.*(y.^2-3.*x.^2), 'H3b'},...
    ... Order 4
    {'x^4-6 x^2 y^2 + y^4 - x^2 - y^2', @(y,x) (x.^4-6*x.^2.*y.^2+y.^4)-(x.^2+y.^2), 'H4a'},... % extra term
    {'x^3 y-x y^3', @(y,x) (x.^3.*y-x.*y.^3), 'H4b'},...
    ... Order 5
    {'3 x^5 - 30 x^3 y^2 + 15 x y^4 - 10 x^3', @(y,x) 3.*x.^5-30*x.^3.*y.^2+15.*x.*y.^4 - 10*x.^3, 'H5a'},... % extra term
    {'3 y^5 - 30 y^3 x^2 + 15 y x^4 - 10 y^3', @(y,x) 3.*y.^5-30*y.^3.*x.^2+15.*y.*x.^4 - 10*y.^3, 'H5b'},... % extra term
    ... Order 6
    {'x^6 - 15 x^4 y^2 + 15 x^2 y^4 - y^6 - 5 x^4 +5 y^4', @(y,x) x.^6 - 15.*x.^4.*y.^2 + 15.*x.^2.*y.^4-y.^6 - 5*(x.^4-y.^4), 'H6a'},...  % extra term
    {'3 x^5 y - 10 x^3 y^3 + 3 x y^5 - 10 x^3 y - 10 x y^3', @(y,x)3.*x.^5.*y-10.*x.^3.*y.^3+3.*x.*y.^5-10.*x^3.*y-10.*x.*y.^3, 'H6b'}
    };

orders = 1:4;
idx0 = length(harmonics);
harmonics(end+2*length(orders)) = {[]};
for i = 1:length(orders)
    order = orders(i);
    nameReal = sprintf('G%gR', order);
    nameImag = sprintf('G%gI', order);
    harmonics(idx0+2*(i-1)+1) = {{nameReal, realHarmonicMonomial(order), nameReal}};
    harmonics(idx0+2*(i-1)+2) = {{nameImag, imagHarmonicMonomial(order), nameImag}};
end

end