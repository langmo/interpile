function [A, nA, varargout] = avalancheDistributionStoch(S, F, numRounds, callback)
% S... sandpile to start from
% F...dropzone
% A...avalanche sizes (A=0: numel(S))
% nA...number of avalanches of given size

if ~exist('numRounds', 'var') || isempty(numRounds)
    numRounds = 1;
end
if ~exist('callback', 'var') || isempty(callback)
    callback = @(x)1;
end

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

numSteps = ceil(numRounds*distriN);

% Check: Avalanche max size = dimension of system?
A = 0:numel(S);
nA = zeros(size(A));

ticVal = uint64(0);
if directMethod
    for s=1:numSteps
        if toc(ticVal) > 5
            callback((s-1)/(numSteps));
            ticVal = tic();
        end
        
        idx = randi(distriN);
        S(ys(idx), xs(idx)) = S(ys(idx), xs(idx)) + 1;

        [S,H] = relaxPile(S);
        Ai = sum(sum(H))+1;
        nA(Ai) = nA(Ai)+1;
    end
else
    for s=1:numSteps
        if toc(ticVal) > 5
            callback((s-1)/(numSteps));
            ticVal = tic();
        end
        
        r = rand();
        idx = find(ps>=r, 1);
        S(ys(idx), xs(idx)) = S(ys(idx), xs(idx)) + 1;

        [S,H] = relaxPile(S);
        Ai = sum(sum(H))+1;
        nA(Ai) = nA(Ai)+1;
    end
end
callback(1);

if nargout > 2
    varargout{1} = S;
end
end