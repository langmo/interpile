function [A, nA, varargout] = avalancheDistributionStoch(S, F, numRounds, callback)
% S... sandpile to start from
% F...dropzone
% A...avalanche sizes (A=0: numel(S))
% nA...number of avalanches of given size

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