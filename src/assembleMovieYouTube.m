function assembleMovieYouTube( filePath, configPath, timePerRound, deltaT)

if nargin <2 || isempty(configPath)
    [filename, pathname, ~] = uigetfile({'config.mat'}, 'Select movie configuration file', fullfile(cd(), 'config.mat'));
    if isempty(filename) || (isnumeric(filename) && numel(filename) == 1 && filename == 0)
        return;
    end
    configFile = fullfile(pathname, filename);
end
if nargin <1 || isempty(filePath)
    [pathName,~,~] = fileparts(configFile);
    [pathName,fileName,~] = fileparts(pathName);
    fileName = [fileName(1:strfind(fileName, '_frames')-1), '_youtube.avi'];
    
    [fileName,pathName] = uiputfile(fullfile(pathName,fileName), 'Save Movie');
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

assembleMovie(filePath, configFile, timePerRound, false, 4, deltaT)


end

