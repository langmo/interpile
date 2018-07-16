function configPath = generateDeterministicFrames(S, excitation, folder, numRounds, stepsPerRound, callback)
% S... sandpile to start from
% F...dropzone

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

