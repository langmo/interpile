function [C, Cd, T, Td, numSinkTopples] = dualNullpile(C, Cd)
if nargin < 3 || isempty(T)
    T = 1./~isinf(C)-1;
end
if nargin < 4 || isempty(Td)
    Td = 1./~isinf(Cd)-1;
end

oldC = C;
oldCd = Cd;
oldT = T;
oldTd = Td;

% toppling the sink (of the non-dual domain) is equivalent to
% toppling each vertex of the outer boundary of the non-dual graph
outerBoundary = isinf(C) & ...
    (~isinf(Cd(1:size(Cd,1)-1, 1:size(Cd,2)-1))...
     |~isinf(Cd(2:size(Cd,1), 2:size(Cd,2))));
%T(topples)=0;
numSinkTopples = 0;
while true
    % topple the sink
    %C = C - 4*topples;
    Cd(1:size(Cd,1)-1, 1:size(Cd,2)-1) = Cd(1:size(Cd,1)-1, 1:size(Cd,2)-1) + 2*outerBoundary;
    Cd(2:size(Cd,1), 2:size(Cd,2)) = Cd(2:size(Cd,1), 2:size(Cd,2)) + 2*outerBoundary;
    %T = T + topples;

    % relax the pile
    [C, Cd, T, Td] = dualRelax(C, Cd, T, Td);
    
    % if anything changed, accept toppling of the sink, otherwise reject.
    if any(any(C-oldC))
        oldC = C;
        oldCd = Cd;
        oldT = T;
        oldTd = Td;
        numSinkTopples = numSinkTopples +1;
    else
        C = oldC;
        Cd = oldCd;
        T = oldT;
        Td = oldTd;
        break;
    end
end

