function generateMovie(S, filePath, excitation, numRounds, stepsPerRound, timePerRound, smallMovie, stochMovie)

if nargin < 1
    S = nullPile(64, 64);
end

if nargin < 3
    detMovieDialog(S);
    return;
end

height = size(S, 1);
width = size(S, 2);

if ~exist('excitation', 'var') || isempty(excitation)
    excitation = @(y,x) x.*(x.^2-3.*y.^2);
end

if ~exist('stepsPerRound', 'var') || isempty(stepsPerRound)
    stepsPerRound = 60;
end

if ~exist('filePath', 'var') || isempty(filePath)
    filePath = fullfile(cd(), sprintf('harmonicDet_%gx%g_%s.avi', height, width, datestr(now,'yyyy-MM-dd_HH-mm-ss')));
end

if ~exist('numRounds', 'var') || isempty(numRounds)
    numRounds = 1;
end

if ~exist('timePerRound', 'var') || isempty(timePerRound)
    timePerRound = 6;
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
% Either dropZone is already the drop zone, or a function corresponding
% to the intended toppling function. If the latter, generate the drop zone.
if isa(excitation, 'function_handle')
    excitation = computeExcitation(excitation, height, width);
end

%% generate frames
callback = @(x) waitbar(0.05+x*0.85, wbh, 'Generating frames...');
if stochMovie
    configPath = generateStochFrames(S, excitation, folder, numRounds, stepsPerRound, callback);
else
    configPath = generateDeterministicFrames(S, excitation, folder, numRounds, stepsPerRound, callback);
end


%% Generate movie
wbh = waitbar(0.9, wbh, 'Generating movie...');
assembleMovie(filePath, configPath, timePerRound, smallMovie)
close(wbh)

end

