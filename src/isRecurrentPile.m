function isRecurrent = isRecurrentPile(S)
% Algorithm according to Figur 6.3 in 
% Járai, Antal A. "The Sandpile Cellular Automaton." Probabilistic Cellular Automata. Springer, Cham, 2018. 79-88.
if nargin <1
    S = ones(15,15)*3;
    S(7,2) = 4;
    S(4,6) = 4;
    S = relaxPile(S);
    %S(5,5) = S(5,5) - 1;
    plotSandPile(S);
end

% Filter to count number of remaining neighbours
neighbourFilter = zeros(3,3);
neighbourFilter(1, 2)= 1;
neighbourFilter(2, 1)= 1;
neighbourFilter(2, 3)= 1;
neighbourFilter(3, 2)= 1;

% Initially, all nodes are remaining
isRecurrent = false;
remaining = ones(size(S));
lastRemaining = inf;
numRemaining = size(S, 1) * size(S, 2);
while numRemaining < lastRemaining
    lastRemaining = numRemaining;
    % Update remaining nodes
    remaining = double(S < imfilter(remaining, neighbourFilter));
    % check if no node is remaining anymore
    numRemaining = sum(sum(remaining));
    if numRemaining == 0
        isRecurrent = true;
        break;
    end
end

return;
