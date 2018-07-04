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
    [folder, baseName, ~] = fileparts(folder);
    filePath = fullfile(folder, [baseName(1:strfind(baseName, '_frames')), '.avi']);
    smallMovie = true;
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
    if strcmpi(mode, 'det');
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
callback = @(x) waitbar(0.05+x*0.85, wbh, sprintf('Generating frames: %g%%', x*100));

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

