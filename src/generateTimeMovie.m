function generateTimeMovie(S, filePath, harmonicFct, numRounds, stepsPerRound, timePerRound, smallMovie, stochMovie)

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
    S = nullPile(64, 64);
end
if nargin < 3
    timeMovieDialog(S);
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

% Either harmonicFct is already the drop zone, or a function corresponding
% to the intended toppling function. If the latter, generate the drop zone.
if isa(harmonicFct, 'function_handle')
    F = generateDropZone(harmonicFct, height, width, ~isinf(S));
else
    F = harmonicFct;
end

%% Generate Movie
wbh = movieWaitbar(0, 'Preparing movie...');
callback = @(x) movieWaitbarUpdate(wbh, x);
try
    if stochMovie
        configPath = generateStochFrames(S, F, folder, numRounds, stepsPerRound, callback);
    else
        configPath = generateDetFrames(S, F, folder, numRounds, stepsPerRound, callback);
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