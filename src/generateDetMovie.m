function generateDetMovie(S, filePath, polynomial, numRounds, stepsPerRound, timePerRound, smallMovie)

if nargin < 1
    S = nullPile(64, 64);
end

if nargin < 3
    detMovieDialog(S);
    return;
end

height = size(S, 1);
width = size(S, 2);

if ~exist('polynomial', 'var') || isempty(polynomial)
    polynomial = @(y,x) x.*(x.^2-3.*y.^2);
end

if ~exist('stepsPerRound', 'var') || isempty(stepsPerRound)
    stepsPerRound = 60;
end

if ~exist('filePath', 'var') || isempty(filePath)
    filePath = fullfile(cd(), sprintf('harmonicDet_%gx%g_%s.avi', height, width, datestr(now,'yyyy-MM-dd_HH-mm-ss')));
end

if ~exist('numRounds', 'var') || isempty(numRounds)
    numRounds = 2;
end

if ~exist('timePerRound', 'var') || isempty(timePerRound)
    timePerRound = 60;
end
if ~exist('smallMovie', 'var') || isempty(smallMovie)
    smallMovie = true;
end



[pathstr,name,~] = fileparts(filePath);
folder = fullfile(pathstr, [name, '_frames']);
fileTemplate = 'step%g.mat';
configPath = fullfile(folder, 'config.mat');

wbh = waitbar(0, 'Preparing movie...');
if ~exist(configPath, 'file')
    %% Get all drop numbers
    X=repmat((0:width+1) - (width+1)/2, height+2, 1);
    Y=repmat(((0:height+1) - (height+1)/2)', 1, width+2);

     if mod(width,2) ~= 1 || mod(height, 2) ~= 1
         X = 2*X;
         Y = 2*Y;
     end
    H = polynomial(Y, X);
    
    DeltaH = filter2([0,1,0;1,-4,1;0,1,0], H, 'valid');
    assert(all(all(~DeltaH)));
    %% Values at the vertices are not important for algorithm
    H(1,1) = 0;
    H(1, end) = 0;
    H(end, 1) = 0;
    H(end, end) = 0;
    %% Make all values positive, and drop again values at the vertices
    H = H - min(min(H));
    H(1,1) = 0;
    H(1, end) = 0;
    H(end, 1) = 0;
    H(end, end) = 0;
    %% divide by greatest common divisor
    values = setdiff(unique(H), 0);
    divisor = values(1);
    for i=2:length(values)
        divisor = gcd(divisor, values(i));
        if divisor == 1
            break;
        end
    end
    H = H ./divisor;

    %% Remove all values which do not correspond to drop zone
    F = H;
    F(2:end-1, 2:end-1) = 0;
    F(1,1) = 0;
    F(1, end) = 0;
    F(end, 1) = 0;
    F(end, end) = 0;
   
    %% The number of elements we have already dropped in the last rounds
    D = zeros(height+2, width+2);

    %% Filter to map the outside area to the inside
    addFilter = zeros(3,3);
    addFilter(1, 2)= 1;
    addFilter(2, 1)= 1;
    addFilter(2, 3)= 1;
    addFilter(3, 2)= 1;

    %% start iteration
    numSteps = ceil(numRounds*stepsPerRound);
    
    mkdir(folder);
    save(configPath, 'S', 'filePath', 'stepsPerRound', 'height', 'width', 'folder', 'fileTemplate', 'stepsPerRound', 'numSteps', 'numRounds');
    save(fullfile(folder, sprintf(fileTemplate, 0)), 'S');
    for s=1:numSteps
        wbh = waitbar(0.05+(s-1)/(numSteps)*0.85, wbh, sprintf('Generating frame %g of %g...', s, numSteps));
        
        n = s/stepsPerRound;
        
        Dnew = floor(n.*F);

        X = filter2(addFilter, Dnew - D, 'valid');
        D = Dnew;

        S = relaxPile(S+X);

        save(fullfile(folder, sprintf(fileTemplate, s)), 'S');
    end
else
    load(configPath);
end

%% Generate movie

wbh = waitbar(0.9, wbh, 'Generating Movie...');
%%
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
close(wbh)

end

