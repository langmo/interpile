function varargout = spanningTreeViewer(varargin)
% interViewer - The InterPile movie viewer.
%
% Usage:
%   spanningTreeViewer()
%       Opens file chooser dialoge box to select the config file of the
%       InterPile movie to open.
%   spanningTreeViewer(configPath)
%       Opens the InterPile movie with the respective movie configuration
%       pile located at the specified path.
%   figH = spanningTreeViewer(...)
%       Returns the handle to the movie viewer figure.

% Copyright (C) 2019 Moritz Lang
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
if nargin>=1 && ~isempty(varargin{1})
    configFile = varargin{1};
else
    configFile = cd();
end

if ischar(configFile) && exist(configFile, 'dir')
    [filename, pathname, ~] = uigetfile({'config.mat', 'InterPile Movies (*.mat)'}, 'Select movie configuration file', fullfile(configFile, 'config.mat'));
    if isempty(filename) || (isnumeric(filename) && numel(filename) == 1 && filename == 0)
        if nargout >= 1
            varargout{1} = [];
        end
        if nargout >= 2
            varargout{2} = [];
        end
        return;
    end
    configFile = fullfile(pathname, filename);
end


%% Load Configuration
if isstruct(configFile)
    data = configFile;
else
    mode = []; % forward declaration to avoid bug in Matlab where Matlab thinks mode is a function and not a variable.
    load(configFile);
    [folder, ~, ~] = fileparts(configFile);
    [parentFolder, ~, ~] = fileparts(folder);
    data = struct();
    data.configFile = configFile;
    data.fileTemplate = fileTemplate;
    if exist('numRounds', 'var') && ~isempty(numRounds)
        data.numRounds = numRounds;
    else
        data.numRounds = 1;
    end
    data.numSteps = numSteps;
    data.folder = folder;
    data.parentFolder = parentFolder;
    data.stepsPerRound = stepsPerRound;
    if exist('mode', 'var') && ~isempty(mode)
        data.mode = mode;
    elseif exist('excitation', 'var')
        data.mode = 'stoch';
    elseif exist('domainSizes', 'var')
        data.mode = 'scaling';
    else
        data.mode = 'det';
    end
    if strcmpi(data.mode, 'mask')
        data.currentIndex = 1;
        data.maskVariables = maskVariables;
    elseif strcmpi(data.mode, 'scaling')
        data.domainSizes = domainSizes;
        data.domainTimes = domainTimes;
        data.currentIndex = 1;
    else
        data.currentIndex = 0;
    end
end
colors = pileColors();

%% Create figure
figH = figure('Color', ones(1,3), 'NumberTitle', 'off', 'Units', 'pixels', 'MenuBar', 'none',...
    'BusyAction', 'cancel');

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
        'Callback', @(figH, ~)openMovie(figH));
uimenu(fileMenu, 'Label',...
        'Clone Window', ...
        'Callback', @(figH, ~)interViewer(getData(figH)));
uimenu(fileMenu, 'Label',...
    'Edit Pile in InterPile', ...
    'Callback', @(figH, ~)interPile(getPile(figH)), 'Separator','on');
uimenu(fileMenu, 'Label',...
    'Display Pile as Image', ...
    'Callback', @(figH, ~)printPile(getPile(figH)));


% Generate movie
generateMenu = uimenu(figH, 'Label', 'Export'); 
uimenu(generateMenu, 'Label',...
        'Generate Movie', ...
        'Callback', @(figH, ~)generateMovieDlg(figH));
uimenu(generateMenu, 'Label',...
    'Save Pile as Image', ...
    'Callback', @(figH, ~)savePileAsImage(figH), 'Separator','on');
uimenu(generateMenu, 'Label',...
    'Save Pile as Mat', ...
    'Callback', @(figH, ~)savePileAsMat(figH));

%% Time bar
timeField = uicontrol('Style', 'slider', ...
    'Tag', 'timeField',...
    'Units', 'centimeters');
timeField.Max = 1;
if strcmpi(data.mode, 'scaling') || strcmpi(data.mode, 'mask')
    timeField.Min = 1/data.numSteps;
else
    timeField.Min = 0;
end
timeField.Value = data.currentIndex/data.numSteps;
timeField.SliderStep = [1,1]./data.numSteps;
timeField.Callback = @(figH, ~)timeChanged(figH);

uicontrol('Style', 'text', 'String', 'Time X.XX (XXX of XXX)',...
    'Tag', 'timeText',...
    'Units', 'centimeters', 'HorizontalAlignment', 'center', 'Background', ones(1,3));

%% Main plot
axH = axes('Tag', 'Splot', 'Units', 'pixels');
colormap(colors)
colorbar('north', 'Ticks', (1:size(colors, 1))+0.5, 'TickLabels', [arrayfun(@(x)int2str(x), 0:size(colors, 1)-3, 'UniformOutput', false), {sprintf('%g+', size(colors, 1)-2), 'X'}], 'Units', 'centimeters', 'Tag', 'colorbar');
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

if nargout >= 1
    varargout{1} = figH;
end
if nargout >= 2
    varargout{2} = data.configFile;
end

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
    if index < 1 && (strcmpi(figH.UserData.mode, 'scaling') || strcmpi(figH.UserData.mode, 'mask'))
            index = 1;
    elseif index < 0
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
        case {'downarrow', 'pagedown'}
            setIndex(figH, getIndex(figH)+10);
        case {'uparrow', 'pageup'}
            setIndex(figH, getIndex(figH)-10);
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
        if isinf(S(yData, xData))
            figH.Name = sprintf('InterPile Viewer - (%g, %g) -> outside domain', yData, xData);
        else
            figH.Name = sprintf('InterPile Viewer - (%g, %g) -> %g', yData, xData, S(yData, xData));
        end
    else
        [folder, ~, ~] = fileparts(figH.UserData.configFile);
        [~, folder, ext] = fileparts(folder);
        folder = [folder, ext];
        idx = strfind(folder, '_frames');
        if ~isempty(idx)
            folder = folder(1:idx(end)-1);
        end
        figH.Name = sprintf('InterPile Viewer - %s', folder);
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
    [parentY, parentX, W] = toSpanningTree(S);
    if 1
        
        Y=repmat((1:size(S, 1))', 1, size(S, 2));
        X=repmat(1:size(S, 2), size(S, 1), 1);
        idx = parentX ~= 0;
        
        X = X(idx)';
        Y = Y(idx)';
        W = W(idx)';
        parentX = parentX(idx)';
        parentY = parentY(idx)';
        
        numColors = 10;
        minThreshold = 1;
        maxThreshold = 1000;
        thresholds = 10.^(log10(minThreshold):(log10(maxThreshold)-log10(minThreshold))/(numColors-1):log10(maxThreshold));
        colors = flipud(gray(numColors+1));
        colors(1, :)=[];
        categories = arrayfun(@(i){thresholds(i), colors(i, :)}, (1:numColors)', 'UniformOutput', false);
        categories = vertcat(categories{:});
%         categories = {...
%             0, 0.8*ones(1,3);...
%             5, 0.4*ones(1,3);...
%             10, 0*ones(1,3);...
%             50, [0,1,0];...
%             100, [1,0,0]};
        alreadySelected = false(size(X));
        for c=length(categories):-1:1
            select = W>=categories{c, 1} & ~alreadySelected;
            alreadySelected = alreadySelected | select;
            numSelect = sum(select);
            dataX = NaN(numSelect*3, 1);
            dataY = NaN(numSelect*3, 1);

            dataX(1:3:end-2) = X(select);
            dataX(2:3:end-1) = parentX(select);
            dataY(1:3:end-2) = Y(select);
            dataY(2:3:end-1) = parentY(select);
            line(dataX, dataY, 'Color',categories{c,2},'LineStyle','-');
        end

        
    elseif 1
        Y=repmat((1:size(S, 1))', 1, size(S, 2));
        X=repmat(1:size(S, 2), size(S, 1), 1);
        idx = parentX ~= 0;
        
        X = X(idx)';
        Y = Y(idx)';
        parentX = parentX(idx)';
        parentY = parentY(idx)';

        dataX = NaN(length(X)*3, 1);
        dataY = NaN(length(X)*3, 1);

        dataX(1:3:end-2) = X;
        dataX(2:3:end-1) = parentX;
        dataY(1:3:end-2) = Y;
        dataY(2:3:end-1) = parentY;
        line(dataX, dataY, 'Color','black','LineStyle','-');
        
    else
        W = zeros(size(S));
        for yStart=1:size(S, 1)
            for xStart=1:size(S, 2)
                x=xStart;
                y=yStart;
                while parentX(y,x)>0
                    xOld = x;
                    yOld = y;
                    x=parentX(yOld,xOld);
                    y=parentY(yOld,xOld);
                    W(y,x) = W(y,x)+1;
                end
            end
        end
        W=round(W./10);
        W(W>9) = 9;
        image(W+1);
    end
%     Stemp = S;
%     Stemp(~isinf(Stemp) & Stemp>9) = 9;
%     Stemp(isinf(Stemp)) = 10;
%     image(Stemp+1);
    xlim([0.5, size(S, 2)+0.5]);
    ylim([0.5, size(S, 1)+0.5]);

    setPile(figH, S);
    
    timeTextH = findall(figH, 'Tag', 'timeText');
    if strcmpi(figH.UserData.mode, 'scaling')
        domainSize = figH.UserData.domainSizes(figH.UserData.currentIndex, :);
        domainTime = figH.UserData.domainTimes(figH.UserData.currentIndex, :);
        timeTextH.String = sprintf('Size: %gx%g, Time: %g (Frame: %g/%g)', domainSize(1), domainSize(2), domainTime,...
            figH.UserData.currentIndex,figH.UserData.numSteps);
    elseif strcmpi(figH.UserData.mode, 'mask')
        maskVariables = figH.UserData.maskVariables;
        timeTextH.String = sprintf('Transformation progress: %05.2f%% (Frame: %g/%g)', (figH.UserData.currentIndex-1)/(length(maskVariables)-1)*100,...
            figH.UserData.currentIndex,figH.UserData.numSteps);
    else
        timeTextH.String = sprintf('Time: %1.7f (Frame: %g/%g)', (figH.UserData.currentIndex)/(figH.UserData.stepsPerRound),...
            figH.UserData.currentIndex,figH.UserData.numSteps);
    end
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
function openMovie(figH)
    data = getData(figH);
    interViewer(data.parentFolder)
end
function generateMovieDlg(figH)
    data = getData(figH);
    assembleMovieDialog([], data.configFile)
end
function S = getPile(figH)
    data = getData(figH);
    S = data.S;
end