function assembleMovie(filePath, configPath, timePerRound, smallMovie, scaling, deltaFrames, showText)

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

mode = []; % forward declaration to circumvent error in Matlab.

load(configPath);
[~,~,ext] = fileparts(filePath);
[folder, ~, ~] = fileparts(configPath);
%% Generate movie
if ~exist('deltaFrames', 'var') || isempty(deltaFrames)
    deltaFrames = 1;
end
if ~exist('showTime', 'var') || isempty(showText)
    showText = true;
end
colors = pileColors();
colors = colors(1:4, :);
frameRate = stepsPerRound/timePerRound/deltaFrames;
if smallMovie
    if strcmpi(ext, '.mp4')
         v = VideoWriter(filePath, 'MPEG-4');
        v.Quality = 100;
    else
        v = VideoWriter(filePath, 'Indexed AVI');
        v.Colormap = colors;
    end
else
    if strcmpi(ext, '.mp4')
        v = VideoWriter(filePath, 'MPEG-4');
        v.Quality = 50;
    else
        v = VideoWriter(filePath, 'Uncompressed AVI');
    end
end
if ~exist('scaling', 'var') || isempty(scaling)
    scaling = 1;
end

v.FrameRate = frameRate;
open(v);

imgId=0;
if ~exist(fullfile(folder, sprintf(fileTemplate, 0)), 'file')
    imgId=1;
end
firstRound = true;
while true
    imgPath = fullfile(folder, sprintf(fileTemplate, imgId));
    if ~exist(imgPath, 'file')
        break;
    end
    load(imgPath, 'S');
    if smallMovie
        if scaling ~= 1
            S = repelem(S, scaling, scaling);
        end
        if strcmpi(ext, '.mp4')
            St = zeros([size(S)+[1,1], 3]);
            for i=1:size(S, 1)
                for j=1:size(S, 2)
                    if isinf(S(i, j))
                        St(i, j, :) = ones(1,3);
                    else
                        St(i, j, :) = colors(S(i, j)+1, :);
                    end
                end
            end
            writeVideo(v, uint8(round(St*255)));
        else
            writeVideo(v, uint8(S));
        end
        
    else
        if firstRound
            firstRound = false;
            fgh = printPile(S, [], [], true, 0);
             ppp = fgh.Position;
             ppp(1)=0;
             ppp(2)=0;
             fgh.Position = ppp;
            drawnow();
            if showText
                pos = get(gca(), 'Position');
                txt = uicontrol('Style','text',...
                    'Units', 'centimeters',...
                        'Position',[pos(1), 0.1, 12, 1.4],...
                        'String',sprintf('time: %3.3f', 0),...
                        'BackgroundColor', ones(1,3),...
                        'HorizontalAlignment', 'left',...
                        'FontSize', 20);
            end
        else
            fgh = printPile(S, fgh, [], true, 0);
        end
        if showText
            if exist('mode', 'var') && strcmpi(mode, 'scaling')
                if referenceTime == 0
                    txt.String = sprintf('Domain=%gx%g', size(S, 1), size(S, 2));
                else
                    txt.String = sprintf('Domain=%gx%g, Time=%3.6f', size(S, 1), size(S, 2), domainTimes(imgId));
                end
            elseif exist('mode', 'var') && strcmpi(mode, 'mask')
                txt.String = sprintf('Transformation progress: %05.2f%%', (imgId-1)/(length(maskVariables)-1)*100);
            else
                txt.String = sprintf('Time=%3.6f', imgId/stepsPerRound);
            end
        end
        drawnow();
        writeVideo(v,getframe(fgh));
    end
    imgId = imgId+deltaFrames;
end
close(v);
if ~smallMovie
    close(fgh);
end
end

