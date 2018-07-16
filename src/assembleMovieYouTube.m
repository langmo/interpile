function assembleMovieYouTube( filePath, configFile, timePerRound, deltaT, showTime)

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

if nargin <2 || isempty(configFile)
    [filename, pathname, ~] = uigetfile({'config.mat'}, 'Select movie configuration file', fullfile(cd(), 'config.mat'));
    if isempty(filename) || (isnumeric(filename) && numel(filename) == 1 && filename == 0)
        return;
    end
    configFile = fullfile(pathname, filename);
end
if ~exist('showTime', 'var') || isempty(showTime)
    showTime = true;
end
if nargin <1 || isempty(filePath)
    [pathName,~,~] = fileparts(configFile);
    [pathName,fileName,ext] = fileparts(pathName);
    fileName = [fileName,ext];
    fileName = [fileName(1:strfind(fileName, '_frames')-1), '_youtube.avi'];
    
    [fileName,pathName] = uiputfile(fullfile(pathName,fileName), 'Save Movie');
    if isempty(fileName) || (isnumeric(fileName) && numel(fileName) == 1 && fileName == 0)
        return;
    end
    filePath = fullfile(pathName, fileName);
end

if nargin <4 || isempty(deltaT)
    load(configFile, 'numSteps');
    deltaT = max(round(numSteps/600), 1);
end

if nargin <3 || isempty(timePerRound)
    load(configFile, 'numSteps');
    timePerRound = 200/600*round(numSteps/deltaT);
end

assembleMovie(filePath, configFile, timePerRound, false, 4, deltaT, showTime)


end

