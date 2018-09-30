function nStates = numStatesInHarmonic(harmonic, N, M, mask)

if ~exist('N', 'var') || isempty(N)
    N = 128;
end
if ~exist('M', 'var') || isempty(M)
    M = N;
end
if ~exist('mask', 'var') || isempty(mask)
    mask = ones(N, M);
end

X = generateDropZone(harmonic, N, M, mask, false, false);
drops = setdiff(unique(X), 0);

times = cell(1, length(drops));
for i=1:length(drops)
    drop = drops(i);
    if drop < 0
        times{i} = 0:-1/drop:1+1/drop;
    else
        times{i} = 1/drop:1/drop:1;
    end
end
times = unique(cell2mat(times));
nStates = length(times);

end

