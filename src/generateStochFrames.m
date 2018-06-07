function configPath = generateStochFrames(S, F, folder, numRounds, stepsPerRound, callback)
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

%% start iteration
if sum(sum(F))<=1e8
    distri = toDistribution(F);
    distriN = size(distri, 1);
    directMethod = true;
else
    [distri, distriN] = toDistributionReal(F);
    ps = distri(:, 3);
    directMethod = false;
end
xs = distri(:, 2);
ys = distri(:, 1);

coinsPerStep = round(distriN/stepsPerRound);
stepsPerRound = distriN / coinsPerStep;
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

ticVal = uint64(0);
for s=1:numSteps
    if toc(ticVal) > 5
        callback((s-1)/(numSteps));
        ticVal = tic();
    end

    SFile = fullfile(folder, sprintf(fileTemplate, s));
    if emptyFolder || ~exist(SFile, 'file')
        if directMethod
            for k=1:coinsPerStep
                idx = randi(distriN);
                S(ys(idx), xs(idx)) = S(ys(idx), xs(idx)) + 1;
            end
        else
            for k=1:coinsPerStep
                r = rand();
                idx = find(ps>=r, 1);
                S(ys(idx), xs(idx)) = S(ys(idx), xs(idx)) + 1;
            end
        end
        S = relaxPile(S);
        save(SFile, 'S');
    else
        load(SFile, 'S');
    end
end
callback(1);
end