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

% how often do we topple in the current step?
topplings = floor(max(S, 0)/4);
% how often do we topple in total?
H = topplings;
while any(any(topplings))
    S = S - 4*topplings;
    % increase right
    S(:, 2:end) = S(:, 2:end)+topplings(:, 1:end-1);
    % increase left
    S(:, 1:end-1) = S(:, 1:end-1)+topplings(:, 2:end);
    % increase bottom
    S(2:end, :) = S(2:end, :)+topplings(1:end-1, :);
    % increase top
    S(1:end-1, :) = S(1:end-1, :)+topplings(2:end, :);
    
    
    topplings = floor(max(S, 0)/4);
    H = H + topplings;
end

if nargout == 0
    printPile(S);
elseif nargout > 1
    varargout{1} = H;
end


end