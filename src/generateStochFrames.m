function configPath = generateStochFrames(S, excitation, folder, numRounds, stepsPerRound, callback)
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
        load(configPath, 'S', 'excitation', 'stepsPerRound', 'fileTemplate', 'numSteps');
    else
        load(configPath, 'S', 'excitation', 'stepsPerRound', 'fileTemplate', 'numSteps', 'numRounds');
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
end

% For the stochastic approach, we do not have to distinguish from where we
% drop particles...
if isstruct(excitation)
    excitation = excitation.Xt + excitation.Xb + excitation.Xl + excitation.Xr;
end

%% start iteration
if sum(sum(excitation))<=1e8
    distri = toDistribution(excitation);
    distriN = size(distri, 1);
    directMethod = true;
else
    [distri, distriN] = toDistributionReal(excitation);
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
mode = 'stoch'; %#ok<NASGU>
if emptyFolder || ~exist(configPath, 'file')
    save(configPath, 'S', 'excitation', 'stepsPerRound', 'fileTemplate', 'numSteps', 'numRounds', 'mode');
else
    numRoundsTemp = numRounds;
    load(configPath, 'S', 'excitation', 'stepsPerRound', 'fileTemplate', 'numSteps', 'numRounds');
    numRounds = max(numRoundsTemp, numRounds);
    numSteps = ceil(numRounds*stepsPerRound);
    save(configPath, 'S', 'excitation', 'stepsPerRound', 'fileTemplate', 'numSteps', 'numRounds', 'mode');
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
                %r = rand();
                %idx = find(ps>=r, 1);
                idx = find_halfspace(ps, rand());
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

function X = find_halfspace(Y,T)
    % returns the index of the first element in the ascending array Y which
    % is greater or equal to T, i.e. a value of X s.t. Y(X)>=T, Y(X-1)<T
    % in the ASCENDING array data that is
    % <x using a simple half space search
    L = 1;
    R = length(Y);
    while L < R
        M = floor((L + R)/2);
        if T < Y(M)
            R = M;
        elseif T > Y(M)
            L = M + 1;
        else
            X = M;
            return;
        end
    end
    X = L;
end