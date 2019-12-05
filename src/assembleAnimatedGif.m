function assembleAnimatedGif(filePath, configPath, numFrames, timePerRound, scaling, pileColorMap)

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

if nargin <2 || isempty(configPath)
    [filename, pathname, ~] = uigetfile({'config.mat'}, 'Select movie configuration file', fullfile(cd(), 'config.mat'));
    if isempty(filename) || (isnumeric(filename) && numel(filename) == 1 && filename == 0)
        return;
    end
    configPath = fullfile(pathname, filename);
end
if nargin <1 || isempty(filePath)
    [pathName,~,~] = fileparts(configPath);
    [pathName,fileName,ext] = fileparts(pathName);
    fileName = [fileName,ext];
    fileName = [fileName(1:strfind(fileName, '_frames')-1), '.gif'];
    
    [fileName,pathName] = uiputfile(fullfile(pathName,fileName), 'Save Movie');
    if isempty(fileName) || (isnumeric(fileName) && numel(fileName) == 1 && fileName == 0)
        return;
    end
    filePath = fullfile(pathName, fileName);
end
if ~exist('numFrames', 'var') || isempty(numFrames)
    numFrames = 60;
end
if ~exist('timePerRound', 'var') || isempty(timePerRound)
    timePerRound = 10;
end
if ~exist('scaling', 'var') || isempty(scaling)
    scaling = 1;
end
if ~exist('pileColorMap', 'var') || isempty(pileColorMap)
    pileColorMap = [];
end

%% Load config
load(configPath);

[folder, ~, ~] = fileparts(configPath);
deltaFrames = round(numSteps/numFrames);
%% Generate movie

colors = pileColors(pileColorMap);
colors = colors(1:4, :);
frameRate = timePerRound/numFrames;

imgId=0;
if ~exist(fullfile(folder, sprintf(fileTemplate, 0)), 'file')
    imgId=1;
end
firstRound = true;
wbh = waitbar(0, 'Generating gif...');
stepNum = 0;
while true
    stepNum = stepNum +1;
    wbh = waitbar((stepNum-1)/numFrames, wbh, sprintf('Generating gif (Frame %g of %g)...', stepNum, numFrames));
    imgPath = fullfile(folder, sprintf(fileTemplate, imgId));
    if ~exist(imgPath, 'file')
        break;
    end
    load(imgPath, 'S');
    imgColors = colors;
    
    if numel(scaling)==1
        if scaling ~= 1
            S = repelem(S, scaling, scaling)+1;
        end
    else
        if size(S,1) <= scaling(1)/2
            [S, imgColors] = imresize(S+1, imgColors, scaling, 'nearest');
        else
            [S, imgColors] = imresize(S+1, imgColors, scaling, 'bilinear');
        end
    end
    if firstRound
        imwrite(S,imgColors,filePath,'gif', 'Loopcount',inf, 'DelayTime', frameRate); 
        firstRound = false;
    else
        imwrite(S,imgColors,filePath,'gif','WriteMode','append'); 
    end
    
    imgId = imgId+deltaFrames;
end
close(wbh);
end

