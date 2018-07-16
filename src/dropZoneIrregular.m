function S = dropZoneIrregular(height, width )

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

if nargin < 1
    width = 15;
    height = 15;
end

S = zeros(height, width);
if mod(width, 2) == 0
    borderV = 3/4*height;
    S(borderV, 1:width/2+1) = S(borderV, 1:width/2+1) + (1:width/2+1);
    S(borderV+1, 1:width/2+1) = S(borderV+1, 1:width/2+1) + 3 * (1:width/2+1);

    S(1:borderV, width/2+1) = S(1:borderV, width/2+1) + (1:borderV)';
    S(1:borderV, end) = S(1:borderV, end) + (width/2+1)*(1:borderV)';

    S(end:-1:borderV+1, width/2+1) = S(end:-1:borderV+1, width/2+1) + 3*(1:height-borderV)';

    S(end:-1:borderV+1, end) = S(end:-1:borderV+1, end) + 3*(width/2+1)*(1:height-borderV)';

    S(borderV, width/2+2:end) = S(borderV, width/2+2:end) + width/2+1;
    S(borderV+1, width/2+2:end) = S(borderV+1, width/2+2:end) + 3*(width/2+1);
else
    borderV = 3/4*(height+1);
    borderH = (width+1)/2;
    S(borderV, 1:borderH) = S(borderV, 1:borderH) + 4*(1:borderH);
    
    S(1:borderV, borderH) = S(1:borderV, borderH) + (1:borderV)';
    S(1:borderV, end) = S(1:borderV, end) + (borderH)*(1:borderV)';
    
    S(end:-1:borderV+1, borderH) = S(end:-1:borderV+1, borderH) + 3*(1:height-borderV)';
    
    S(end:-1:borderV+1, end) = S(end:-1:borderV+1, end) + 3*(borderH)*(1:height-borderV)';
    
    S(borderV, borderH+1:end) = S(borderV, borderH+1:end) + 4*(borderH);

end
end

