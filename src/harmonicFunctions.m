function harmonics = harmonicFunctions()

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
    {'1', @(y,x)ones(size(x))},...
    ... Order 1
    {'x', @(y,x)x},...
    {'y', @(y,x)y},...
    ... Order 2
    {'x y', @(y,x)x.*y},...
    {'x^2 - y^2', @(y,x)x.^2 - y.^2},...
    ... Order 3
    {'x^3 - 3 x y^2', @(y,x) x.*(x.^2-3.*y.^2)},...
    ... Order 4
    {'x^4-6 x^2 y^2 + y^4 - x^2 - y^2', @(y,x) (x.^4-6*x.^2.*y.^2+y.^4)-(x.^2+y.^2)},... % extra term
    {'x^3 y-x y^3', @(y,x) (x.^3.*y-x.*y.^3)},...
    ... Order 5
    {'3 x^5 - 30 x^3 y^2 + 15 x y^4 - 10 x^3', @(y,x) 3.*x.^5-30*x.^3.*y.^2+15.*x.*y.^4 - 10*x.^3},... % extra term
    {'3 y^5 - 30 y^3 x^2 + 15 y x^4 - 10 y^3', @(y,x) 3.*y.^5-30*y.^3.*x.^2+15.*y.*x.^4 - 10*y.^3},... % extra term
    ... Order 6
    {'x^6 - 15 x^4 y^2 + 15 x^2 y^4 - y^6 - 5 x^4 +5 y^4', @(y,x) x.^6 - 15.*x.^4.*y.^2 + 15.*x.^2.*y.^4-y.^6 - 5*(x.^4-y.^4)},...  % extra term
    {'3 x^5 y - 10 x^3 y^3 + 3 x y^5 - 10 x^3 y - 10 x y^3', @(y,x)3.*x.^5.*y-10.*x.^3.*y.^3+3.*x.*y.^5-10.*x^3.*y-10.*x.*y.^3}...
    };
end