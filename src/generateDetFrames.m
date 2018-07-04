function configPath = generateDetFrames(S, F, folder, numRounds, stepsPerRound, callback)
% S... sandpile to start from
% F...dropzone
if ~exist('callback', 'var') || isempty(callback)
    callback = @(x)1;
end
if ischar(S)
    % Continue frame generation.
    configPath = S;
    clear S;
   
    if exist('numRounds', 'var') && ~isempty(numRounds)
        load(configPath, 'S', 'F', 'stepsPerRound', 'fileTemplate', 'numSteps');
    else
        load(configPath, 'S', 'F', 'stepsPerRound', 'fileTemplate', 'numSteps', 'numRounds');
    end
    if ~exist('folder', 'var') || isempty(folder)
        [folder, ~, ~] = fileparts(configPath);
    end
else
    if ~exist('stepsPerRound', 'var') || isempty(stepsPerRound)
        stepsPerRound = 600;
    end
    if ~exist('numRounds', 'var') || isempty(numRounds)
        numRounds = 1;
    end
    
    fileTemplate = 'step%g.mat';
    configPath = fullfile(folder, 'config.mat');
    numSteps = ceil(numRounds*stepsPerRound);
end
    
%% The number of elements we have already dropped in the last rounds
D = zeros(size(S));

%% start iteration
emptyFolder = false;
if ~exist(folder, 'dir')
    mkdir(folder);
    emptyFolder = true;
end
mode = 'det'; %#ok<NASGU>
if emptyFolder || ~exist(configPath, 'file')
    save(configPath, 'S', 'F', 'stepsPerRound', 'fileTemplate', 'numSteps', 'numRounds', 'mode');
else
    numRoundsTemp = numRounds;
    load(configPath, 'S', 'F', 'stepsPerRound', 'fileTemplate', 'numSteps', 'numRounds');
    numRounds = max(numRoundsTemp, numRounds);
    numSteps = ceil(numRounds*stepsPerRound);
    save(configPath, 'S', 'F', 'stepsPerRound', 'fileTemplate', 'numSteps', 'numRounds', 'mode');
end

SFile = fullfile(folder, sprintf(fileTemplate, 0));
if emptyFolder || ~exist(SFile, 'file')
    save(SFile, 'S');
end

ticVal = uint64(0);
for s=1:numSteps
    if toc(ticVal) > 5
        callback((s-1)/(numSteps));
        ticVal = tic();
    end
    
    n = s/stepsPerRound;

    Dnew = floor(n.*F);

    X = Dnew - D;
    D = Dnew;

    SFile = fullfile(folder, sprintf(fileTemplate, s));
    if emptyFolder || ~exist(SFile, 'file')
        S = relaxPile(S+X);
        save(SFile, 'S');
    else
        load(SFile, 'S');
    end
end
callback(1);
end

