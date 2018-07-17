function continueTimeMovie(configPath, filePath, numRounds, timePerRound, smallMovie)

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

if nargin() < 1
    [filename, pathname, ~] = uigetfile({'config.mat', 'InterPile Movies (*.mat)'}, 'Select movie configuration file', fullfile(cd(), 'config.mat'));
    if isempty(filename) || (isnumeric(filename) && numel(filename) == 1 && filename == 0)
        return;
    end
    configPath = fullfile(pathname, filename);
end

if ~exist('filePath', 'var') || isempty(filePath)
    [folder, ~, ~] = fileparts(configPath);
    [folder, baseName, ext] = fileparts(folder);
    baseName = [baseName, ext];
    idx = strfind(baseName, '_frames');
    if ~isempty(idx)
        baseName = baseName(1:idx(end)-1);
    end
    filePath = fullfile(folder, [baseName, '.avi']);
end
if ~exist('numRounds', 'var') || isempty(numRounds)
    numRounds = [];
end

if ~exist('timePerRound', 'var') || isempty(timePerRound)
    timePerRound = 60;
end
if ~exist('smallMovie', 'var') || isempty(smallMovie)
    smallMovie = true;
end

oldWarn = warning('off','MATLAB:load:variableNotFound');
load(configPath, 'mode')
warning(oldWarn);
if exist('mode', 'var')
    if strcmpi(mode, 'scaling');
         error('InterPile:WrongFunction', 'Movie is a domain scaling movie. Use continueScalingMovie instead.');
    elseif strcmpi(mode, 'det');
        stochMovie = false;
    elseif strcmpi(mode, 'stoch');
        stochMovie = true;
    else
        error('InterPile:UnknownMovieType', 'Movie type %s is unknown', mode);
    end
else
    % Compatibility mode for old movies not saving what kind of movie they
    % are. Simply assume deterministic except if variable excitation is there...
    oldWarn = warning('off','MATLAB:load:variableNotFound');
    load(configPath, 'excitation')
    warning(oldWarn);
    if exist('excitation', 'var')
        stochMovie = false;
    else
        stochMovie = false;
    end
end

%% Continue movie
wbh = movieWaitbar(0, 'Preparing movie...');
callback = @(x) movieWaitbarUpdate(wbh, x);
try
    if stochMovie
        configPath = generateStochFrames(configPath, [], [], numRounds, [], callback);
    else
        configPath = generateDetFrames(configPath, [], [], numRounds, [], callback);
    end

    wbh = movieWaitbar(1, wbh, 'Generating movie...');
    assembleMovie(filePath, configPath, timePerRound, smallMovie)
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