function figH = interViewer(varargin)
%% Pre-process input
if nargin <1 || isempty(varargin{1})
    [filename, pathname, ~] = uigetfile({'config.mat'}, 'Select movie configuration file', fullfile(cd(), 'config.mat'));
    if isempty(filename) || (isnumeric(filename) && numel(filename) == 1 && filename == 0)
        return;
    end
    configFile = fullfile(pathname, filename);
else
    configFile = varargin{1};
end


%% Load Configuration
if isstruct(configFile)
    data = configFile;
else
    load(configFile);
    [folder, ~, ~] = fileparts(configFile);
    data = struct();
    data.configFile = configFile;
    data.fileTemplate = fileTemplate;
    data.numRounds = numRounds;
    data.numSteps = numSteps;
    data.folder = folder;
    data.stepsPerRound = stepsPerRound;
    data.currentIndex = 0;
end
colors = pileColors();

%% Create figure
figH = figure('Color', ones(1,3), 'NumberTitle', 'off', 'Units', 'pixels', 'MenuBar', 'none');
figH.Name = sprintf('InterPile Viewer - %s', data.configFile);
figH.KeyPressFcn = {@keyDown};
figH.UserData=data;
try
    setWindowIcon();
catch
    % Do nothing, default Matlab icon is OK, too.
end
%% Menus

% File
fileMenu = uimenu(figH, 'Label', 'File'); 
uimenu(fileMenu, 'Label',...
        'Open Movie', ...
        'Callback', @(figH, ~)interViewer());
uimenu(fileMenu, 'Label',...
        'Clone Window', ...
        'Callback', @(figH, ~)interViewer(getData(figH)));
uimenu(fileMenu, 'Label',...
    'Edit Pile in InterPile', ...
    'Callback', @(figH, ~)interPile(getPile(figH)), 'Separator','on');
uimenu(fileMenu, 'Label',...
    'Display Pile as Image', ...
    'Callback', @(figH, ~)printPile(getPile(figH)), 'Separator','on');
uimenu(fileMenu, 'Label',...
    'Save Pile as Image', ...
    'Callback', @(figH, ~)savePileAsImage(figH));
uimenu(fileMenu, 'Label',...
    'Save Pile as Mat', ...
    'Callback', @(figH, ~)savePileAsMat(figH));


%% Time bar
timeField = uicontrol('Style', 'slider', ...
    'Tag', 'timeField',...
    'Units', 'centimeters');
timeField.Max = 1;
timeField.Min = 0;
timeField.Value = data.currentIndex/data.numSteps;
timeField.SliderStep = [1,1]./data.numSteps;
timeField.Callback = @(figH, ~)timeChanged(figH);

uicontrol('Style', 'text', 'String', 'Time X.XX (XXX of XXX)',...
    'Tag', 'timeText',...
    'Units', 'centimeters', 'HorizontalAlignment', 'center', 'Background', ones(1,3));

%% Main plot
axH = axes('Tag', 'Splot', 'Units', 'pixels');
colormap(colors)
cbh = colorbar('north', 'Ticks', (1:size(colors, 1))+0.5, 'TickLabels', arrayfun(@(x)int2str(x), 0:size(colors, 1)-1, 'UniformOutput', false), 'Units', 'centimeters', 'Tag', 'colorbar');
hold on;
plotPile(figH);
data = getData(figH);
xlim([0.5, size(data.S, 2)+0.5]);
ylim([0.5, size(data.S, 1)+0.5]);
axH.YDir = 'reverse';
axH.XTick = [];
axH.YTick = [];
axH.Layer = 'top';
box on;

%% resize and initialize callbacks
onResize(figH);
set(figH, 'ResizeFcn', @onResize); 
set(figH, 'WindowButtonMotionFcn', {@mouseMove});

end
function savePileAsImage(figH)
    [filename,ext,user_canceled] = imputfile();
    if user_canceled
        return;
    end
    
    S = getPile(figH);
    S(isnan(S)) = 0;
    
    imwrite(S+1, pileColors(), filename, ext);
end
function savePileAsMat(figH)
    [fileName,pathName] = uiputfile('sandpile.mat', 'Save Sandpile');
    if ~ischar(fileName)
        return;
    end
    S = getPile(figH); %#ok<NASGU>
    save(fullfile(pathName, fileName), 'S');
end
function setIndex(figH, index)
    figH = ancestor(figH,'figure');
    if index < 0
        index = 0;
    elseif index > figH.UserData.numSteps
        index = figH.UserData.numSteps;
    end
    figH.UserData.currentIndex = index;
    plotPile(figH);
    timeField = findall(figH, 'Tag', 'timeField');
    timeField.Value = (figH.UserData.currentIndex)/(figH.UserData.numSteps);
end
function index = getIndex(figH)
    index = figH.UserData.currentIndex;
end
function keyDown(figH, evt)
    switch evt.Key
        case 'rightarrow'
            setIndex(figH, getIndex(figH)+1);
        case 'leftarrow'
            setIndex(figH, getIndex(figH)-1);
        otherwise  
    end
    
end
function timeChanged(figH)
    figH = ancestor(figH,'figure');
    timeField = findall(figH, 'Tag', 'timeField');
    figH.UserData.currentIndex = round(timeField.Value*(figH.UserData.numSteps));
    plotPile(figH);
end
function mouseMove(figH, ~)
    figH = ancestor(figH,'figure');
    S = getPile(figH);
    mousePos = get(figH,'CurrentPoint');
    axisPos = get(findall(figH, 'Tag', 'Splot'), 'Position');
    
    width = size(S, 2);
    height = size(S, 1);

    % Get mouse position
    x = (mousePos(1)-axisPos(1)) / axisPos(3);
    y = 1- (mousePos(2)-axisPos(2)) / axisPos(4);
    xData = ceil(width * x);
    yData = ceil(height * y);
    if xData > 0 && xData <= width && yData > 0 && yData <= height
        figH.Name = sprintf('InterPile Viewer - (%g, %g) -> %g', yData, xData, S(yData, xData));
    else
        figH.Name = sprintf('InterPile Viewer - %s', figH.UserData.configFile);
    end
end

function plotPile(figH)
    figH = ancestor(figH, 'figure');
    axH = findall(figH, 'Tag', 'Splot');
    axes(axH);
    cla();
    fileName = fullfile(figH.UserData.folder, sprintf(figH.UserData.fileTemplate, figH.UserData.currentIndex));
    if exist(fileName, 'file')
        load(fileName, 'S');
    end
    if ~exist('S', 'var')
        if isfield(figH.UserData, 'S')
            S = zeros(size(figH.UserData.S));
        else
            S = zeros(100, 100);
        end
    end
    Stemp = S;
    Stemp(isinf(Stemp)) = 10;
    image(Stemp+1);

    setPile(figH, S);
    
    timeText = findall(figH, 'Tag', 'timeText');
    timeText.String = sprintf('Time %1.7f (Image %g of %g)', (figH.UserData.currentIndex)/(figH.UserData.stepsPerRound),...
        figH.UserData.currentIndex,figH.UserData.numSteps);
end
function onResize(figH, ~)
    topHeight = 1.5; %cm
    bottomHeight = 1.5; %cm
    figH = ancestor(figH, 'figure');
    S = getPile(figH);
    % main plot
    axH = findall(figH, 'Tag', 'Splot');
    % get size
    set(figH, 'Units', 'centimeters');
    figureDim = get(figH, 'Position');
    set(figH, 'Units', 'pixels');
    figureDim = figureDim(3:4);
    width = min((figureDim-[0.5,topHeight+bottomHeight]).*[1, size(S, 2)/size(S, 1)]);
    height = width / size(S, 2)*size(S, 1);
    set(axH, 'Units', 'centimeters', 'Position', [0.25, bottomHeight + (figureDim(2)-bottomHeight-topHeight-height)/2, width, height]);
    set(axH, 'Units', 'pixels');
    
    % Colorbar
    colorbar = findall(figH, 'Tag', 'colorbar');
    colorbar.Position = [0.25, 0.25+bottomHeight+height + (figureDim(2)-bottomHeight-topHeight-height)/2, min(figureDim(1)-1, 6), 0.5];
    
    timeField = findall(figH, 'Tag', 'timeField');
    timeField.Position = [0.25, 0.75, figureDim(1)-0.5, 0.5];
    
    timeText = findall(figH, 'Tag', 'timeText');
    timeText.Position = [0.25, 0.15, figureDim(1)-0.5, 0.5];
end
function setPile(figH, S)
    data = getData(figH);
    data.S = S;
    set(ancestor(figH,'figure'), 'UserData', data);
end
function data = getData(figH)
    data = get(ancestor(figH,'figure'), 'UserData');
end
function S = getPile(figH)
    data = getData(figH);
    S = data.S;
end