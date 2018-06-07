function configPath = generateDetFrames(S, F, folder, numRounds, stepsPerRound, callback)
% S... sandpile to start from
% F...dropzone
if ~exist('stepsPerRound', 'var') || isempty(stepsPerRound)
    stepsPerRound = 60;
end
if ~exist('numRounds', 'var') || isempty(numRounds)
    numRounds = 1;
end
if ~exist('callback', 'var') || isempty(callback)
    callback = @(x)1;
end
fileTemplate = 'step%g.mat';
configPath = fullfile(folder, 'config.mat');

    
%% The number of elements we have already dropped in the last rounds
D = zeros(size(S));

%% start iteration
numSteps = ceil(numRounds*stepsPerRound);

emptyFolder = false;
if ~exist(folder, 'dir')
    mkdir(folder);
    emptyFolder = true;
end
if emptyFolder || ~exist(configPath, 'file')
    save(configPath, 'S', 'F', 'stepsPerRound', 'fileTemplate', 'numSteps', 'numRounds', 'folder');
else
    load(configPath);
end

SFile = fullfile(folder, sprintf(fileTemplate, 0));
if emptyFolder || ~exist(SFile, 'file')
    save(SFile, 'S');
end
for s=1:numSteps
    callback((s-1)/(numSteps));
    
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

