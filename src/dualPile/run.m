plotDual = false;
plotRegular = true;

if false
    width = 91;
    boundary = 21; % at least 1
    boundaryExt = 1;
    C = zeros(width+2*boundary);
    midX = boundary+(width+1)/2;
    midY = midX;
    %C(midY, midX)=37;
    for x=1:size(C, 2)
        for y=1:size(C, 1)
            if abs(x-midX)+abs(y-midY)>width/2
                C(y,x)=inf;
            end
        end
    end

    Cext = inf(size(C));
    Cext(1+boundaryExt:size(Cext,1)-boundaryExt, 1+boundaryExt:size(Cext,2)-boundaryExt)=0;
elseif true
    widthSmall = 57;
    widthLarge = 2*widthSmall - (widthSmall-1)/2;
    boundary = 1; % at least 1
    C = zeros(widthLarge+2*boundary);
    midX = boundary+(widthSmall+1)/2;
    midY = boundary+(widthSmall+1)/2*2;
    for x=1:size(C, 2)
        for y=1:size(C, 1)
            if abs(x-midX)+abs(y-midY)>widthSmall/2
                C(y,x)=inf;
            end
        end
    end

    midX = boundary+(widthLarge+1)/2;
    midY = boundary+(widthLarge+1)/2;
    Cext = zeros(size(C));
    for x=1:size(Cext, 2)
        for y=1:size(Cext, 1)
            if (x-midX)+(y-midY)>widthSmall/2 ...
                || -(x-midX)-(y-midY)>widthSmall/2 ...
                || (x-midX)-(y-midY)>(widthSmall)...
                || -(x-midX)+(y-midY)>(widthSmall)
                Cext(y,x)=inf;
            end
        end
    end
elseif true
        width = 51;
    boundary = 121; % at least 1
    boundaryExt = 1;
    C = zeros(width+2*boundary);
    midX = boundary+(width+1)/2;
    midY = midX;
    %C(midY, midX)=37;
    for x=1:size(C, 2)
        for y=1:size(C, 1)
            if abs(x-midX)+abs(y-midY)>width/2
                C(y,x)=inf;
            end
        end
    end

    widthExt = width + 2*(boundary-boundaryExt);
    Cext = zeros(size(C));
    for x=1:size(Cext, 2)
        for y=1:size(Cext, 1)
            if abs(x-midX)+abs(y-midY)>widthExt/2
                Cext(y,x)=inf;
            end
        end
    end
else
    width = 71;
    boundary = 71; % at least 1
    boundaryExt = 1;
    C = inf(width+2*boundary);
    C(1+boundary:size(C,1)-boundary, 1+boundary:size(C,2)-boundary)=0;

    Cext = inf(size(C));
    Cext(1+boundaryExt:size(Cext,1)-boundaryExt, 1+boundaryExt:size(Cext,2)-boundaryExt)=0;
end

Cd = createDual(C);
Cdext = createDual(Cext);

C0 = C;
Cd0 = Cd;
Cext0 = Cext;
Cdext0 = Cdext;

%%
%interPile(nullPile(size(C,1), size(C, 2), ~isinf(C)));
%%
[C, Cd, T, Td, numSinkTopples] = dualNullpile(C0, Cd0);
%%
if plotDual
    
end
if plotRegular
    
end
%%
additionalTopplings = 0;
[Cext, Cdext, Text, Tdext] = dualExtend(Cext0, Cdext0, T+additionalTopplings, Td+2*additionalTopplings, numSinkTopples+additionalTopplings);
%%
if plotDual
    figH = figure(123);
    dualDisplay(C, Cd, T, Td, figH);
    figH = figure(124);
    dualDisplay(Cext, Cdext, Text, Tdext, figH);
end
if plotRegular
    figHRegular = figure();
    subplot(1,2,1);
    plotPile(gca(), C);
    axis equal;
    axis off;
    subplot(1,2,2);
    plotPile(gca(), Cext);
    axis equal;
    axis off;
end
%%
if true
    interPile(Cext(2:size(Cext,1)-1, 2:size(Cext,2)-1));
end