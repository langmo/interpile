function [S, varargout] = relaxPile(S)
% Relaxes and returns the provided sandpile S.
% Usage:
%   S = relaxPile(S)
%   [S, H] = relaxPile(S)
% Arguments:
%   S ... sandpile to relax
% Returns:
%   S ... relaxed sandpile
%   H ... toppling matrix

% We use an iterative algorithm where in each step we topple each vertex
% according to its current(!) particle count.
% To do so, we first construct a matrix determining how often each vertex topples,
% and then use filtering to determine where to add particles.
filter = [...
    0,1,0;...
    1,0,1;...
    0,1,0];

% how often do we topple in the current step?
topplings = floor(max(S, 0)/4);
% how often do we topple in total?
H = topplings;
while any(any(topplings))
    increases = imfilter(topplings, filter);
    S = S -topplings*4 + increases;
    topplings = floor(max(S, 0)/4);
    H = H + topplings;
end

if nargout == 0
    plotSandPile(S);
elseif nargout > 1
    varargout{1} = H;
end


end