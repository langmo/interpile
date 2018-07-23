function masks = domainMasks()
% Returns a cell array of domain masks.
% Usage:
%   masks = domainMasks()
% Notes:
%   The first element of every element of the cell array is the name of the
%   mask, the second is a function handle to generate the mask.

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

masks = {...
    {'Ellipsoid', @(y,x,height,width) x.^2/((width+1)/2).^2+y.^2/((height+1)/2).^2<1},...
    {'Punctured', @(y,x,height,width) floor(y) ~= 0 | floor(x) ~= 0},...
    {'Rotated Ellipse', @(y,x,height,width) (x./(width/2)+0.2*y./(height/2)).^2+(y./(height/2)).^2 <= 1},...
    {'Square Hole', @(y,x,height,width) abs(x)>width/4 | abs(y)>height/4}
    };

end

