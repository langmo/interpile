function fgh = printPile(S, fgh, rawPlot, lessColors, borderWidth)
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
if nargin >= 2 && ~isempty(fgh) && ishandle(fgh)
    set(get(gca(), 'Children'), 'CData', S+1);
else
    colors = pileColors();
    if lessColors
       colors(5:end, :) = []; 
    end
    if rawPlot
        fgh = figure('Units', 'pixels', 'Position', [3,100, size(S, 2), size(S, 1)], 'Color', ones(1,3));
        try
            setWindowIcon();
        catch
            % do nothing, default icon is fine, too.
        end
        %fgh.PaperSize = [size(S, 2), size(S, 1)];
        %fgh.PaperPosition = [1,1,size(S, 2), size(S, 1)];
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

