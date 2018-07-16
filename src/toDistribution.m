function indices = toDistribution(S)
% toDistribution - Takes a potential and returns an array to quickly
% randomly access elements.
% Usage:
%   indices = toDistribution(potential)
%       Takes the potential S and returns an |S| x 2 matrix. 
%       Each row corresponds to an (y,x) position of a vertex of the
%       potential. The same (y,x) combination appears exactly as often as
%       potential(y,x). This matrix is
%       intended to be used for random particle dropping according to a
%       given potential. Given this matrix, one just has to choose with
%       randi a random column, and then increase the corresponding element
%       in the sandpile.
% Example:
%   % Drop a particle at a random boundary vertex according to a given
%   % potential:
%   distri = toDistribution(potential);
%   idx = randi(size(distri, 1));
%   S(distri(idx, 1), distri(idx, 2)) = S(distri(idx, 1), distri(idx, 2)) + 1;
%
% Note: 
%   Quick for potentials with reasonable amount of |potential|. For
%   potentials corresponding to higher-order harmonics, use
%   toDistributionReal() instead.

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

indices = NaN(sum(sum(S)), 2);
idx = 1;
for y = 1 : size(S, 1)
    for x = 1 : size(S, 2)
        for k = 1:S(y,x)
            indices(idx, :) = [y, x];
            idx = idx+1;
        end
    end
end
end

