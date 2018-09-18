function monomial = imagHarmonicMonomial(n)

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

monomial = @(Y,X) round(arrayfun(@(y,x)sum(arrayfun(@(j)(-1)^j * binom(x-j+floor(n/2)-1, n-2*j-1) .* binom(y+j, 2*j+1), 0:floor((n-1)/2))), Y, X));
end

function val = binom(n,k)
% Custom implementation of binomial coefficient n over k. The Matlab
% implementation nchoosek cannot cope with the case when n is negative...
val = prod(arrayfun(@(e)(n-e)./(k-e), 0:k-1));
end