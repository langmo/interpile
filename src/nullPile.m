function S = nullPile(n, m, mask, maskName)
% nullPile - Calculates the sandpile group identity element for a NxM
% domain.
% Usage:
%   S = nullPile()
%       Returns identity element for a 255x255 square domain.
%   S = nullPile(N)
%       Returns identity element for an NxN square domain.
%   S = nullPile(N, M)
%       Returns identity element for an NxM rectangular domain.
%   S = nullPile(N, M, mask, maskName)
%       Returns identity element for an arbitrary domain which fits into an
%       NxM rectangular. The NxM logical matrix mask defines which vertices
%       belong to the domain (true) and which not (false). The variable
%       maskName must be a string identifying the mask. Using the same
%       string for different masks for the same NxM domain results in
%       undefined behavior.
% Algorithm:
%   Based on the following algorithm:
%   if f and g are two states then (f+g*)*=(f+g)*
%   (where * denotes the relaxation)
%   Now note that 6* and (6-6*)* are recurrent, since obtained from 3 by adding. Apply the trick to them: 
%   (6*+(6-6*)*)*=(6*+6-6*)*=6* 
%   Therefore, (6-6*)* has to be the zero of the sandpile group.
%   S = relaxPile(6*ones(n,m)-relaxPile(6*ones(n,m)));
%   Same works also from 5, since 2 is always reachable for rectangles.
% Note:
%   To increase speed, identities are saved into a file in the folder
%   null_piles/ once calculated. This explains the need to specify a
%   unique maskName, based on which the correct file to load the respective
%   identity is selected.

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
    n = 255;
end
if nargin < 2
    m = n;
end
if nargin < 3
    mask = ones(n, m);
end
if nargin < 4 || isempty(maskName)
    maskName = '';
else
    maskName = ['_', maskName];
end
if all(all(mask == ones(n, m)))
    maskName = '';
    savePile = true;
elseif isempty(maskName)
    savePile = false;
else
    savePile = true;
end

%% Load identity if it was previously saved
if savePile
    if ~isdeployed()
        dirName = 'null_piles';
    else
        dirName = fullfile(ctfroot(), 'null_piles');
    end
    fileName = fullfile(dirName, sprintf('%gx%g%s.mat', n, m, maskName));
    if exist(fileName, 'file')
        load(fileName, 'S');
        return;
    end
end

%% Calculate identity
filled = 5*ones(n,m);
filled(~mask) = -inf;

S = filled-relaxPile(filled);
S(~mask) = -inf;
S = relaxPile(S);

%% Save mask for later use
if savePile
    try
        if ~exist(dirName, 'dir')
            mkdir(dirName);
            fprintf('Saving nullpiles in folder %s to speed up program.\n', dirName);
        end
        save(fileName, 'S');
    catch
        % do nothing. The identity simply has to be calculated again next
        % time.
    end
end
end

