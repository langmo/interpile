function [C, Cd, T, Td] = dualRelax(C, Cd, T, Td)
if nargin < 3 || isempty(T)
    T = 1./~isinf(C)-1;
end
if nargin < 4 || isempty(Td)
    Td = 1./~isinf(Cd)-1;
end

anyTopples = true;
anyTopplesd = true;
while anyTopples || anyTopplesd
    %% normal toppling
    topples = floor(C/4);
    topples(isinf(topples))=0;
    
    anyTopples = any(any(topples));
    if anyTopples
        C = C - 4*topples;
        Cd(1:size(Cd,1)-1, 1:size(Cd,2)-1) = Cd(1:size(Cd,1)-1, 1:size(Cd,2)-1) + 2*topples;
        Cd(2:size(Cd,1), 2:size(Cd,2)) = Cd(2:size(Cd,1), 2:size(Cd,2)) + 2*topples;
        T = T + topples;
    end
    %% dual toppling
    topplesd = floor(Cd/2);
    topplesd(isinf(topplesd))=0;
    
    anyTopplesd = any(any(topplesd));
    if any(any(topplesd))
        Cd = Cd - 2*topplesd;
        C= C + topplesd(1:size(Cd,1)-1, 2:size(Cd,2));
        C= C + topplesd(2:size(Cd,1), 1:size(Cd,2)-1);
        Td = Td + topplesd;
    end
end

end

