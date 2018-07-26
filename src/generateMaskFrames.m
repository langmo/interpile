function configPath = generateMaskFrames(configPath, callback)

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

if ~exist('callback', 'var') || isempty(callback)
    callback = @(x)1;
end
load(configPath, 'harmonicFctStr', 'harmonicTime', 'maskFctStr', 'domainSize', 'maskVariables', 'fileTemplate');
maskFct = str2func(maskFctStr);
if isempty(harmonicFctStr)
    harmonicFct = [];
else
    harmonicFct = str2func(harmonicFctStr);
end
if harmonicTime < 0
    harmonicFctToUse = @(y,x) - harmonicFct(y,x);
    timeToUse = -harmonicTime;
else
    harmonicFctToUse = harmonicFct;
    timeToUse = harmonicTime;
end
    
[folder, ~, ~] = fileparts(configPath);
%% start iteration

X=repmat((0:domainSize(2)-1) - (domainSize(2)-1)/2, domainSize(1), 1);
Y=repmat(((0:domainSize(1)-1) - (domainSize(1)-1)/2)', 1, domainSize(2));

ticVal = uint64(0);
for s=1:length(maskVariables)
    SFile = fullfile(folder, sprintf(fileTemplate, s));
    if exist(SFile, 'file')
        continue;
    end
    if toc(ticVal) > 5
        callback((s-1)/length(maskVariables));
        ticVal = tic();
    end
    
    try 
        mask = maskFct(Y,X, domainSize(1), domainSize(2), maskVariables(s));
    catch ex
        error('InterPile:InvalidMask', 'Could not calculate mask: %s', ex.message);
    end
    
    
    S = nullPile(domainSize(1), domainSize(2), mask);
    if ~isempty(harmonicFct)
        potential = generateDropZone(harmonicFctToUse, size(S, 1), size(S, 2), mask);

        potentialT = floor(timeToUse.*potential);
        S = relaxPile(S+potentialT); %#ok<NASGU>
    end

    save(SFile, 'S');
end
callback(1);
end

