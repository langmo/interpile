function [C, Cd, T, Td] = dualExtend(C, Cd, Tsub, Tdsub, numSinkTopples)

T = 1./~isinf(C)-1;
%T(~isinf(Tsub))=Tsub(~isinf(Tsub));
Td = 1./~isinf(Cd)-1;
%Td(~isinf(Tdsub))=Tdsub(~isinf(Tdsub));

% toppling the sink (of the non-dual domain) is equivalent to
% toppling each vertex of the outer boundary of the non-dual graph
outerBoundary = isinf(C) & ...
    (~isinf(Cd(1:size(Cd,1)-1, 1:size(Cd,2)-1))...
     |~isinf(Cd(2:size(Cd,1), 2:size(Cd,2))));
firstIteration = true;
numAdditionalTopplings = 1;

oldC = C;
oldCd = Cd;
oldT = T;
oldTd = Td;
while true
    
    if firstIteration
        firstIteration = false;
        % take over topplings of the sub-graph
        topplesSink = numSinkTopples;
        topples = Tsub;
        topples(isinf(topples))=0;
        
        topplesd = Tdsub;
        topplesd(isinf(topplesd))=0;
    else
        topplesSink = numAdditionalTopplings;
        topples = ~isinf(Tsub) * numAdditionalTopplings;
        topplesd = ~isinf(Tdsub) * 2 * numAdditionalTopplings;
    end
    
     %C = C - 4*topples;
    Cd(1:size(Cd,1)-1, 1:size(Cd,2)-1) = Cd(1:size(Cd,1)-1, 1:size(Cd,2)-1) + 2*topplesSink*outerBoundary;
    Cd(2:size(Cd,1), 2:size(Cd,2)) = Cd(2:size(Cd,1), 2:size(Cd,2)) + 2*topplesSink*outerBoundary;
        
    C = C - 4*topples;
    Cd(1:size(Cd,1)-1, 1:size(Cd,2)-1) = Cd(1:size(Cd,1)-1, 1:size(Cd,2)-1) + 2*topples;
    Cd(2:size(Cd,1), 2:size(Cd,2)) = Cd(2:size(Cd,1), 2:size(Cd,2)) + 2*topples;
    T = T + topples;

    Cd = Cd - 2*topplesd;
    C= C + topplesd(1:size(Cd,1)-1, 2:size(Cd,2));
    C= C + topplesd(2:size(Cd,1), 1:size(Cd,2)-1);
    Td = Td + topplesd;


    % topple the rest
    anyTopples = true;
    anyTopplesd = true;
    while anyTopples || anyTopplesd
        %% normal toppling
        topples = floor(C/4);
        topples(isinf(topples) | ~isinf(Tsub))=0;

        anyTopples = any(any(topples));
        if anyTopples
            C = C - 4*topples;
            Cd(1:size(Cd,1)-1, 1:size(Cd,2)-1) = Cd(1:size(Cd,1)-1, 1:size(Cd,2)-1) + 2*topples;
            Cd(2:size(Cd,1), 2:size(Cd,2)) = Cd(2:size(Cd,1), 2:size(Cd,2)) + 2*topples;
            T = T + topples;
        end
        %% dual toppling
        topplesd = floor(Cd/2);
        topplesd(isinf(topplesd) | ~isinf(Tdsub))=0;

        anyTopplesd = any(any(topplesd));
        if any(any(topplesd))
            Cd = Cd - 2*topplesd;
            C= C + topplesd(1:size(Cd,1)-1, 2:size(Cd,2));
            C= C + topplesd(2:size(Cd,1), 1:size(Cd,2)-1);
            Td = Td + topplesd;
        end
    end
    % if anything changed, accept toppling of the sink, otherwise reject.
    if any(any(C-oldC))
        if false
            
            figHRegular = figure(789);
            subplot(2,2,1);
            plotPile(gca(), oldC);
            axis equal;
            axis off;
            subplot(2,2,2);
            plotPile(gca(), C);
            axis equal;
            axis off;
            
            subplot(2,2,3);
            plotPile(gca(), abs(C-oldC));
            axis equal;
            axis off;
            
            subplot(2,2,4);
            plotPile(gca(), ceil(abs(T-oldT)/numAdditionalTopplings));
            axis equal;
            axis off;
            
        end
        oldC = C;
        oldCd = Cd;
        oldT = T;
        oldTd = Td;
        numAdditionalTopplings = 2*numAdditionalTopplings;
    else
        C = oldC;
        Cd = oldCd;
        T = oldT;
        Td = oldTd;
        break;
    end
end
end

