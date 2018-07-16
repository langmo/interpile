function excitation = excitationIrregular(height, width )

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
    width = 8;
    height = 8;
end

Xt = zeros(height, width);
Xl = Xt;
Xb = Xt;
Xr = Xt;
if mod(width, 2) == 0
    borderT = 3/4*(height);
    borderB = borderT+1;
    borderL = (width)/2;
    borderR = borderL+1;
    
    Xt(1, 1:borderL ) = 1;
    Xt(borderB, 1:borderL ) = 3*(1:borderL);
    Xt(borderB, borderL+1:end ) = 3*(1+borderL);
    
    Xb(end, 1:borderL ) = 1;
    Xb(borderT, 1:borderL ) = (1:borderL);
    Xb(borderT, borderL+1:end ) = (1+borderL);
        
    Xl(:, 1) = 1;
    Xl(1:borderT, borderR) = 0:(borderT-1);
    Xl(end:-1:borderB, borderR) = (1:(height-borderT))*3-1;
    
    Xr(:, borderL) = 1;
    Xr(1:borderT, end) = (borderR)*(1:borderT)';
    Xr(end:-1:borderB, end) = 3*(borderR)*(1:(height-borderT))';
else
    borderV = 3/4*(height+1);
    borderH = (width+1)/2;

    Xt(borderV, 1:borderH) = 4*(1:borderH);
    Xt(borderV, borderH+1:end) = 4*(borderH);


    Xr(1:borderV, borderH) = (1:borderV)';
    Xr(1:borderV, end) = (borderH)*(1:borderV)';
    Xr(end:-1:borderV+1, borderH) = 3*(1:height-borderV)';
    Xr(end:-1:borderV+1, end) = 3*(borderH)*(1:height-borderV)';
end

if nargout == 0
    disp('Xt:');
    disp(Xt);
    disp('Xl:');
    disp(Xl);
    disp('Xb:');
    disp(Xb);
    disp('Xr:');
    disp(Xr);
else
    excitation = struct();
    excitation.Xt = Xt;
    excitation.Xl = Xl;
    excitation.Xb = Xb;
    excitation.Xr = Xr;
end
end

