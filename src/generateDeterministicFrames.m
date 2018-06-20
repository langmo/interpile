function configPath = generateDeterministicFrames(S, excitation, folder, numRounds, stepsPerRound, callback)
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
Xl_t = zeros(size(S));
Xt_t = zeros(size(S));
Xr_t = zeros(size(S));
Xb_t = zeros(size(S));

%% start iteration
numSteps = ceil(numRounds*stepsPerRound);

emptyFolder = false;
if ~exist(folder, 'dir')
    mkdir(folder);
    emptyFolder = true;
end
if emptyFolder || ~exist(configPath, 'file')
    save(configPath, 'S', 'excitation', 'stepsPerRound', 'fileTemplate', 'numSteps', 'numRounds', 'folder');
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
    
    t = s/stepsPerRound;

    Xl_tp = floor(t.*excitation.Xl);
    dXl = Xl_tp - Xl_t;
    Xl_t = Xl_tp;

    Xr_tp = floor(t.*excitation.Xr);
    dXr = Xr_tp - Xr_t;
    Xr_t = Xr_tp;
    
    Xt_tp = floor(t.*excitation.Xt);
    dXt = Xt_tp - Xt_t;
    Xt_t = Xt_tp;
    
    Xb_tp = floor(t.*excitation.Xb);
    dXb = Xb_tp - Xb_t;
    Xb_t = Xb_tp;
    
    SFile = fullfile(folder, sprintf(fileTemplate, s));
    if emptyFolder || ~exist(SFile, 'file')
        S = relaxPile(S+dXl+dXr+dXt+dXb);
        save(SFile, 'S');
    else
        load(SFile, 'S');
    end
end
callback(1);
end

