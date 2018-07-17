function configPath = generateScalingFrames(configPath, callback)

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

if ~exist('callback', 'var') || isempty(callback)
    callback = @(x)1;
end
load(configPath, 'harmonicFctStr', 'domainSizes', 'domainTimes', 'fileTemplate');
if isempty(harmonicFctStr)
    harmonicFct = [];
else
    harmonicFct = str2func(harmonicFctStr);
end
    
[folder, ~, ~] = fileparts(configPath);
%% start iteration
ticVal = uint64(0);
for s=1:size(domainSizes, 1)
    SFile = fullfile(folder, sprintf(fileTemplate, s));
    if exist(SFile, 'file')
        continue;
    end
    if toc(ticVal) > 5
        callback((s-1)/(size(domainSizes, 1)));
        ticVal = tic();
    end
    S = nullPile(domainSizes(s, 1), domainSizes(s, 2));

    if ~isempty(harmonicFct)
        X = generateDropZone(harmonicFct, size(S, 1), size(S, 2));

        Xt = floor(domainTimes(s).*X);
        S = relaxPile(S+Xt); %#ok<NASGU>
    end

    save(SFile, 'S');
end
callback(1);
end

