function assembleMovie(filePath, configPath, timePerRound, smallMovie, scaling, deltaT, showTime)
load(configPath);
[~,~,ext] = fileparts(filePath);
[folder, ~, ~] = fileparts(configPath);
%% Generate movie
if ~exist('deltaT', 'var') || isempty(deltaT)
    deltaT = 1;
end
if ~exist('showTime', 'var') || isempty(showTime)
    showTime = true;
end
colors = pileColors();
colors = colors(1:4, :);
frameRate = stepsPerRound/timePerRound/deltaT;
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
                    St(i, j, :) = colors(S(i, j)+1, :);
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
            drawnow();
            if showTime
                pos = get(gca(), 'Position');
                txt = uicontrol('Style','text',...
                    'Units', 'centimeters',...
                        'Position',[pos(1), 0.1, 4, 1.4],...
                        'String',sprintf('time: %3.3f', 0),...
                        'BackgroundColor', ones(1,3),...
                        'HorizontalAlignment', 'left',...
                        'FontSize', 20);
            end
        else
            fgh = printPile(S, fgh, [], true, 0);
        end
        if showTime
            txt.String = sprintf('Time=%3.3f', imgId/stepsPerRound);
        end
        drawnow();
        writeVideo(v,getframe(fgh));
    end
    imgId = imgId+deltaT;
end
close(v);
if ~smallMovie
    close(fgh);
end
end

