function continueMovie(configPath, filePath, numRounds, timePerRound, smallMovie)

if nargin() < 1
    [filename, pathname, ~] = uigetfile({'config.mat'}, 'Select movie configuration file', fullfile(cd(), 'config.mat'));
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
         error('InterPile:NotYetImplemented', 'Continuation of domain scaling movies currently not possible.');
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

% Continue movie
wbh = waitbar(0, 'Continuing movie...');
callback = @(x) movieWaitbar(wbh, x);

if stochMovie
    configPath = generateStochFrames(configPath, [], [], numRounds, [], callback);
else
    configPath = generateDetFrames(configPath, [], [], numRounds, [], callback);
end


%% Generate movie
wbh = waitbar(0.9, wbh, 'Generating movie...');
assembleMovie(filePath, configPath, timePerRound, smallMovie)
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