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


N = size(S, 1);
M = size(S, 2);

left = spdiags([ones(N,1),-4*ones(N,1), ones(N,1)], [-1,0,1], N, N);
right = spdiags(ones(M,2), [-1,1], M, M);

% how often do we topple in the current step?
topplings = floor(max(S, 0)/4);
% how often do we topple in total?
H = zeros(size(topplings));
while any(any(topplings))
    H = H + topplings;
    S = S + left * topplings + topplings * right;
    topplings = floor(max(S, 0)/4);
end

if nargout == 0
    printPile(S);
elseif nargout > 1
    varargout{1} = H;
end

end