function fgh = printPile(S, fgh, rawPlot, lessColors, borderWidth)

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

if nargin < 1
    S = evalin('base', 'S');
end
if nargin < 3 || isempty(rawPlot)
    rawPlot = false;
end
if nargin < 4 || isempty(lessColors)
    lessColors = false;
end
if nargin < 5 || isempty(borderWidth)
    borderWidth = 0.5;
end
colors = pileColors();
if lessColors
   colors(5:end, :) = []; 
end

if ~strcmpi(class(S), 'double')
    S = double(S);
end

if nargin >= 2 && ~isempty(fgh) && ishandle(fgh)
    figure(fgh);
    plotH = get(fgh.CurrentAxes, 'Children');
    if all(size(get(plotH, 'CData'))==size(S))
        set(plotH, 'CData', S+1);
    else
        delete (plotH);
        if rawPlot
            image(S+1);
            colormap(colors)
            xlim([0.5, size(S, 2)+0.5]);
            ylim([0.5, size(S, 1)+0.5]);
            axH = gca();
            axH.YDir = 'reverse';
            axis off;
            %fgh.CurrentAxes.Position = [1,1,size(S, 2), size(S, 1)];
        else
            width = 20;
            height = width/size(S, 2)*size(S, 1);
        
            image(S+1);
            colormap(colors)

            cbh = colorbar('southoutside', 'Ticks', (1:size(colors, 1))+0.5, 'TickLabels', arrayfun(@(x)int2str(x), 0:size(colors, 1)-1, 'UniformOutput', false), 'Units', 'centimeters', 'Tag', 'colorbar');
            xlim([0.5, size(S, 2)+0.5]);
            ylim([0.5, size(S, 1)+0.5]);
            
            fgh.CurrentAxes.YDir = 'reverse';
            fgh.CurrentAxes.XTick = [];
            fgh.CurrentAxes.YTick = [];
            cbh.Position = [borderWidth+width-min(width, size(colors, 1)*6/10),0.7,min(width, size(colors, 1)*6/10), 0.5];
        end
    end
else
    if rawPlot
        fgh = figure('Units', 'pixels', 'Position', [3,100, size(S, 2), size(S, 1)], 'Color', ones(1,3));
        try
            setWindowIcon();
        catch
            % do nothing, default icon is fine, too.
        end
        image(S+1);
        colormap(colors)
        xlim([0.5, size(S, 2)+0.5]);
        ylim([0.5, size(S, 1)+0.5]);
        axH = gca();
        axH.YDir = 'reverse';
        axis off;
        axH.Units = 'pixels';
        axH.Position = [1,1,size(S, 2), size(S, 1)];

    else
        width = 20;
        height = width/size(S, 2)*size(S, 1);
        
        fgh = figure('Units', 'centimeters', 'Position', [3,3, width+2*borderWidth, height+1.5+borderWidth], 'Color', ones(1,3));
        try
            setWindowIcon();
        catch
            % do nothing, default icon is fine, too.
        end
        image(S+1);
        colormap(colors)
        
        cbh = colorbar('southoutside', 'Ticks', (1:size(colors, 1))+0.5, 'TickLabels', arrayfun(@(x)int2str(x), 0:size(colors, 1)-1, 'UniformOutput', false), 'Units', 'centimeters', 'Tag', 'colorbar');
        xlim([0.5, size(S, 2)+0.5]);
        ylim([0.5, size(S, 1)+0.5]);
        axH = gca();
        axH.YDir = 'reverse';
        axH.XTick = [];
        axH.YTick = [];
        axH.Layer = 'top';
        axH.Units = 'centimeters';
        cbh.Units = 'centimeters';
        axH.Position = [borderWidth,1.5,width, height];


        cbh.Position = [borderWidth+width-min(width, size(colors, 1)*6/10),0.7,min(width, size(colors, 1)*6/10), 0.5];
    end
end

end

