function varargout = plotTree(varargin)
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

[parentY, parentX, W] = pile2tree(S);
if nargout >= 1
    varargout{1} = all(all(~isnan(parentX)));
end
Y=repmat((1:size(S, 1))', 1, size(S, 2));
X=repmat(1:size(S, 2), size(S, 1), 1);

sources = parentX == 0 | isnan(parentX);
parentX(sources) = NaN;
parentY(sources) = NaN;

numColors = 10;
minThreshold = 1;
maxThreshold = 1000*numel(S)/255^2;
thresholds = 10.^(log10(minThreshold):(log10(maxThreshold)-log10(minThreshold))/(numColors-1):log10(maxThreshold));
colors = flipud(gray(numColors+1));
colors(1, :)=[];
alreadySelected = false(size(X));
for c=numColors:-1:1
    select = W>=thresholds(c) & ~alreadySelected;
    alreadySelected = alreadySelected | select;
    numSelect = sum(sum(select));
    dataX = NaN(numSelect*3, 1);
    dataY = NaN(numSelect*3, 1);

    dataX(1:3:end-2) = X(select);
    dataX(2:3:end-1) = parentX(select);
    dataY(1:3:end-2) = Y(select);
    dataY(2:3:end-1) = parentY(select);
    plotH = line(axH, dataX, dataY, 'Color' ,colors(c,:),'LineStyle','-');
    set(plotH,'HitTest','off');
end
xlim(axH, [0.5, size(S, 2)+0.5]);
ylim(axH, [0.5, size(S, 1)+0.5]);

if ~isempty(cbh)
    colormap(axH, colors);
    ticks = [1,5,length(colors)];
    tickLabels = arrayfun(@(x)sprintf('%1.2fx10^%g', 10^(log10(x)-floor(log10(x))), floor(log10(x))), thresholds(ticks), 'UniformOutput', false);
    
    cbh.Ticks = 0.5+ticks;
    cbh.TickLabels = tickLabels;
end
end

