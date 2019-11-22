function convertMovieToNonRecurrent( destFile, orgConfigFile)

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

if nargin <2 || isempty(orgConfigFile)
    [filename, pathname, ~] = uigetfile({'config.mat'}, 'Select movie configuration file', fullfile(cd(), 'config.mat'));
    if isempty(filename) || (isnumeric(filename) && numel(filename) == 1 && filename == 0)
        return;
    end
    orgConfigFile = fullfile(pathname, filename);
end
[orgPath,~,~] = fileparts(orgConfigFile);
if nargin <1 || isempty(destFile)
    [destPathName,orgFolderName,~] = fileparts(orgPath);
    destFileName = [orgFolderName(1:strfind(orgFolderName, '_frames')-1), '_nonRecurrent.avi'];
    
    [destFileName, destPathName] = uiputfile(fullfile(destPathName, destFileName), 'Save Movie');
    if isempty(destFileName) || (isnumeric(destFileName) && numel(destFileName) == 1 && destFileName == 0)
        return;
    end
    destFile = fullfile(destPathName, destFileName);
end
[destPathName,destFileName,~] = fileparts(destFile);
destPath = fullfile(destPathName, [destFileName,'_frames']);

[~, configFileName, configFileExt] = fileparts(orgConfigFile);
destConfigFile = fullfile(destPath, [configFileName, configFileExt]);

%% Create folder
mkdir(destPath);
copyfile(orgConfigFile, destConfigFile);

fileList = dir(fullfile(orgPath, 'step*.mat'));

S=0;
wbh = waitbar(0, 'Converting files...');
for i=1:length(fileList)
    wbh = waitbar((i-1)/length(fileList), wbh, sprintf('Converting file %g of %g ...', i, length(fileList)));
    
    fileName = fileList(i).name;
    load(fullfile(orgPath, fileName), 'S');
    S = toNonRecurrent(S);
    save(fullfile(destPath, fileName), 'S');
end
close(wbh);
end

