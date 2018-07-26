function continueMaskMovie(configPath, filePath)

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

oldWarn = warning('off','MATLAB:load:variableNotFound');
load(configPath, 'mode', 'movieTime')
warning(oldWarn);
if ~exist('mode', 'var') || ~strcmpi(mode, 'mask');
    error('InterPile:WrongFunction', 'Movie is not a domain scaling/mask movie. Use continueMovie instead.');
end

%% Continue movie
wbh = movieWaitbar(0, 'Preparing movie...');
callback = @(x) movieWaitbarUpdate(wbh, x);
try
    configPath = generateMaskFrames(configPath, callback);

    wbh = movieWaitbar(1, wbh, 'Generating movie...');
    assembleMovie(filePath, configPath, movieTime, true, 1, 1, true)
catch ME
    switch ME.identifier
        case 'InterPile:UserStop'
            close(wbh);
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