function dropZones = potentials()

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

harmonicZones = defaultPotentials();

if ~isdeployed()
    dirName = 'custom_potentials';
else
    dirName = fullfile(ctfroot(), 'custom_potentials');
end
if ~exist(dirName, 'dir')
    dropZoneFiles = struct([]);
else
    dropZoneFiles = dir(fullfile(dirName, '*.mat'));
end


dropZones = cell(1, length(dropZoneFiles)+length(harmonicZones));
for i=1:length(dropZoneFiles)
    [~, name, ~] = fileparts(dropZoneFiles(i).name);
    dropZonePath = fullfile(dirName, dropZoneFiles(i).name);
    dropZones{i} = struct('name', name, 'potential', @(height, width)loadDropZone(dropZonePath));
end

for i=1:length(harmonicZones)
    dropZones{i+length(dropZoneFiles)} = struct('name', harmonicZones{i}{1}, 'potential', harmonicZones{i}{2});
end

end

function S = loadDropZone(path) %#ok<STOUT>
load(path, 'S');
end