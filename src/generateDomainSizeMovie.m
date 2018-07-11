function generateDomainSizeMovie(filePath, domainSizes, harmonicFct, timeFct, movieTime)
if ~exist('domainSizes', 'var') || isempty(domainSizes)
    domainSizes = 1:2:127;
end
if ~exist('filePath', 'var') || isempty(filePath)
    filePath = fullfile(cd(), sprintf('domainResizing_%gx%g_to_%gx%g_%s.avi', domainSizes(1), domainSizes(1), domainSizes(end),domainSizes(end)));
end

if ~exist('harmonicFct', 'var')
    harmonicFct = [];
end
if ~exist('timeFct', 'var')
    timeFct = @(N,M)0;
end
if ~isa(timeFct, 'function_handle')
    fixedTime = timeFct;
    timeFct = @(N,M)fixedTime;
end

if ~exist('movieTime', 'var') || isempty(movieTime)
    movieTime = length(domainSizes)/10;
end

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
    numSteps = stepsPerRound;
    save(configPath, 'domainSizes', 'fileTemplate', 'stepsPerRound', 'numSteps');
else
    domainSizesTemp = domainSizes;
    load(configPath, 'domainSizes', 'fileTemplate', 'stepsPerRound', 'numSteps');
    
    if isempty(setdiff(domainSizes,domainSizesTemp))
        domainSizes = domainSizesTemp;
        stepsPerRound = length(domainSizes);
        numSteps = stepsPerRound;
    end
    clear domainSizesTemp;
    save(configPath, 'domainSizes', 'fileTemplate', 'stepsPerRound', 'numSteps');
end

ticVal = uint64(0);
for s=1:length(domainSizes)
    if toc(ticVal) > 5
        callback((s-1)/(length(domainSizes)));
        ticVal = tic();
    end
    
    
    SFile = fullfile(folder, sprintf(fileTemplate, s));
    if ~emptyFolder && exist(SFile, 'file')
        continue;
    end
    S = nullPile(domainSizes(s));
    
    if ~isempty(harmonicFct)
        X = generateDropZone(harmonicFct, size(S, 1), size(S, 2));
        
        Xt = floor(timeFct(size(S, 1), size(S, 2)).*X);
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