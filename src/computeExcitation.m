function [excitation, varargout] = computeExcitation(harmonicFct, height, width)
% For a given harmonic function, calculates the excitation necessary to
% induce the dynamics corresponding to this harmonic on an height x width
% sandpile.
%
% Usage:
%   excitation = computeExcitation(harmonicFct, height, width)
%   [excitation, H] = computeExcitation(harmonicFct, height, width)
%   [excitation, H, k] = computeExcitation(harmonicFct, height, width)


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

%% Check input variables
if ~exist('harmonicFct', 'var') || isempty(harmonicFct)
    harmonicFct = @(y,x) x.*(x.^2-3.*y.^2);
end

if ~exist('height', 'var') || isempty(height)
    height = 128;
end
if ~exist('width', 'var') || isempty(width)
    width = height;
end

%% Compute the excitation
% Fill extended lattice with harmonic fct, with the origin set to the center of the lattice.
X=repmat((0:width+1) - (width+1)/2, height+2, 1);
Y=repmat(((0:height+1) - (height+1)/2)', 1, width+2);
% Use sub-sampled grid if width or height are not odd to make sure all
% values are integers.
if mod(width,2) ~= 1 || mod(height, 2) ~= 1
 X = 2*X;
 Y = 2*Y;
end
H = harmonicFct(Y, X);

% Make sure all values are integers
assert(all(all(mod(H,1)==0)));

% Make sure we really have a harmonic function
DeltaH = filter2([0,1,0;1,-4,1;0,1,0], H, 'valid');
assert(all(all(DeltaH==0)), 'Provided function is not harmonic!');

% Set corners to zero. The extended lattice does per definition not contain
% these corners, and their value is not used. 
% It is however easiert to include them in calculations to be able to use
% squre matrices. All we have to make sure is that these corners do not determine the value
% saying how often we have to add the constant harmonic H=1.
H(1,1) = 0;
H(end,1) = 0;
H(1,end) = 0;
H(end,end) = 0;

% Calculate how often we have to add the constant harmonic H=1 to make all
% values non-negative
k = -min(min(min(H)), 0);

% Add constant harmonic
H = H + k;

% Separate values which correspond to drop zone, and the ones which correspond to the board
excitation = struct();
excitation.Xt = zeros(height, width);
excitation.Xl = zeros(height, width);
excitation.Xb = zeros(height, width);
excitation.Xr = zeros(height, width);

excitation.Xt(1, :)    = H(1, 2:end-1);
excitation.Xb(end, :)  = H(end, 2:end-1);
excitation.Xl(:, 1)    = H(2:end-1, 1);
excitation.Xr(:, end)  = H(2:end-1, end);

H = H(2:end-1, 2:end-1);

if nargout == 0
    disp('Xt:');
    disp(excitation.Xt);
    disp('Xl:');
    disp(excitation.Xl);
    disp('Xb:');
    disp(excitation.Xb);
    disp('Xr:');
    disp(excitation.Xr);
end
if nargout > 1
    varargout{1} = H;
end
if nargout > 2
    varargout{2} = k;
end

end

