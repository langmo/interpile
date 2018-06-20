function dropZones = dropZones()

harmonicZones = harmonicDropZones();

if ~isdeployed()
    dirName = 'drop_zones';
else
    dirName = fullfile(ctfroot(), 'drop_zones');
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
    dropZones{i} = struct('name', name, 'dropZone', @()loadDropZone(dropZonePath));
end

for i=1:length(harmonicZones)
    dropZones{i+length(dropZoneFiles)} = struct('name', harmonicZones{i}{1}, 'dropZone', @()harmonicZones{i}{2}(128,128));
end

end

function S = loadDropZone(path) %#ok<STOUT>
load(path, 'S');
end