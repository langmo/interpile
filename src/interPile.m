function figH = interPile(varargin)
%% Pre-process input
if nargin <1 || isempty(varargin{1})
    var1 = zeros(64, 64);
else
    var1 = varargin{1};
end
if isstruct(var1)
    data = var1;
else
    data = struct();
    data.Sundo = {};
    data.Sredo = {};
    data.S = var1;
end
if nargin >=2 && ~isempty(varargin{2}) && ishandle(varargin{2})
    figH = ancestor(varargin{2}, 'figure');
    figure(figH);
    plotPile(data.S, figH);
    return;
end

%% Configuration
harmonics = harmonicDropZones();
colors = pileColors();

%% Create figure
figH = figure('Color', ones(1,3), 'NumberTitle', 'off', 'Units', 'pixels', 'MenuBar', 'none');
figH.Name = sprintf('InterPile - %gx%g board', size(data.S, 1), size(data.S, 2));
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
        'New Window', ...
        'Callback', @(figH, ~)interPile());
uimenu(fileMenu, 'Label',...
        'Clone Window', ...
        'Callback', @(figH, ~)interPile(getData(figH)));
uimenu(fileMenu, 'Label',...
    'Movie Viewer', ...
    'Callback', @(figH, ~)interViewer());
uimenu(fileMenu, 'Label',...
    'Display Pile as Image', ...
    'Callback', @(figH, ~)printPile(getPile(figH)), 'Separator','on');
uimenu(fileMenu, 'Label',...
    'Save Pile as Image', ...
    'Callback', @(figH, ~)savePileAsImage(figH));
uimenu(fileMenu, 'Label',...
    'Save Pile as Mat', ...
    'Callback', @(figH, ~)savePileAsMat(figH));
uimenu(fileMenu, 'Label',...
    'Save Pile as Dropzone', ...
    'Callback', @(figH, ~)savePileAsDropZone(figH));


uimenu(fileMenu, 'Label',...
    'Stochastic Movie', ...
    'Callback', @(figH, ~)generateMovie(getPile(figH)), 'Separator','on');

uimenu(fileMenu, 'Label',...
    'Deterministic Movie', ...
    'Callback', @(figH, ~)generateDetMovie(getPile(figH)));
    
% Edit
editMenu = uimenu(figH, 'Label', 'Edit');
if ~isdeployed()
    uimenu(editMenu, 'Label',...
            'Export Pile to Workspace', ...
            'Callback', @(figH, ~)assignin('base', 'S', getPile(figH)));
    uimenu(editMenu, 'Label',...
            'Add Pile from Workspace', ...
            'Callback', @(figH, ~)plotPile(getPile(figH)+evalin('base', 'S'), figH));
end
uimenu(editMenu, 'Label',...
        'Undo', ...
        'Callback', @undo, 'Separator','on');
uimenu(editMenu, 'Label',...
        'Redo', ...
        'Callback', @redo);


% Transform
transformMenu = uimenu(figH, 'Label', 'Transform'); 
uimenu(transformMenu, 'Label',...
        'Invert Pile', ...
        'Callback', @invert);
uimenu(transformMenu, 'Label',...
        '3-Pile', ...
        'Callback', @threeMinusPile);
uimenu(transformMenu, 'Label',...
        '3+Pile', ...
        'Callback', @threePlusPile);
uimenu(transformMenu, 'Label',...
        '6-Pile', ...
        'Callback', @sixMinusPile);    
uimenu(transformMenu, 'Label',...
        '2*Pile', ...
        'Callback', @twoTimesPile);
    
% Size
sizeMenu = uimenu(figH, 'Label', 'Size'); 
uimenu(sizeMenu, 'Label',...
        'Custom Size', ...
        'Callback', @(figH, ~)boardSizeCustom(figH));
evenSizeMenu = uimenu(sizeMenu, 'Label', '2^N'); 
sizes = 2.^(0:1:9);
for mySize = sizes
    uimenu(evenSizeMenu, 'Label',...
        sprintf('%gx%g', mySize, mySize), ...
        'Callback', @(figH, ~)boardSize(mySize,mySize,figH));
end
oddSizeMenu = uimenu(sizeMenu, 'Label', '2^N-1'); 
sizes = 2.^(1:1:9)-1;
for mySize = sizes
    uimenu(oddSizeMenu, 'Label',...
        sprintf('%gx%g', mySize, mySize), ...
        'Callback', @(figH, ~)boardSize(mySize,mySize,figH));
end

size3NMenu = uimenu(sizeMenu, 'Label', '3^N'); 
sizes = 3.^(0:1:7);
for mySize = sizes
    uimenu(size3NMenu, 'Label',...
        sprintf('%gx%g', mySize, mySize), ...
        'Callback', @(figH, ~)boardSize(mySize,mySize,figH));
end

size3N_Menu = uimenu(sizeMenu, 'Label', '3^N-1'); 
sizes = 3.^(1:1:7)-1;
for mySize = sizes
    uimenu(size3N_Menu, 'Label',...
        sprintf('%gx%g', mySize, mySize), ...
        'Callback', @(figH, ~)boardSize(mySize,mySize,figH));
end

size2x3_Menu = uimenu(sizeMenu, 'Label', '2 x 3^N'); 
sizes = 2*3.^(0:1:7);
for mySize = sizes
    uimenu(size2x3_Menu, 'Label',...
        sprintf('%gx%g', mySize, mySize), ...
        'Callback', @(figH, ~)boardSize(mySize,mySize,figH));
end

% Fill
fillMenu = uimenu(figH, 'Label', 'Fill'); 
uimenu(fillMenu, 'Label',...
    'All 0', ...
    'Callback', @(figH, ~)fillAll(figH, 0));
uimenu(fillMenu, 'Label',...
    'All 1', ...
    'Callback', @(figH, ~)fillAll(figH, 1));
uimenu(fillMenu, 'Label',...
    'All 2', ...
    'Callback', @(figH, ~)fillAll(figH, 2));
uimenu(fillMenu, 'Label',...
    'All 3', ...
    'Callback', @(figH, ~)fillAll(figH, 3));
uimenu(fillMenu, 'Label',...
    'Null Pile', ...
    'Callback', @fillNullPile,'Separator','on');
uimenu(fillMenu, 'Label',...
    'Random', ...
    'Callback', @fillRandom);

% Drop random
dropRandomMenu = uimenu(figH, 'Label', 'Drop Random'); 
subMenu = uimenu(dropRandomMenu, 'Label', 'Uniform');
uimenu(subMenu, 'Label', 'User defined', ...
        'Callback', @(figH, ~)dropRandom(figH, askForInput(figH, 'Number of particles:')));
sizes = 2.^(0:1:6);
for mySize = sizes
    uimenu(subMenu, 'Label',...
        sprintf('%g Particles', mySize), ...
        'Callback', @(figH, ~)dropRandom(figH, mySize));
end
sizes = 2.^(-5:5);
for mySize = sizes
    if mySize >=1
        name = sprintf('<%g Particles/Field>', mySize);
    else
        name = sprintf('<1/%g Particles/Field>', 1/mySize);
    end
    uimenu(subMenu, 'Label', name, ...
        'Callback', @(figH, ~)dropRandom(figH, [], mySize));
end
    
subMenu = uimenu(dropRandomMenu, 'Label', 'Radial Uniform');
uimenu(subMenu, 'Label', 'User defined', ...
        'Callback', @(figH, ~)dropRandomCircle(figH, askForInput(figH, 'Number of particles:')));
sizes = 2.^(0:1:6);
for mySize = sizes
    uimenu(subMenu, 'Label',...
        sprintf('%g Particles', mySize), ...
        'Callback', @(figH, ~)dropRandomCircle(figH, mySize));
end

subMenu = uimenu(dropRandomMenu, 'Label', 'Radial Perfect');
sizes = 2.^(-5:5);
for mySize = sizes
    if mySize >=1
        name = sprintf('%g*width^2 Particles', mySize);
    else
        name = sprintf('1/%g*width^2 Particles', 1/mySize);
    end
    uimenu(subMenu, 'Label',...
        name, ...
        'Callback', @(figH, ~)dropRandomPerfectCircle(figH, mySize));
end

subMenu = uimenu(dropRandomMenu, 'Label', 'Square Perfect Half');
sizes = 2.^(-5:5);
for mySize = sizes
    if mySize >=1
        name = sprintf('%g*width^2 Particles', mySize);
    else
        name = sprintf('1/%g*width^2 Particles', 1/mySize);
    end
    uimenu(subMenu, 'Label',...
        name, ...
        'Callback', @(figH, ~)dropRandomPerfectSquare(figH, 1/2, mySize));
end

subMenu = uimenu(dropRandomMenu, 'Label', 'Harmonic Square 45°', 'Separator','on');
uimenu(subMenu, 'Label',...
        'User defined', ...
        'Callback', @(figH, ~)dropRandomSquare45(figH, askForInput(figH, 'Average fraction of null element:')));
sizes = 2.^(-5:5);
for mySize = sizes
    if mySize >=1
        name = sprintf('<%g x null element>', mySize);
    else
        name = sprintf('<1/%g x null element>', 1/mySize);
    end
    uimenu(subMenu, 'Label',...
        name, ...
        'Callback', @(figH, ~)dropRandomSquare45(figH, mySize));
end

for h=1:length(harmonics)
    harmonic = harmonics{h};
    if h==1
        subMenu = uimenu(dropRandomMenu, 'Label', sprintf('Harmonic %s', harmonic{1}), 'Separator','on');
    else
        subMenu = uimenu(dropRandomMenu, 'Label', sprintf('Harmonic %s', harmonic{1}));
    end
    uimenu(subMenu, 'Label',...
            'User defined', ...
            'Callback', @(figH, ~)dropRandomHarmonic(figH, askForInput(figH, sprintf('Fraction of harmonic %s:', harmonic{1})), harmonic{2}));
    sizes = 2.^(-5:5);
    for mySize = sizes
        if mySize >=1
            name = sprintf('<%g x null element>', mySize);
        else
            name = sprintf('<1/%g x null element>', 1/mySize);
        end
        uimenu(subMenu, 'Label',...
            name, ...
            'Callback', @(figH, ~)dropRandomHarmonic(figH, mySize, harmonic{2}));
    end
end

% Drop deterministic
dropDeterministicMenu = uimenu(figH, 'Label', 'Drop Deterministic'); 
subMenu = uimenu(dropDeterministicMenu, 'Label', 'Cross');
uimenu(subMenu, 'Label',...
        'User defined', ...
        'Callback', @(figH, ~)dropCross(figH, round(askForInput(figH, 'Number of particles in cross fields:'))));
sizes = 1:1:10;
for mySize = sizes
    name = sprintf('%g Particles/field', mySize);
    uimenu(subMenu, 'Label',...
        name, ...
        'Callback', @(figH, ~)dropCross(figH, mySize));
end
subMenu = uimenu(dropDeterministicMenu, 'Label', 'Circle');
uimenu(subMenu, 'Label',...
        'User defined', ...
        'Callback', @(figH, ~)dropCircle(figH, round(askForInput(figH, 'Number of particles in circle fields:'))));
sizes = 1:1:10;
for mySize = sizes
    name = sprintf('%g Particles/field', mySize);
    uimenu(subMenu, 'Label',...
        name, ...
        'Callback', @(figH, ~)dropCircle(figH, mySize));
end

subMenu = uimenu(dropDeterministicMenu, 'Label', 'Harmonic Square 45°', 'Separator','on');
uimenu(subMenu, 'Label',...
        'User defined', ...
        'Callback', @(figH, ~)dropSquare45(figH, 0.5*round(2*askForInput(figH, 'Number of times to add harmonic square 45°:'))));
sizes = 0.5:0.5:10;
for mySize = sizes
    name = sprintf('%g x Square 45°', mySize);
    uimenu(subMenu, 'Label',...
        name, ...
        'Callback', @(figH, ~)dropSquare45(figH, mySize));
end

for h=1:length(harmonics)
    harmonic = harmonics{h};
    if h==1
        subMenu = uimenu(dropDeterministicMenu, 'Label', sprintf('Harmonic %s', harmonic{1}), 'Separator','on');
    else
        subMenu = uimenu(dropDeterministicMenu, 'Label', sprintf('Harmonic %s', harmonic{1}));
    end
    uimenu(subMenu, 'Label',...
            'User defined', ...
            'Callback', @(figH, ~)dropHarmonic(figH, round(askForInput(figH, sprintf('Number of times to add harmonic %s:', harmonic{1}))), harmonic{2}));
    sizes = 2.^(0:8);
    for mySize = sizes
        name = sprintf('%g x Harmonic %s', mySize, harmonic{1});
        uimenu(subMenu, 'Label',...
            name, ...
            'Callback', @(figH, ~)dropHarmonic(figH, mySize, harmonic{2}));
    end
end

%% recurrent field
uicontrol('Style', 'text', 'String', 'valid',...
    'Tag', 'validField',...
    'Units', 'centimeters',...
    'BackgroundColor', [0,1,0],...
    'HorizontalAlignment', 'center');


%% Main plot
axH = axes('Tag', 'Splot', 'Units', 'pixels');
colormap(colors)
colorbar('south', 'Ticks', (1:size(colors, 1))+0.5, 'TickLabels', arrayfun(@(x)int2str(x), 0:size(colors, 1)-1, 'UniformOutput', false), 'Units', 'centimeters', 'Tag', 'colorbar');
hold on;
plotPile(data.S, figH, true, false);
%axis off;
xlim([0.5, size(data.S, 2)+0.5]);
ylim([0.5, size(data.S, 1)+0.5]);
axH.YDir = 'reverse';
axH.XTick = [];
axH.YTick = [];
% grid(axH, 'on');
% grid(axH, 'minor');
axH.Layer = 'top';
box on;

%% initialize options
% optionsPanel = uipanel('Title', 'Options', 'BackgroundColor', [1, 1, 1],...
%     'Units', 'centimeters', 'Tag', 'options');

modeH = uibuttongroup('visible','off', 'Units', 'centimeters',...
    'Position', [0.25, 0.25, 5, 5], 'Title', 'Options',...
    'Tag', 'modeGroup',...
    'BackgroundColor', [1,1,1]);
addToppleH = uicontrol('Style','Radio','String','Add',...
    'Units', 'centimeters','pos',[0.25,3.75,2,0.5],'parent', modeH,'HandleVisibility','off',...
    'Tag', 'modeAdd',...
    'BackgroundColor', [1,1,1]);
uicontrol('Style','Radio','String','Decrease',...
    'Units', 'centimeters','pos',[0.25,3,2,0.5],'parent', modeH,'HandleVisibility','off',...
    'Tag', 'modeDecrease',...
    'BackgroundColor', [1,1,1]);
uicontrol('Style','Radio','String','Wave',...
    'Units', 'centimeters','pos',[0.25,2.25,2,0.5],'parent', modeH,'HandleVisibility','off',...
    'Tag', 'modeWave',...
    'BackgroundColor', [1,1,1]);
set(modeH,'SelectedObject',addToppleH);
set(modeH,'Visible','on');

uicontrol('Style','checkbox','String','Auto-Topple',...
    'Units', 'centimeters','pos',[0.25,1.25,2.5,0.5],'parent', modeH,'HandleVisibility','off',...
    'Tag', 'modeAutoTopple',...
    'BackgroundColor', [1,1,1], 'Value', 1);

uicontrol('Style', 'pushbutton', ...
    'String', 'Topple', 'Units', 'centimeters','parent', modeH, ...
    'Position', [0.25,0.25,2.5,0.75], ...
    'Callback', {@onToppleButton},...
    'Tag', 'toppleButton');

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

    imwrite(getPile(figH)+1, pileColors(), filename, ext);
end
function savePileAsMat(figH)
    [fileName,pathName] = uiputfile('sandpile.mat', 'Save Sandpile');
    if ~ischar(fileName)
        return;
    end
    S = getPile(figH); %#ok<NASGU>
    save(fullfile(pathName, fileName), 'S');
end
function savePileAsDropZone(figH)
    name = inputdlg({'Dropzone Name:'}, 'Save Sandpile as Dropzone', 1, {'drop_zone_name'});
    if isempty(name)
        return;
    end
    name = name{1};
    S = getPile(figH); %#ok<NASGU>
    if ~isdeployed()
        dirName = 'drop_zones';
    else
        dirName = fullfile(ctfroot(), 'drop_zones');
    end
    if ~exist(dirName, 'dir')
        mkdir(dirName);
    end
    save(fullfile(dirName, [name, '.mat']), 'S');
end
function keyDown(figH, evt)
    if strcmp(evt.Character, sprintf('\b'))
        undo(figH);
    elseif strcmp(evt.Character, 'i')
        invert(figH);
    end
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
        figH.Name = sprintf('InterPile - (%g, %g) -> %g', yData, xData, S(yData, xData));
    else
        figH.Name = sprintf('InterPile - %gx%g board', size(S, 1), size(S, 2));
    end
end
function plotPileRelax(S, figH)
    figH = ancestor(figH, 'figure');
    modeAutoTopple = findall(figH, 'Tag', 'modeAutoTopple');

    shouldRelax = (modeAutoTopple.Value == 1) && any(any(S>3));
    plotPile(S, figH, ~shouldRelax);
    drawnow();
    if shouldRelax
        tic();
        S = relaxPile(S);
        el = toc();
        waitTime = round(1000*(0.3-el))/1000;
        if waitTime > 0
            t = timer;
            t.StartDelay = waitTime;
            t.TimerFcn = @(myTimerObj, thisEvent)plotPile(S, figH, true, false);
            start(t)
        else
            plotPile(S, figH, true, false);
        end
    end
end

function plotPile(S, figH, allowEdits, saveUndo)
    if nargin < 3
        allowEdits = true;
    end
    if nargin < 4
        saveUndo = true;
    end
  
    figH = ancestor(figH, 'figure');
    axH = findall(figH, 'Tag', 'Splot');
    axes(axH);
    cla();
    imageH = image(S+1);
    
    if allowEdits
        set(imageH,'ButtonDownFcn',{@dropParticle})
    else
        set(imageH,'ButtonDownFcn',{})
    end
    setPile(figH, S, saveUndo);
    
    axH = findall(figH, 'Tag', 'validField');
    if any(any(S>3))
        axH.String = 'unstable';
        axH.BackgroundColor = [0.7, 0.7, 0];
    elseif isRecurrentPile(S)
        axH.String = 'recurrent';
        axH.BackgroundColor = [0, 0.7, 0];
    else
        axH.String = 'non-recurrent';
        axH.BackgroundColor = [0.6, 0, 0];
    end
    
end
function onResize(figH, ~)
    optionsWidth = 3.5; %cm
    figH = ancestor(figH, 'figure');
    S = getPile(figH);
    % main plot
    axH = findall(figH, 'Tag', 'Splot');
    % get size
    set(figH, 'Units', 'centimeters');
    figureDim = get(figH, 'Position');
    set(figH, 'Units', 'pixels');
    figureDim = figureDim(3:4);
    width = min((figureDim-[0.5+optionsWidth,1.5]).*[1, size(S, 2)/size(S, 1)]);
    height = width / size(S, 2)*size(S, 1);
    set(axH, 'Units', 'centimeters', 'Position', [0.25, 1.25 + (figureDim(2)-1.5-height)/2, width, height]);
    set(axH, 'Units', 'pixels');
    
    % Colorbar
    axH = findall(figH, 'Tag', 'colorbar');
    axH.Position = [0.5, 0.5, min(figureDim(1)-optionsWidth-1, 6), 0.5];
    
    % Valid field
    axH = findall(figH, 'Tag', 'validField');
    axH.Position = [figureDim(1)-optionsWidth, 0.5, optionsWidth-0.25, 0.5];
    
    % Mode
    modeGroup = findall(figH, 'Tag', 'modeGroup');
    modeGroup.Position = [figureDim(1)-optionsWidth, figureDim(2)-5.25, optionsWidth-0.25, 5];
end
function setPile(figH, S, saveUndo)
    data = getData(figH);
    if saveUndo
        data.Sundo = [data.Sundo, data.S];
        data.Sredo = {};
    end
    data.S = S;
    while length(data.Sundo) > 10
        data.Sundo(1) = [];
    end
    set(ancestor(figH,'figure'), 'UserData', data);
end
function redo(figH, ~)
    data = getData(figH);
    if isempty(data) || length(data.Sredo)< 1
        return;
    end
    data.Sundo = [data.Sredo, {data.S}];
    S = data.Sredo{end};
    data.Sredo(end) = [];
    set(ancestor(figH,'figure'), 'UserData', data);
    plotPile(S, figH, true, false);
end
function undo(figH, ~)
    data = getData(figH);
    if isempty(data) || length(data.Sundo)< 1
        return;
    end
    data.Sredo = [data.Sredo, {data.S}];
    S = data.Sundo{end};
    data.Sundo(end) = [];
    set(ancestor(figH,'figure'), 'UserData', data);
    plotPile(S, figH, true, false);
end
function data = getData(figH)
    data = get(ancestor(figH,'figure'), 'UserData');
end
function S = getPile(figH)
    data = getData(figH);
    S = data.S;
end
function dropParticle(figH, ~)
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
        %% get selected option
        selectedChoice = get(findall(figH, 'Tag', 'modeGroup'), 'SelectedObject');
        if selectedChoice == findall(figH, 'Tag', 'modeAdd')
            S(yData, xData) = S(yData, xData) +1;
            plotPileRelax(S, figH);
        elseif selectedChoice == findall(figH, 'Tag', 'modeWave')
            if S(yData, xData)<3
                return;
            end
            S(yData, xData) = S(yData, xData) -4;
            if yData > 1
                S(yData-1, xData) = S(yData-1, xData) +1;
            end
            if yData < size(S, 1)
                S(yData+1, xData) = S(yData+1, xData) +1;
            end
            if xData > 1
                S(yData, xData-1) = S(yData, xData-1) +1;
            end
            if xData < size(S, 2)
                S(yData, xData+1) = S(yData, xData+1) +1;
            end
            plotPile(relaxPile(S), figH);
        else
            if S(yData, xData)<=0
                return;
            end
            S(yData, xData) = S(yData, xData) -1;
            plotPile(S, figH);
        end
    end
end
function onToppleButton(figH, ~)
    S = getPile(figH);
    Snew = relaxPile(S);
    if any(any(Snew~=S))
        plotPile(Snew, figH);
    end
end
function dropRandom(figH, N, k)
    S = getPile(figH);
    if nargin >= 3 && isempty(N)
        N = round(k*size(S, 1)*size(S, 2));
    end
    for i=1:N
        y = randi(size(S, 1));
        x = randi(size(S, 2));
        S(y,x) = S(y,x) + 1;
    end
    plotPileRelax(S, figH);
end

function dropRandomCircle(figH, N)
    S = getPile(figH);
    width = size(S, 1);
    radius = width/2;
    for i=1:N
        r = rand()*radius;
        phi = rand()*2*pi;
        x = 1+round((width-1)/2+r*sin(phi));
        y = 1+round((width-1)/2+r*cos(phi));
        S(y,x) = S(y,x) + 1;
    end
    plotPileRelax(S, figH);
end

function dropRandomSquare(figH, relRad, N)
    S = getPile(figH);
    width = size(S, 1);
    radius = relRad*width;
    for i=1:N
        x = 1+round((width-1)/2+(rand()-0.5)*radius);
        y = 1+round((width-1)/2+(rand()-0.5)*radius);
        S(y,x) = S(y,x) + 1;
    end
    plotPileRelax(S, figH);
end

function dropRandomSquare45(figH, k)
    S = getPile(figH);
    width = size(S, 2);
    height = size(S, 1);
    if width ~= height
        errordlg('Only available for square boards.', 'Function not available');
        return;
    end
    radius = width/sqrt(2);
    N = round(k*width^2);
    for i=1:N
        x = (rand()-0.5)*radius;
        y = (rand()-0.5)*radius;
        
        xx = 1+round((width-1)/2+x*cos(pi/4)-y*sin(pi/4));
        yy = 1+round((width-1)/2+x*sin(pi/4)+y*cos(pi/4));
        S(yy,xx) = S(yy,xx) + 1;
    end
    plotPileRelax(S, figH);
end
function dropSquare45(figH, k)
    S = getPile(figH);
    height = size(S, 1);
    width = size(S, 2);
    if width ~= height
        errordlg('Only available for square boards.', 'Function not available');
        return;
    end
    S = S + round(2*k)*double(repmat(abs((1:width)-width/2-0.5), width, 1)+repmat(abs((1:width)'-width/2-0.5), 1, width)<=width/2);
    plotPileRelax(S, figH);
end

function dropHarmonic(figH, k, harmonicFct)
    S = getPile(figH);
    height = size(S, 1);
    width = size(S, 2);
    S = S + k*harmonicFct(height, width);
    plotPileRelax(S, figH);
end


function dropRandomHarmonic(figH, k, harmonic)
    S = getPile(figH);
    height = size(S, 1);
    width = size(S, 2);
    distri = toDistribution(harmonic(height, width));
    distriN = size(distri, 1);
    N = distriN*k;
    for i=1:N
        idx = randi(distriN);
        S(distri(idx, 1), distri(idx, 2)) = S(distri(idx, 1), distri(idx, 2)) + 1;
    end
    plotPileRelax(S, figH);
end
function dropCross(figH, k)
    S = getPile(figH);
    width = size(S, 2);
    height = size(S, 1);
    if mod(height, 2) == 1
        S(ceil(height/2), 1:width) = S(ceil(height/2), 1:width) + 2*k;
    else
        S(height/2, 1:width) = S(height/2, 1:width) + 1*k;
        S(height/2+1, 1:width) = S(height/2+1, 1:width) + 1*k;
    end
    if mod(width, 2) == 1
        S(1:height, ceil(width/2)) = S(1:height, ceil(width/2)) + 2*k;
    else
        S(1: height, width/2) = S(1: height, width/2) + 1*k;
        S(1: height, width/2+1) = S(1: height, width/2+1) + 1*k;
    end
    plotPileRelax(S, figH);
end
function dropCircle(figH, k)
    S = getPile(figH);
    width = size(S, 2);
    S = S + k*double(repmat(abs((1:width)-width/2-0.5), width, 1).^2+repmat(abs((1:width)'-width/2-0.5), 1, width).^2<=(width/2)^2);
    plotPileRelax(S, figH);
end
function fraction = askForInput(figH, text)
    if nargin < 2
        text = 'Number of particles to drop:';
    end
    data = getData(figH);
    if ~isfield(data, 'UserInput')
        data.UserInput = '1/8';
    end
    prompt = {text};
    title = 'User Input';
    dims = [1 35];
    definput = {data.UserInput};
    answer = inputdlg(prompt,title,dims,definput);
    if isempty(answer)
        fraction = 0;
    else
        try
            fraction = evalin('base', answer{1});
            data.UserInput = answer{1};
            set(ancestor(figH,'figure'), 'UserData', data);
        catch
            errordlg(sprintf('Could not evaluate string "%s" to a real number!', answer{1}), 'Invalid Input');
        end
    end
end

function boardSizeCustom(figH)
    S = getPile(figH);
    
    prompt = {'Enter width:', 'Enter height:'};
    title = 'Size of sandpile';
    dims = [1 35];
    definput = {int2str(size(S, 2)), int2str(size(S, 1))};
    answer = inputdlg(prompt,title,dims,definput);
    if ~isempty(answer)
        try
            width = evalin('base', answer{1});
        catch
            errordlg(sprintf('Could not evaluate width string "%s" to a real number!', answer{1}), 'Invalid Input');
            return;
        end
        try
            height = evalin('base', answer{2});
            
        catch
            errordlg(sprintf('Could not evaluate height string "%s" to a real number!', answer{2}), 'Invalid Input');
            return;
        end
        boardSize(width, height, figH);
    end
end



function dropRandomPerfectSquare(figH, relRad, k)
    S = getPile(figH);
    width = size(S, 1);
    N = round(k*width^2);
    dropRandomSquare(figH, relRad, N)
end

function dropRandomPerfectCircle(figH, k)
    S = getPile(figH);
    width = size(S, 1);
    N = round(k*width^2);
    dropRandomCircle(figH, N)
end

function boardSize(width, height, figH)
    S = getPile(figH);
    if width == size(S, 2) && height == size(S, 1)
        return;
    end
    figH = ancestor(figH, 'figure');
    axH = findall(figH, 'Tag', 'Splot');
    S = zeros(height, width)*3;
    plotPile(S, figH);
    xlim(axH, [0.5, size(S, 2)+0.5]);
    ylim(axH, [0.5, size(S, 1)+0.5]);
    figH.Name = sprintf('InterPile - %gx%g board', height, width);
    onResize(figH);
end
function invert(figH, ~)
    S = getPile(figH);
    plotPile(inversePile(S), figH);
end
function threeMinusPile(figH, ~)
    S = getPile(figH);
    plotPile(3*ones(size(S))-S, figH);
end
function sixMinusPile(figH, ~)
    S = getPile(figH);
    plotPileRelax(6*ones(size(S))-S, figH);
end
function threePlusPile(figH, ~)
    S = getPile(figH);
    plotPileRelax(3*ones(size(S))+S, figH);
end
function twoTimesPile(figH, ~)
    S = getPile(figH);
    plotPileRelax(S+S, figH);
end
function fillAll(figH, number)
    S = ones(size(getPile(figH)))*number;
    plotPile(S, figH);
end

function fillNullPile(figH, ~)
    S = getPile(figH);
    plotPile(nullPile(size(S, 1), size(S, 2)), figH);
end
function fillRandom(figH, ~)
    S = getPile(figH);
    S = randi(4,size(S, 1),size(S, 2))-1;
    plotPile(S, figH);
end