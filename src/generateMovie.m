function generateMovie(S, filePath, harmonic, numRounds, stepsPerRound, timePerRound)

if nargin < 1
    S = nullPile(64, 64);
end

if nargin < 3
    movieDialog(S);
    return;
end

[pathstr,name,~] = fileparts(filePath);
folder = fullfile(pathstr, [name, '_frames']);
width = size(S, 2);
height = size(S, 2);

if ~exist('numRounds', 'var') || isempty(numRounds)
    numRounds = 2;
end
if ~exist('stepsPerRound', 'var') || isempty(stepsPerRound)
    stepsPerRound = 64;
end
if ~exist('timePerRound', 'var') || isempty(timePerRound)
    timePerRound = 4;
end

fileTemplate = 'step%g.mat';


%% Create frames
wbh = waitbar(0, 'Preparing movie...');
if ~exist(folder, 'dir')
    % distri = toDistribution(harmonic(height, width));
    % distriN = size(distri, 1);

    [distri, distriN] = toDistributionReal(harmonic(height, width));
    ps = distri(:, 3);
    xs = distri(:, 2);
    ys = distri(:, 1);
    coinsPerStep = round(distriN/stepsPerRound);
    numRepeats = round(numRounds*stepsPerRound);
    
    mkdir(folder);
    save(fullfile(folder, sprintf(fileTemplate, 0)), 'S');


    for i=1:numRepeats
        wbh = waitbar(0.05+(i-1)/numRepeats*0.85, wbh, sprintf('Generating frame %g of %g...', i, numRepeats));

        for k=1:coinsPerStep
            s = rand();
            idx = find(ps>=s, 1);
            %idx = randi(distriN);
            S(ys(idx), xs(idx)) = S(ys(idx), xs(idx)) + 1;
        end
        S = relaxPile(S);
        save(fullfile(folder, sprintf(fileTemplate, i)), 'S');
    end
end

%% Create movie
wbh = waitbar(0.9, wbh, 'Generating Movie...');
frameRate = stepsPerRound/timePerRound;
v = VideoWriter(filePath);
v.FrameRate = frameRate;
open(v);

imgId=0;
while true
    imgPath = fullfile(folder, sprintf(fileTemplate, imgId));
    if ~exist(imgPath, 'file')
        break;
    end
    load(imgPath, 'S');
    if imgId==0
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
        txt.String = sprintf('<coins/field>=%3.3f', imgId/stepsPerRound);
        fgh = printPile(S, fgh);
    end
    drawnow();
    writeVideo(v,getframe(fgh));
    imgId = imgId+1;
end
close(v);
close(fgh);
close(wbh)
end