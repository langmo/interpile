function varargout = interPile(varargin)
% interPile - Graphical user interface for interactively manipulating
% sandpiles and generating movies of their harmonic dynamics.
% Usage:
%   interPile()
%       Opens the graphical user interface with a 63x63 empty starting
%       sandpile.
%   interPile(S)
%       Opens the graphical user interface initialized to the sandpile S.
%   interPile(S, figH)
%       Displays the sandpile S in the already opened InterPile graphical
%       user interface having the provided figure handle figH.
%   figH = interPile(...)
%       Returns the figure handle of the InterPile user interface.

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

%% Pre-process input
if nargin <1 || isempty(varargin{1})
    var1 = zeros(255, 255);
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
otherPotentials = potentials();
harmonicFcts = harmonicFunctions();
colors = pileColors();

%% Create figure
figH = figure('Color', ones(1,3), 'NumberTitle', 'off', 'units','normalized','outerposition',[0.2 0.2 0.6 0.6], 'Units', 'pixels', 'MenuBar', 'none');
figH.Name = sprintf('InterPile - %gx%g domain', size(data.S, 1), size(data.S, 2));
figH.KeyPressFcn = {@keyDown};
figH.UserData=data;
setWindowIcon();
%% Menu: File
fileMenu = uimenu(figH, 'Label', 'File'); 
uimenu(fileMenu, 'Label',...
        'New Window', ...
        'Callback', @(figH, ~)interPile(getData(figH)));
uimenu(fileMenu, 'Label',...
    'Movie Viewer', ...
    'Callback', @(figH, ~)openMovie(figH));
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
    'Load Pile from Mat', ...
    'Callback', @(figH, ~)loadPileAsMat(figH));
uimenu(fileMenu, 'Label',...
    'Save Pile as Potential', ...
    'Callback', @(figH, ~)savePileAsDropZone(figH));

uimenu(fileMenu, 'Label',...
    'New Harmonic Dynamics Movie', ...
    'Callback', @(figH, ~)generateTimeMovie(getPile(figH)), 'Separator','on');

uimenu(fileMenu, 'Label',...
    'New Domain Scaling Movie', ...
    'Callback', @(figH, ~)generateScalingMovie());

uimenu(fileMenu, 'Label',...
    'Continue Movie', ...
    'Callback', @(figH, ~)continueMovie());


%% Menu: Edit
editMenu = uimenu(figH, 'Label', 'Edit');
if ~isdeployed()
    uimenu(editMenu, 'Label',...
            'Export Pile to Workspace', ...
            'Callback', @(figH, ~)assignin('base', 'S', getPile(figH)));
    uimenu(editMenu, 'Label',...
            'Add Pile from Workspace', ...
            'Callback', @(figH, ~)plotPileRelax(getPile(figH)+evalin('base', 'S'), figH));
end 
    
uimenu(editMenu, 'Label',...
        'Undo', ...
        'Callback', @undo, 'Separator','on');
uimenu(editMenu, 'Label',...
        'Redo', ...
        'Callback', @redo);

   
%% Menu: Size
sizeMenu = uimenu(figH, 'Label', 'Size'); 
uimenu(sizeMenu, 'Label',...
        'Custom Domain Size', ...
        'Callback', @(figH, ~)boardSizeCustom(figH));
evenSizeMenu = uimenu(sizeMenu, 'Label', '2^N x 2^N', 'Separator','on'); 
sizes = 2.^(0:1:9);
for mySize = sizes
    uimenu(evenSizeMenu, 'Label',...
        sprintf('%g x %g', mySize, mySize), ...
        'Callback', @(figH, ~)boardSize(mySize,mySize,figH));
end
oddSizeMenu = uimenu(sizeMenu, 'Label', '2^N - 1 x 2^N - 1'); 
sizes = 2.^(1:1:9)-1;
for mySize = sizes
    uimenu(oddSizeMenu, 'Label',...
        sprintf('%g x %g', mySize, mySize), ...
        'Callback', @(figH, ~)boardSize(mySize,mySize,figH));
end

size3NMenu = uimenu(sizeMenu, 'Label', '3^N x 3^N'); 
sizes = 3.^(0:1:7);
for mySize = sizes
    uimenu(size3NMenu, 'Label',...
        sprintf('%g x %g', mySize, mySize), ...
        'Callback', @(figH, ~)boardSize(mySize,mySize,figH));
end

size3N_Menu = uimenu(sizeMenu, 'Label', '3^N - 1 x 3^N - 1'); 
sizes = 3.^(1:1:7)-1;
for mySize = sizes
    uimenu(size3N_Menu, 'Label',...
        sprintf('%g x %g', mySize, mySize), ...
        'Callback', @(figH, ~)boardSize(mySize,mySize,figH));
end

size2x3_Menu = uimenu(sizeMenu, 'Label', '2*3^N x 2*3^N'); 
sizes = 2*3.^(0:1:7);
for mySize = sizes
    uimenu(size2x3_Menu, 'Label',...
        sprintf('%g x %g', mySize, mySize), ...
        'Callback', @(figH, ~)boardSize(mySize,mySize,figH));
end

%% Menu: Mask
maskMenu = uimenu(figH, 'Label', 'Mask'); 
uimenu(maskMenu, 'Label',...
        'Custom Domain Mask', ...
        'Callback', @customMask);
masks = domainMasks();
for i=1:length(masks)
    menuH = uimenu(maskMenu, 'Label',...
        masks{i}{1}, ...
        'Callback', @(figH, ~)setMask(figH, masks{i}{1}, masks{i}{2}));
    if i==1
        menuH.Separator = 'on';
    end
end
uimenu(maskMenu, 'Label',...
        'Clear Mask', ...
        'Callback', @clearMask, 'Separator','on');

%% Menu:  Fill
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
    'Custom #particles/field', ...
    'Callback', @(figH, ~)fillAll(figH, round(askForInput(figH, 'Number of particles carried by each vertex:', 4))));
uimenu(fillMenu, 'Label',...
    'Identity', ...
    'Callback', @fillNullPile,'Separator','on');
uimenu(fillMenu, 'Label',...
    'Random', ...
    'Callback', @fillRandom);

%% Menu: Transform
transformMenu = uimenu(figH, 'Label', 'Transform'); 
uimenu(transformMenu, 'Label',...
        'Invert Pile', ...
        'Callback', @invert);
uimenu(transformMenu, 'Label',...
        '3 - Pile', ...
        'Callback', @threeMinusPile, 'Separator','on');
uimenu(transformMenu, 'Label',...
        '3 + Pile', ...
        'Callback', @threePlusPile);
uimenu(transformMenu, 'Label',...
        '6 - Pile', ...
        'Callback', @sixMinusPile);    
uimenu(transformMenu, 'Label',...
        '2 * Pile', ...
        'Callback', @twoTimesPile);

%% Menu: Drop deterministic
dropDeterministicMenu = uimenu(figH, 'Label', 'Drop Deterministic'); 

centerMenu = uimenu(dropDeterministicMenu, 'Label', 'Central vertex');
uimenu(centerMenu, 'Label',...
        'Custom amount', ...
        'Callback', @(figH, ~)dropCenter(figH, round(askForInput(figH, 'Number of particles to drop onto central vertex:'))));
sizes = 2.^(0:15);
for mySize = sizes
    name = sprintf('%g particles', mySize);
    menuH = uimenu(centerMenu, 'Label',...
        name, ...
        'Callback', @(figH, ~)dropCenter(figH, mySize));
    if mySize == sizes(1)
        menuH.Separator = 'on';
    end
end

potentialMenu = uimenu(dropDeterministicMenu, 'Label', 'Standard Potentials', 'Separator', 'on');
for h=1:length(harmonicFcts)
    harmonicFctName = harmonicFcts{h}{1};
    harmonicFctIdentifier = harmonicFcts{h}{3};
    harmonicFct = harmonicFcts{h}{2};
    subMenu = uimenu(potentialMenu, 'Label', sprintf('Potential of %s = %s', harmonicFctIdentifier, harmonicFctName));
    uimenu(subMenu, 'Label',...
            'Custom amount', ...
            'Callback', @(figH, ~)dropPotential(figH, round(askForInput(figH, sprintf('Number of times to add potential of harmonic %s:',harmonicFctName))), harmonicFct));
    sizes = 2.^(0:8);
    for mySize = sizes
        name = sprintf('%g x potential of %s = %s', mySize, harmonicFctIdentifier, harmonicFctName);
        menuH = uimenu(subMenu, 'Label',...
            name, ...
            'Callback', @(figH, ~)dropPotential(figH, mySize, harmonicFct));
        if mySize == sizes(1)
            menuH.Separator = 'on';
        end
    end
end

potentialMenu = uimenu(dropDeterministicMenu, 'Label', 'Other Potentials');
subMenu = uimenu(potentialMenu, 'Label', 'Square 45°-shaped potential');
uimenu(subMenu, 'Label',...
        'Custom amount', ...
        'Callback', @(figH, ~)dropSquare45(figH, 0.5*round(2*askForInput(figH, 'Number of times to add harmonic square 45°:'))));
sizes = 0.5:0.5:10;
for mySize = sizes
    name = sprintf('%g x Square 45° potential', mySize);
    menuH = uimenu(subMenu, 'Label',...
        name, ...
        'Callback', @(figH, ~)dropSquare45(figH, mySize));
    if mySize == sizes(1)
        menuH.Separator = 'on';
    end
end

for h=1:length(otherPotentials)
    potential = otherPotentials{h};
    subMenu = uimenu(potentialMenu, 'Label', sprintf('%s', potential.name));
    uimenu(subMenu, 'Label',...
            'Custom amount', ...
            'Callback', @(figH, ~)dropOtherPotential(figH, round(askForInput(figH, sprintf('Number of times to add %s:', potential.name))), potential.potential));
    sizes = 2.^(0:8);
    for mySize = sizes
        name = sprintf('%g x %s', mySize, potential.name);
        menuH = uimenu(subMenu, 'Label',...
            name, ...
            'Callback', @(figH, ~)dropOtherPotential(figH, mySize, potential.potential));
        if mySize == sizes(1)
            menuH.Separator = 'on';
        end
    end
end

othersMenu = uimenu(dropDeterministicMenu, 'Label', 'Others');
subMenu = uimenu(othersMenu, 'Label', 'Cross');
uimenu(subMenu, 'Label',...
        'Custom amount', ...
        'Callback', @(figH, ~)dropCross(figH, round(askForInput(figH, 'Number of particles in cross fields:'))));
sizes = 1:1:10;
for mySize = sizes
    name = sprintf('%g x cross', mySize);
    menuH = uimenu(subMenu, 'Label',...
        name, ...
        'Callback', @(figH, ~)dropCross(figH, mySize));
    if mySize == sizes(1)
        menuH.Separator = 'on';
    end
end
subMenu = uimenu(othersMenu, 'Label', 'Circle');
uimenu(subMenu, 'Label',...
        'Custom amount', ...
        'Callback', @(figH, ~)dropCircle(figH, round(askForInput(figH, 'Number of particles in circle fields:'))));
sizes = 1:1:10;
for mySize = sizes
    name = sprintf('%g x circle', mySize);
    menuH = uimenu(subMenu, 'Label',...
        name, ...
        'Callback', @(figH, ~)dropCircle(figH, mySize));
    if mySize == sizes(1)
        menuH.Separator = 'on';
    end
end

%% Menu: Drop stochastic
dropRandomMenu = uimenu(figH, 'Label', 'Drop Stochastic'); 
subMenu = uimenu(dropRandomMenu, 'Label', 'Uniform');
uimenu(subMenu, 'Label', 'Custom number', ...
        'Callback', @(figH, ~)dropRandom(figH, askForInput(figH, 'Number of particles:')));
sizes = 2.^(0:1:6);
for mySize = sizes
    menuH = uimenu(subMenu, 'Label',...
        sprintf('%g Particles', mySize), ...
        'Callback', @(figH, ~)dropRandom(figH, mySize));
    if mySize == sizes(1)
        menuH.Separator = 'on';
    end
end
sizes = 2.^(-5:5);
for mySize = sizes
    if mySize >=1
        name = sprintf('<%g Particles/Field>', mySize);
    else
        name = sprintf('<1/%g Particles/Field>', 1/mySize);
    end
    menuH = uimenu(subMenu, 'Label', name, ...
        'Callback', @(figH, ~)dropRandom(figH, [], mySize));
    if mySize == sizes(1)
        menuH.Separator = 'on';
    end
end
    
subMenu = uimenu(dropRandomMenu, 'Label', 'Radial Uniform');
uimenu(subMenu, 'Label', 'Custom number', ...
        'Callback', @(figH, ~)dropRandomCircle(figH, askForInput(figH, 'Number of particles:')));
sizes = 2.^(0:1:6);
for mySize = sizes
    uimenu(subMenu, 'Label',...
        sprintf('%g Particles', mySize), ...
        'Callback', @(figH, ~)dropRandomCircle(figH, mySize));
end
sizes = 2.^(-5:5);
for mySize = sizes
    if mySize >=1
        name = sprintf('%g*width^2 Particles', mySize);
    else
        name = sprintf('1/%g*width^2 Particles', 1/mySize);
    end
    menuH = uimenu(subMenu, 'Label',...
        name, ...
        'Callback', @(figH, ~)dropRandomCircle(figH, [], mySize));
    if mySize == sizes(1)
        menuH.Separator = 'on';
    end
end

potentialMenu = uimenu(dropRandomMenu, 'Label', 'Standard Potentials', 'Separator','on');
sizes = 2.^(-5:5);
for h=1:length(harmonicFcts)
    harmonicFctName = harmonicFcts{h}{1};
    harmonicFctIdentifier = harmonicFcts{h}{3};
    harmonicFct = harmonicFcts{h}{2};
    subMenu = uimenu(potentialMenu, 'Label', sprintf('Potential of %s = %s', harmonicFctIdentifier, harmonicFctName));
    uimenu(subMenu, 'Label',...
            'Custom amount', ...
            'Callback', @(figH, ~)dropRandomPotential(figH, round(askForInput(figH, sprintf('Number of times to add potential of harmonic %s:',harmonicFctName))), harmonicFct));
    for mySize = sizes
        if mySize >=1
            name = sprintf('<%g x potential of %s = %s>', mySize, harmonicFctIdentifier, harmonicFctName);
        else
            name = sprintf('<1/%g x potential of %s = %s>', 1/mySize, harmonicFctIdentifier, harmonicFctName);
        end
        menuH = uimenu(subMenu, 'Label',...
            name, ...
            'Callback', @(figH, ~)dropRandomPotential(figH, mySize, harmonicFct));
        if mySize == sizes(1)
            menuH.Separator = 'on';
        end
    end
end

potentialMenu = uimenu(dropRandomMenu, 'Label', 'Other Potentials');
subMenu = uimenu(potentialMenu, 'Label', 'Square 45°-shaped potential');
uimenu(subMenu, 'Label',...
        'Custom amount', ...
        'Callback', @(figH, ~)dropRandomSquare45(figH, askForInput(figH, 'Average fraction of element:')));
sizes = 2.^(-5:5);
for mySize = sizes
    if mySize >=1
        name = sprintf('<%g x Square 45°-shaped potential>', mySize);
    else
        name = sprintf('<1/%g x Square 45°-shaped potential>', 1/mySize);
    end
    menuH = uimenu(subMenu, 'Label',...
        name, ...
        'Callback', @(figH, ~)dropRandomSquare45(figH, mySize));
    if mySize == sizes(1)
        menuH.Separator = 'on';
    end
end
for h=1:length(otherPotentials)
    potential = otherPotentials{h};
    subMenu = uimenu(potentialMenu, 'Label', sprintf('%s', potential.name));
    uimenu(subMenu, 'Label',...
            'Custom amount', ...
            'Callback', @(figH, ~)dropRandomOtherPotential(figH, askForInput(figH, sprintf('Fraction of potential %s:', potential.name)), potential.potential));
    sizes = 2.^(-5:5);
    for mySize = sizes
        if mySize >=1
            name = sprintf('<%g x %s>', mySize, potential.name);
        else
            name = sprintf('<1/%g x %s>', 1/mySize, potential.name);
        end
        menuH = uimenu(subMenu, 'Label',...
            name, ...
            'Callback', @(figH, ~)dropRandomOtherPotential(figH, mySize, potential.potential));
        if mySize == sizes(1)
            menuH.Separator = 'on';
        end
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
colorbar('south', 'Ticks', (1:size(colors, 1))+0.5, 'TickLabels', [arrayfun(@(x)int2str(x), 0:size(colors, 1)-3, 'UniformOutput', false), {sprintf('%g+', size(colors, 1)-2), 'X'}], 'Units', 'centimeters', 'Tag', 'colorbar');
hold on;
plotPile(data.S, figH, true, false);
%axis off;
xlim([0.5, size(data.S, 2)+0.5]);
ylim([0.5, size(data.S, 1)+0.5]);
axH.YDir = 'reverse';
axH.XTick = [];
axH.YTick = [];
axH.Layer = 'top';
box on;

%% initialize actions
modeH = uibuttongroup('visible','off', 'Units', 'centimeters',...
    'Position', [0.25, 0.25, 5, 5], 'Title', 'Actions',...
    'Tag', 'modeGroup',...
    'BackgroundColor', [1,1,1]);
addToppleH = uicontrol('Style','Radio','String','Drop particle',...
    'Units', 'centimeters','pos',[0.25,3.75,3,0.5],'parent', modeH,'HandleVisibility','off',...
    'Tag', 'modeAdd',...
    'BackgroundColor', [1,1,1]);
uicontrol('Style','Radio','String','Remove particle',...
    'Units', 'centimeters','pos',[0.25,3,3,0.5],'parent', modeH,'HandleVisibility','off',...
    'Tag', 'modeDecrease',...
    'BackgroundColor', [1,1,1]);
uicontrol('Style','Radio','String','Wave',...
    'Units', 'centimeters','pos',[0.25,2.25,3,0.5],'parent', modeH,'HandleVisibility','off',...
    'Tag', 'modeWave',...
    'BackgroundColor', [1,1,1]);
set(modeH,'SelectedObject',addToppleH);
set(modeH,'Visible','on');

uicontrol('Style','checkbox','String','Auto-topple',...
    'Units', 'centimeters','pos',[0.25,1.25,3,0.5],'parent', modeH,'HandleVisibility','off',...
    'Tag', 'modeAutoTopple',...
    'BackgroundColor', [1,1,1], 'Value', 1);

uicontrol('Style', 'pushbutton', ...
    'String', 'Topple', 'Units', 'centimeters','parent', modeH, ...
    'Position', [0.25,0.25,3,0.75], ...
    'Callback', {@onToppleButton},...
    'Tag', 'toppleButton');

%% resize and initialize callbacks
onResize(figH);
set(figH, 'ResizeFcn', @onResize); 
set(figH, 'WindowButtonMotionFcn', {@mouseMove});

if nargout >= 1
    varargout{1} = figH;
end

end
function openMovie(figH)
    data = getData(figH);
    if isfield(data, 'movieFolder')
        [~, movieFolder] = interViewer(data.movieFolder);
    else
        [~, movieFolder] = interViewer();
    end
    if ~isempty(movieFolder)
        [movieFolder, ~, ~] = fileparts(movieFolder);
        [movieFolder, ~, ~] = fileparts(movieFolder);
        data.movieFolder = movieFolder;
        set(ancestor(figH,'figure'), 'UserData', data);
    end
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
function loadPileAsMat(figH)
    figH = ancestor(figH, 'figure');
    
    [fileName,pathName, ~] = uigetfile('*.mat', 'Load Sandpile');
    if ~ischar(fileName)
        return;
    end
    fileName = fullfile(pathName, fileName);
    if ~exist(fileName, 'file')
        return;
    end
    load(fileName, 'S');
    plotPile(S, figH);
    
    axH = findall(figH, 'Tag', 'Splot');
    xlim(axH, [0.5, size(S, 2)+0.5]);
    ylim(axH, [0.5, size(S, 1)+0.5]);
    figH.Name = sprintf('InterPile - %gx%g domain', size(S,1), size(S,2));
    onResize(figH);
end
function savePileAsDropZone(figH)
    name = inputdlg({'Potential Name:'}, 'Save Sandpile as Potential', 1, {'myPotential'});
    if isempty(name)
        return;
    end
    name = name{1};
    S = getPile(figH); %#ok<NASGU>
    if ~isdeployed()
        dirName = 'custom_potentials';
    else
        dirName = fullfile(ctfroot(), 'custom_potentials');
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
        if isinf(S(yData, xData))
            figH.Name = sprintf('InterPile - (%g, %g) -> outside domain', yData, xData);
        else
            figH.Name = sprintf('InterPile - (%g, %g) -> %g', yData, xData, S(yData, xData));
        end
    else
        figH.Name = sprintf('InterPile - %gx%g domain', size(S, 1), size(S, 2));
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
    
    Stemp = S;
    Stemp(~isinf(Stemp) & Stemp>9) = 9;
    Stemp(isinf(Stemp)) = 10;
    imageH = image(Stemp+1);
    
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
    optionsWidth = 4; %cm
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

function customMask(figH, ~)
    prompt = {'Mask name:', 'Mask formula (variables y and x measure distance from center, N and M height and width of the domain):'};
    title = 'Size of sandpile';
    dims = [1 35];
    definput = {'ellipsoid', 'x.^2/((M+1)/2).^2+y.^2/((N+1)/2).^2<1'};
    answer = inputdlg(prompt,title,dims,definput);
    if isempty(answer)
        return;
    end
    maskFct = @(y,x,N,M)eval(answer{2});
    maskName = answer{1};
    setMask(figH, maskName, maskFct)
end
function setMask(figH, maskName, maskFct)
    maskName = strrep(lower(maskName), ' ', '_');
    data = getData(figH);
    S = getPile(figH);
    width = size(S, 2);
    height = size(S, 1);
    
    try
        X=repmat((0:width-1) - (width-1)/2, height, 1);
        Y=repmat(((0:height-1) - (height-1)/2)', 1, width);
        mask = maskFct(Y,X, height, width);
    catch
        errordlg('Could not set mask (invalid function)!', 'Invalid Input');
        return;
    end
    data.currentMaskName = maskName;
    set(ancestor(figH,'figure'), 'UserData', data);
    S(isinf(S))=0;
    S(~mask) = -inf;
    plotPile(S, figH);
end
function clearMask(figH, ~)
    data = getData(figH);
    S = getPile(figH);
    
    data.currentMaskName = 'none';
    set(ancestor(figH,'figure'), 'UserData', data);
    S(isinf(S))=0;
    plotPile(S, figH);
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

function dropRandomCircle(figH, N, k)
    S = getPile(figH);
    width = size(S, 1);
    if nargin >= 3
         N = round(k*width^2);
    end
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

function dropRandomSquare45(figH, k)
    S = getPile(figH);
    width = size(S, 2);
    height = size(S, 1);
    if width ~= height
        errordlg('Only available for square domains.', 'Function not available');
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
        errordlg('Only available for square domains.', 'Function not available');
        return;
    end
    S = S + round(2*k)*double(repmat(abs((1:width)-width/2-0.5), width, 1)+repmat(abs((1:width)'-width/2-0.5), 1, width)<=width/2);
    plotPileRelax(S, figH);
end

function dropOtherPotential(figH, k, potential)
    S = getPile(figH);
    height = size(S, 1);
    width = size(S, 2);
    try
        pot = potential(height, width);
    catch ex
        dlgH = errordlg(['Cannot generate potential for current domain: ',ex.message], 'Invalid potential');
        setWindowIcon(dlgH);
        return;
    end
    if size(pot, 1) ~= height || size(pot, 2) ~= width
        dlgH = errordlg(sprintf('Potential is only available for %gx%g domains. Current domain size: %gx%g.', size(pot, 1), size(pot, 2), height, width), 'Invalid potential');
        setWindowIcon(dlgH);
        return;
    end
    S = S + k*pot;
    plotPileRelax(S, figH);
end
function dropCenter(figH, numParticles)
    S = getPile(figH);
    height = size(S, 1);
    width = size(S, 2);
    S(floor((height+1)/2), floor((width+1)/2)) = S(floor((height+1)/2), floor((width+1)/2)) + numParticles;
    plotPileRelax(S, figH);
end
function dropPotential(figH, k, harmonicFct)
    S = getPile(figH);
    height = size(S, 1);
    width = size(S, 2);
    mask = ~isinf(S);
    S = S + k*generateDropZone(harmonicFct, height, width, mask);
    plotPileRelax(S, figH);
end

function dropRandomOtherPotential(figH, k, potential)
    S = getPile(figH);
    height = size(S, 1);
    width = size(S, 2);
    try
        pot = potential(height, width);
    catch ex
        dlgH = errordlg(['Cannot generate potential for current domain: ',ex.message], 'Invalid potential');
        setWindowIcon(dlgH);
        return;
    end
    
    if size(pot, 1) ~= height || size(pot, 2) ~= width
        dlgH = errordlg(sprintf('Potential is only available for %gx%g domains. Current domain size: %gx%g.', size(pot, 1), size(pot, 2), height, width), 'Invalid potential');
        setWindowIcon(dlgH);
        return;
    end
    
    distri = toDistribution(pot);
    distriN = size(distri, 1);
    N = distriN*k;
    for i=1:N
        idx = randi(distriN);
        S(distri(idx, 1), distri(idx, 2)) = S(distri(idx, 1), distri(idx, 2)) + 1;
    end
    plotPileRelax(S, figH);
end
function dropRandomPotential(figH, k, harmonicFct)
    S = getPile(figH);
    height = size(S, 1);
    width = size(S, 2);
    mask = ~isinf(S);
    
    potential = generateDropZone(harmonicFct, height, width, mask);
    if sum(sum(potential))<=1e8
        distri = toDistribution(potential);
        distriN = size(distri, 1);
        N = distriN*k;

        for i=1:N
            idx = randi(distriN);
            S(distri(idx, 1), distri(idx, 2)) = S(distri(idx, 1), distri(idx, 2)) + 1;
        end
    else
        [distri, distriN] = toDistributionReal(potential);
        ps = distri(:, 3);
        xs = distri(:, 2);
        ys = distri(:, 1);
        N = distriN*k;
        for i=1:N
            idx = find_halfspace(ps, rand());
            S(ys(idx), xs(idx)) = S(ys(idx), xs(idx)) + 1;
        end
    end
    plotPileRelax(S, figH);
end
function X = find_halfspace(Y,T)
    % returns the index of the first element in the ascending array Y which
    % is greater or equal to T, i.e. a value of X s.t. Y(X)>=T, Y(X-1)<T
    % in the ASCENDING array data that is
    % <x using a simple half space search
    L = 1;
    R = length(Y);
    while L < R
        M = floor((L + R)/2);
        if T < Y(M)
            R = M;
        elseif T > Y(M)
            L = M + 1;
        else
            X = M;
            return;
        end
    end
    X = L;
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
function fraction = askForInput(figH, text, defaultNum)
    if nargin < 2
        text = 'Number of particles to drop:';
    end
    data = getData(figH);
    if nargin < 3
        if ~isfield(data, 'UserInput')
            data.UserInput = '1';
        end
        defaultNum = data.UserInput;
    elseif ~ischar(defaultNum)
        defaultNum = num2str(defaultNum);
    end
    prompt = {text};
    title = 'User Input';
    dims = [1 35];
    definput = {defaultNum};
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
    figH.Name = sprintf('InterPile - %gx%g domain', height, width);
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
    S = getPile(figH);
    Sinf = isinf(S);
    S = ones(size(getPile(figH)))*number;
    S(Sinf) = -inf;
    plotPileRelax(S, figH);
end

function fillNullPile(figH, ~)
    S = getPile(figH);
    mask = ~isinf(S);
    if all(all(mask))
        S = nullPile(size(S, 1), size(S, 2));
    else
        data = getData(figH);
        if isfield(data, 'currentMaskName')
            currentMaskName = data.currentMaskName;
        else
            currentMaskName = 'unknownMask';
        end
        S = nullPile(size(S, 1), size(S, 2), mask, currentMaskName);
    end
    plotPile(S, figH);
end
function fillRandom(figH, ~)
    S = getPile(figH);
    S = randi(4,size(S, 1),size(S, 2))-1;
    plotPile(S, figH);
end