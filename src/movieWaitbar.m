function varargout = movieWaitbar(varargin)
% movieWaitbar - waitbar for movie generation, with option to stop.
% Usage:
%   movieWaitbar(progress)
%       Creates a new waitbar showing the given progress and with the text
%       message 'Processing...'.
%   movieWaitbar(progress, message)
%       Creates a new waitbar showing the given progress and the given text
%       message.
%   movieWaitbar(progress, wbh, message)
%       Updates the waitbar with the handle wbh to the given progress and
%       message.
%   wbh = movieWaitbar(...)
%       Returns a handle to the waitbar.
% Notes:
%   The waitbar can be programmatically closed using its handle with the
%   command close(wbh).
%   If the user presses the stop button, the first call to movieWaitbar
%   using the respective waitbar handle wbh will result in an error with
%   message ID 'InterPile:UserStop'. Catch this error to programmatically
%   handle user stop requests.
%
% See also WAITBAR

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

%% Configuration
width = 300;
hMargin = 15;
vMargin = 15;
heigth = 60;

%% Process input
if nargin < 1
    progress = 0.2;
else
    progress = varargin{1};
end
if nargin < 2
    message = 'Processing...';
    wbh = [];
elseif nargin < 3
    message = varargin{2};
    wbh = [];
else
    message = varargin{3};
    wbh = varargin{2};
end

if isempty(wbh) || ~ishandle(wbh)
    wbh = figure('WindowStyle', 'modal', 'Color', ones(1,3));
    set(wbh, 'DockControls', 'off');
    set(wbh, 'ToolBar', 'none');
    set(wbh, 'MenuBar', 'none');
    set(wbh, 'Resize', 'off');
    set(wbh, 'Name', 'Processing movie');
    set(wbh, 'NumberTitle', 'off');
    set(wbh, 'NextPlot', 'new');
    try
        setWindowIcon();
    catch
        % Do nothing, default Matlab icon is OK, too.
    end
    
    wbhStateHandel = uicontrol('Style','text', ... 
        'Units','pixel', ... 
        'BackgroundColor',[.4 .4 .4], ... 
        'ForegroundColor',[.95 .95 .95], ...
        'HorizontalAlignment', 'right',...
        'String', '', 'Tag', 'state'); 
    wbhProgressStringHandel = uicontrol('Style','text', ... 
        'Units','pixel', ... 
        'BackgroundColor',0.9*[1,1,1], ... 
        'ForegroundColor',[.2 .2 .2], ...
        'HorizontalAlignment', 'right',...
        'String', '', 'Tag', 'progress');
    wbhTextHandel = uicontrol('Style','text', ... 
                  'Units','pixel', ... 
                  'Position',[hMargin, 45+vMargin, width, 16],...
                  'Backgroundcolor',ones(1,3), ... 
                  'HorizontalAlignment', 'left', ...
                  'String', '', 'Tag', 'text'); 
              
    wbhStopButton = uicontrol('Style', 'pushbutton',...
        'Units', 'pixels',...
        'BackgroundColor', ones(1,3),...
        'String', 'Stop',...
        'Position', [width + hMargin-70, 10, 70, 20],...
        'UserData', false,...
        'Callback', @(wbhStopButton,~,~)set(wbhStopButton, 'UserData', true), 'Tag', 'stopButton');
else
    figure(wbh);
    wbhStateHandel = findall(wbh, 'Tag', 'state');
    wbhProgressStringHandel = findall(wbh, 'Tag', 'progress');
    wbhTextHandel = findall(wbh, 'Tag', 'text');
    wbhStopButton = findall(wbh, 'Tag', 'stopButton');
end

% Check if user requested stop


progressPos = round((width-2)*progress);
if progressPos < 0.01
    progressPos = 0.01;
end
wbhTextHandel.String = message;
wbhProgressStringHandel.Position = [hMargin+1+progressPos, 25+vMargin+1, width-progressPos-2, 20-2];
wbhStateHandel.Position = [hMargin+1, 25+vMargin+1, progressPos, 20-2];

pos = get(wbh, 'Position');
pos(3) = width + 2 * hMargin;
pos(4) = heigth + 2 * vMargin;
set(wbh, 'Position', pos);
set(wbh, 'Name', sprintf('Waitbar (%g%%)', round(progress*100)));

if progressPos > 40
    wbhStateHandel.String = sprintf('%g%% ', round(progress*100));
    wbhProgressStringHandel.String = '';
else
    wbhStateHandel.String = '';
    wbhProgressStringHandel.String = sprintf('%g%% ', round(progress*100));
end

if nargout > 0
    varargout{1} = wbh;
end

drawnow();
if wbhStopButton.UserData
    wbhStopButton.UserData = false;
    error('InterPile:UserStop', 'Stop requested by user.');
end