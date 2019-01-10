function varargout = plotPile(varargin)
currentInput = 1;
if ishandle(varargin{currentInput})
    axH = varargin{1};
    currentInput = currentInput+1;
end
S = varargin{currentInput};
currentInput = currentInput+1;
if nargin >= currentInput && ishandle(varargin{currentInput})
    cbh = varargin{currentInput};
else
    cbh = [];
end

if nargout >= 1
    varargout{1} = isRecurrentPile(S);
end

S(~isinf(S) & S>9) = 9;
S(isinf(S)) = 10;
imageH = image(S+1);
set(imageH,'HitTest','off');
xlim(axH, [0.5, size(S, 2)+0.5]);
ylim(axH, [0.5, size(S, 1)+0.5]);

colors = pileColors();
colormap(axH, colors)
if ~isempty(cbh)
    cbh.Ticks = (1:size(colors, 1))+0.5;
    cbh.TickLabels = [arrayfun(@(x)int2str(x), 0:size(colors, 1)-3, 'UniformOutput', false), {sprintf('%g+', size(colors, 1)-2), 'X'}];
end
end

