function [A, nA, varargout] = determineAvalancheDistributionStoch(S, harmonic, harmonicName, numRounds, fileName)

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

%% Configuration
if nargin < 1 || isempty(S)
    S = nullPile(127, 127);
end
if nargin < 4 || isempty(numRounds)
    numRounds = 1;
end
if nargin < 2 || isempty(harmonic)
    %harmonic = @(y,x) x;
    %harmonicName = 'x';
    harmonic = @(y,x) x.*(x.^2-3.*y.^2);
    harmonicName = 'x^3 - 3 x y^2';
elseif nargin < 3 || isempty(harmonic)
    harmonicName = 'userDefined';
end
width = size(S, 2);
height = size(S, 1);

if ~exist('fileName', 'var') || isempty(fileName)
    folder = 'avalancheDistributions';
    if ~exist(folder, 'dir')
        mkdir(folder);
    end
    fileName = fullfile(folder, sprintf('fct_%s_%gx%g_%grounds.mat', harmonicName, height, width, numRounds));
end

%% Initialize variables
S = nullPile(height, width);
X = generateDropZone(harmonic, height, width);

[A, nA, Sfinal] = avalancheDistributionStoch(S, X, numRounds, @callback);

[folder, ~, ~] = fileparts(fileName);
if ~exist(folder, 'dir')
    mkdir(folder);
end
save(fileName, 'height', 'width', 'harmonicName', 'numRounds', 'A', 'nA', 'S', 'Sfinal');

if nargout > 2
    varargout{1} = Sfinal;
end

end
function callback(progress)
    persistent lastMessageLength;
    if progress == 0
        lastMessageLength = 0;
    end
    if progress == 1
        message = '100%% progress. Finished!\n';
    else
        message = sprintf('%2.5f%%%% progress...', progress*100);
    end
    fprintf([repmat('\b', 1, lastMessageLength), message]);
    
    lastMessageLength = length(message)-1; % -1 because we have to excape the percentage sign
end