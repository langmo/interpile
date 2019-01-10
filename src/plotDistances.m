function varargout = plotDistances(varargin)
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

recurrent = isRecurrentPile(S);
if nargout >= 1
    varargout{1} = recurrent;
end
% if ~recurrent
%     return;
% end

N = size(S, 1);
M = size(S, 2);
G = pile2graph(S);
if max(N,M) <=64
    D = distances(G);
    %% Vertical distances
    yInd = 1:N-1;
    Dy = zeros(N-1, M);
    for x = 1:M
        Dy(yInd+(x-1)*(N-1)) = D(sub2ind([N*M+1, N*M+1], yInd+(x-1)*N, yInd+1+(x-1)*N));
    end
    %% Horizontal distances
    xInd = 1:N:N*(M-1);
    Dx = zeros(N, M-1);
    for y = 1:N
        Dx(xInd+(y-1)) = D(sub2ind([N*M+1, N*M+1], xInd+(y-1), xInd+(y-1)+N));
    end
else
    %% Vertical distances
    X = repmat(1:M, N, 1);
    Y = repmat((1:N)', 1, M);
    Dy = arrayfun(@(y,x)distances(G, y+(x-1)*N, 1+y+(x-1)*N), Y(1:end-1, :), X(1:end-1, :));
    Dx = arrayfun(@(y,x)distances(G, y+(x-1)*N, y+x*N), Y(:, 1:end-1), X(:, 1:end-1));
end
%% Compose image

T = ones(2*N-1, 2*M-1);
T(1:2:2*N, 2:2:2*(M-1)) = Dx;
T(2:2:2*(N-1), 1:2:2*M) = Dy;

% pixels diagonally between two nodes
T(2:2:2*(N-1), 2:2:2*(M-1)) = max(max(...
    max(min(Dy(:, 1:end-1),Dy(:, 2:end)), min(Dx(1:end-1, :),Dx(2:end, :))),...
    max(min(Dy(:, 1:end-1),Dx(1:end-1, :)), min(Dy(:, 1:end-1),Dx(2:end, :)))),...
    max(min(Dy(:, 2:end),Dx(1:end-1, :)), min(Dy(:, 2:end),Dx(2:end, :)))...
    );

% pixels where the nodes are
T(3:2:2*(N-1)-1, 3:2:2*(M-1)-1) = max(...
    max(min(Dy(1:end-1, 2:end-1),Dx(2:end-1, 1:end-1)) , min(Dy(2:end, 2:end-1), Dx(2:end-1, 2:end))),...
    max(min(Dy(1:end-1, 2:end-1),Dx(2:end-1, 2:end)) , min(Dy(2:end, 2:end-1), Dx(2:end-1, 1:end-1)))...
    );
%% plot
Tlog = log10(T);
maxT = max(Tlog(~isinf(Tlog)));
img = round(Tlog/maxT*255);
img(isinf(Tlog)) = 256;
plotH = image(img);
set(plotH,'HitTest','off');
colormap(axH, [flipud(gray(255)); 0.5,0,0]);
xlim(axH, [0.5, size(Tlog, 2)+0.5]);
ylim(axH, [0.5, size(Tlog, 1)+0.5]);
if ~isempty(cbh)
    ticks = 0:maxT/2:maxT;
    if isempty(ticks)
        ticks = [0,1,2];
    end
    tickLabels = arrayfun(@(x)sprintf('%1.2fx10^%g', 10^(x-floor(x)), floor(x)), ticks, 'UniformOutput', false);
    
    cbh.Ticks = 1+round(ticks./ticks(end)*255);
    cbh.TickLabels = tickLabels;
end
end

