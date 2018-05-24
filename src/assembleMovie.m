function assembleMovie(filePath, configPath, timePerRound, smallMovie)
load(configPath);

%% Generate movie
frameRate = stepsPerRound/timePerRound;
if smallMovie
    v = VideoWriter(filePath, 'Indexed AVI');
    v.Colormap = pileColors();
else
    v = VideoWriter(filePath, 'Uncompressed AVI');
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
        writeVideo(v, uint8(S));
    else
        if firstRound
            firstRound = false;
            fgh = printPile(S);
            drawnow();
            pos = get(gca(), 'Position');
            txt = uicontrol('Style','text',...
                'Units', 'centimeters',...
                    'Position',[pos(1), 0.5, 4, 0.5],...
                    'String',sprintf('time: %3.3f', 0),...
                    'BackgroundColor', ones(1,3),...
                    'HorizontalAlignment', 'left',...
                    'FontSize', 12);
        else
            fgh = printPile(S, fgh);
        end
        txt.String = sprintf('Time=%3.3f', imgId/stepsPerRound);
        drawnow();
        writeVideo(v,getframe(fgh));
    end
    imgId = imgId+1;
end
close(v);
if ~smallMovie
    close(fgh);
end
end

