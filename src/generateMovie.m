function generateMovie(S, filePath, harmonicFct, numRounds, stepsPerRound, timePerRound, smallMovie, stochMovie)

if nargin < 1
    S = nullPile(64, 64);
end
if nargin < 3
    detMovieDialog(S);
    return;
end

height = size(S, 1);
width = size(S, 2);

if ~exist('harmonicFct', 'var') || isempty(harmonicFct)
    harmonicFct = @(y,x) x.*(x.^2-3.*y.^2);
end

if ~exist('stepsPerRound', 'var') || isempty(stepsPerRound)
    stepsPerRound = 600;
end

if ~exist('filePath', 'var') || isempty(filePath)
    filePath = fullfile(cd(), sprintf('harmonicDet_%gx%g_%s.avi', height, width, datestr(now,'yyyy-MM-dd_HH-mm-ss')));
end

if ~exist('numRounds', 'var') || isempty(numRounds)
    numRounds = 1;
end

if ~exist('timePerRound', 'var') || isempty(timePerRound)
    timePerRound = 60;
end
if ~exist('smallMovie', 'var') || isempty(smallMovie)
    smallMovie = true;
end
if ~exist('stochMovie', 'var') || isempty(stochMovie)
    stochMovie = false;
end



[pathstr,name,~] = fileparts(filePath);
folder = fullfile(pathstr, [name, '_frames']);

wbh = waitbar(0, 'Preparing movie...');
% Either harmonicFct is already the drop zone, or a function corresponding
% to the intended toppling function. If the latter, generate the drop zone.
if isa(harmonicFct, 'function_handle')
    F = generateDropZone(harmonicFct, height, width, ~isinf(S));
else
    F = harmonicFct;
end

%% generate frames
callback = @(x) movieWaitbar(wbh, x);
if stochMovie
    configPath = generateStochFrames(S, F, folder, numRounds, stepsPerRound, callback);
else
    configPath = generateDetFrames(S, F, folder, numRounds, stepsPerRound, callback);
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