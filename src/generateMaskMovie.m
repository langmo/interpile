function generateMaskMovie(filePath, domainSize, maskFct, maskVariables, harmonicFct, harmonicTime, movieTime)

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
    maskMovieDialog();
    return;
end

if ~exist('domainSize', 'var') || isempty(domainSize)
    domainSize = [255,255];
end
if numel(domainSize) == 1
    domainSize = [domainSize,domainSize];
end
if ~exist('maskFct', 'var') || isempty(maskFct)
    maskFct = @(y,x,N,M,s)x.^2/((sqrt(2)*M-s)/2).^2+y.^2/((sqrt(2)*N-s)/2).^2<1;
    maskVariables = 0:1:ceil(max(domainSize)*(sqrt(2)-1));
end
if ischar(maskFct)
    maskFctStr = ['@(y,x,N,M,s)', maskFct]; %#ok<NASGU>
else
    maskFctStr = func2str(maskFct); %#ok<NASGU>
end
if ~exist('harmonicTime', 'var') || isempty(harmonicTime)
    harmonicTime = 0;
end
if ~exist('harmonicFct', 'var') || isempty(harmonicFct) || harmonicTime == 0
    harmonicFct = [];
    harmonicTime = 0; %#ok<NASGU>
end
if isempty(harmonicFct)
    harmonicFctStr = []; %#ok<NASGU>
elseif ischar(harmonicFct)
    harmonicFctStr = ['@(y,x)', harmonicFct]; %#ok<NASGU>
else
    harmonicFctStr = func2str(harmonicFct); %#ok<NASGU>
end


if ~exist('movieTime', 'var') || isempty(movieTime)
    movieTime = length(maskVariables)/10;
end
[pathstr,name,~] = fileparts(filePath);
folder = fullfile(pathstr, [name, '_frames']);
configPath = fullfile(folder, 'config.mat');

%% Save configuration settings
emptyFolder = false;
if ~exist(folder, 'dir')
    mkdir(folder);
    emptyFolder = true;
end
if emptyFolder || ~exist(configPath, 'file')
    fileTemplate = 'step%g.mat'; %#ok<NASGU>
    stepsPerRound = length(maskVariables);
    numSteps = stepsPerRound; %#ok<NASGU>
    mode = 'mask'; %#ok<NASGU>
    save(configPath, 'harmonicFctStr', 'harmonicTime', 'maskFctStr', 'domainSize', 'maskVariables', 'fileTemplate', 'stepsPerRound', 'numSteps', 'movieTime', 'mode');
else
    load(configPath, 'harmonicFctStr', 'harmonicTime', 'maskFctStr', 'domainSize', 'maskVariables', 'fileTemplate', 'stepsPerRound', 'numSteps', 'movieTime', 'mode');
end

%% Generate movie
wbh = movieWaitbar(0, 'Preparing movie...');
callback = @(x) movieWaitbarUpdate(wbh, x);
try
    configPath = generateMaskFrames(configPath, callback);

    wbh = movieWaitbar(1, wbh, 'Generating movie...');
    timePerRound = movieTime;
    assembleMovie(filePath, configPath, timePerRound, true, 1, 1, true)
catch ME
    close(wbh);
    switch ME.identifier
        case 'InterPile:UserStop'
            msgH = msgbox({'Movie generation interrupted.','To resume movie generation, select "Continue Movie" in InterPile.'},'Movie generation interrupted','modal');
            try
                setWindowIcon(msgH);
            catch
                % Do nothing, default Matlab icon is OK, too.
            end
            uiwait(msgH);
            return;
        otherwise
            rethrow(ME)
    end
end
close(wbh);
end

function movieWaitbarUpdate(wbh, progress)
    data = wbh.UserData;
    if isempty(data) || ~isstruct(data) || ~isfield(data, 'lastTick') || ~isfield(data, 'lastProgress')
        data = struct();
        movieWaitbar(progress, wbh, sprintf('Generating frames: %2.2f%%', progress*100));
    else
        time = toc(data.lastTick);
        lastProgress = data.lastProgress;
        periodS = round(time / (progress-lastProgress) * (1-progress));
        periodM = mod(floor(periodS/60), 60);
        periodH = floor(periodS/60/60);
        periodS = mod(periodS, 60);
        movieWaitbar(progress, wbh, sprintf('Generating frames: %2.2f%% (%02gh %02gmin %02gs remaining)', progress*100, periodH, periodM, periodS));
    end
    data.lastProgress = progress;
    data.lastTick = tic();
    wbh.UserData = data;
end