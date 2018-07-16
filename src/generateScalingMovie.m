function generateScalingMovie(filePath, domainSizes, harmonicFct, referenceSize, referenceTime, scalingLaw, movieTime)

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

if nargin < 2
    scalingMovieDialog();
    return;
end
if ~exist('movieTime', 'var') || isempty(movieTime)
    movieTime = length(domainSizes)/10;
end
if min(size(domainSizes))==1 
    if size(domainSizes, 2) > 1
        domainSizes = domainSizes';
    end
    domainSizes = repmat(domainSizes, 1, 2);
end
if ~exist('referenceSize', 'var') || isempty(referenceSize)
    referenceSize = domainSizes(1, :);
end
if ~exist('referenceTime', 'var') || isempty(referenceTime)
    referenceTime = 0;
end
if ~exist('scalingLaw', 'var') || isempty(scalingLaw)
    scalingLaw = 0;
end
if numel(referenceSize)==1 
    referenceSize = [referenceSize, referenceSize];
end
if ~exist('harmonicFct', 'var') || isempty(harmonicFct) || referenceTime == 0
    harmonicFct = [];
    referenceTime = 0;
end

domainTimes = referenceTime * arrayfun(@(i)(referenceSize(1)/domainSizes(i, 1))^scalingLaw, (1:size(domainSizes, 1))');

[pathstr,name,~] = fileparts(filePath);
folder = fullfile(pathstr, [name, '_frames']);
configPath = fullfile(folder, 'config.mat');

%% generate frames
wbh = waitbar(0, 'Preparing movie...');
callback = @(x) movieWaitbar(wbh, x);

emptyFolder = false;
if ~exist(folder, 'dir')
    mkdir(folder);
    emptyFolder = true;
end
if emptyFolder || ~exist(configPath, 'file')
    fileTemplate = 'step%g.mat';
    stepsPerRound = length(domainSizes);
    numSteps = stepsPerRound; %#ok<NASGU>
    mode = 'scaling'; %#ok<NASGU>
    harmonicFctStr = func2str(harmonicFct); %#ok<NASGU>
    save(configPath, 'harmonicFctStr', 'domainSizes', 'domainTimes', 'fileTemplate', 'stepsPerRound', 'numSteps', 'referenceSize', 'referenceTime', 'scalingLaw', 'movieTime', 'mode');
else
    harmonicFctStr = []; % pre-define to avoid error.
    load(configPath, 'harmonicFctStr', 'domainSizes', 'domainTimes', 'fileTemplate', 'stepsPerRound', 'numSteps', 'referenceSize', 'referenceTime', 'scalingLaw');
    mode = 'scaling'; %#ok<NASGU>
    harmonicFct = str2func(harmonicFctStr);
    save(configPath, 'harmonicFctStr', 'domainSizes', 'domainTimes', 'fileTemplate', 'stepsPerRound', 'numSteps', 'referenceSize', 'referenceTime', 'scalingLaw', 'movieTime', 'mode');
end

ticVal = uint64(0);
for s=1:size(domainSizes, 1)
    if toc(ticVal) > 5
        callback((s-1)/(size(domainSizes, 1)));
        ticVal = tic();
    end
    
    SFile = fullfile(folder, sprintf(fileTemplate, s));
    if ~emptyFolder && exist(SFile, 'file')
        continue;
    end
    S = nullPile(domainSizes(s, 1), domainSizes(s, 2));
    
    if ~isempty(harmonicFct)
        X = generateDropZone(harmonicFct, size(S, 1), size(S, 2));
        
        Xt = floor(domainTimes(s).*X);
        S = relaxPile(S+Xt); %#ok<NASGU>
    end
    
    
    save(SFile, 'S');
end
callback(1);


%% Generate movie
wbh = waitbar(0.9, wbh, 'Generating movie...');
timePerRound = movieTime;
assembleMovie(filePath, configPath, timePerRound, false, 1, 1, false)
close(wbh)

end

function movieWaitbar(wbh, progress)
    data = wbh.UserData;
    if isempty(data) || ~isstruct(data) || ~isfield(data, 'lastTick') || ~isfield(data, 'lastProgress')
        data = struct();
        waitbar(0.05+progress*0.85, wbh, sprintf('Generating frames: %2.2f%%', progress*100));
    else
        time = toc(data.lastTick);
        lastProgress = data.lastProgress;
        periodS = round(time / (progress-lastProgress) * (1-progress));
        periodM = mod(floor(periodS/60), 60);
        periodH = floor(periodS/60/60);
        periodS = mod(periodS, 60);
        waitbar(0.05+progress*0.85, wbh, sprintf('Generating frames: %2.2f%% (%02gh %02gmin %02gs remaining)', progress*100, periodH, periodM, periodS));
    end
    data.lastProgress = progress;
    data.lastTick = tic();
    wbh.UserData = data;
end