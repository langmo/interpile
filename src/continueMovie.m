function continueMovie(configPath, filePath)

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

if nargin() < 1
    [filename, pathname, ~] = uigetfile({'config.mat', 'InterPile Movies (*.mat)'}, 'Select movie configuration file', fullfile(cd(), 'config.mat'));
    if isempty(filename) || (isnumeric(filename) && numel(filename) == 1 && filename == 0)
        return;
    end
    configPath = fullfile(pathname, filename);
end

if ~exist('filePath', 'var') || isempty(filePath)
    [folder, ~, ~] = fileparts(configPath);
    [folder, baseName, ext] = fileparts(folder);
    baseName = [baseName, ext];
    idx = strfind(baseName, '_frames');
    if ~isempty(idx)
        baseName = baseName(1:idx(end)-1);
    end
    filePath = fullfile(folder, [baseName, '.avi']);
end

oldWarn = warning('off','MATLAB:load:variableNotFound');
load(configPath, 'mode')
warning(oldWarn);
if exist('mode', 'var') && strcmpi(mode, 'scaling')
    continueScalingMovie(configPath, filePath);
else
    continueTimeMovie(configPath, filePath);
end