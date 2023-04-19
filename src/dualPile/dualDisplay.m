function dualDisplay(C, Cd, T, Td, figH)
if nargin < 3 || isempty(T)
    T = 1./~isinf(C)-1;
end
if nargin < 4 || isempty(Td)
    Td = 1./~isinf(Cd)-1;
end
if nargin < 5 || isempty(figH)
    figH = figure('Color', [1,1,1]);
else
    figure(figH);
    figH.Color = [1,1,1];
    cla();
end


hold on;
axis equal;
axis off;
xlim([0,size(C,2)+1]);
ylim([0,size(C,1)+1]);

colors = pileColors();
faceWidth = 0.4;
nodeWidth = 2*sqrt(faceWidth^2/pi);

faceX = faceWidth/2*[-1,-1,1,1];
faceY = faceWidth/2*[-1,1,1,-1];
nodeX = nodeWidth/2*sin(0:2*pi/20:2*pi);
nodeY = nodeWidth/2*cos(0:2*pi/20:2*pi);
arrowRightUpX = [sqrt((nodeWidth/2)^2/2), 0.5-faceWidth/2];
arrowRightUpY = [sqrt((nodeWidth/2)^2/2), 0.5-faceWidth/2];
arrowLeftDownX = [-sqrt((nodeWidth/2)^2/2), -0.5+faceWidth/2];
arrowLeftDownY = [-sqrt((nodeWidth/2)^2/2), -0.5+faceWidth/2];

arrowRightDownX = [faceWidth/2, 0.5-sqrt((nodeWidth/2)^2/2)];
arrowRightDownY = [-faceWidth/2, -0.5+sqrt((nodeWidth/2)^2/2)];
arrowLeftUpX = [-faceWidth/2, -0.5+sqrt((nodeWidth/2)^2/2)];
arrowLeftUpY = [faceWidth/2, +0.5-sqrt((nodeWidth/2)^2/2)];

for x=1:size(C, 2)
    for y=1:size(C, 1)
        if ~isinf(C(y,x))
            fill(x+nodeX, y+nodeY, colors(min(max(C(y,x), 0),size(colors,1)-1)+1, :));
        end
        if ~isinf(T(y,x))
            arrow([x+arrowRightUpX(1),y+arrowRightUpY(1)],[x+arrowRightUpX(2),y+arrowRightUpY(2)], 3, 90, 60, 3);
            arrow([x+arrowLeftDownX(1),y+arrowLeftDownY(1)],[x+arrowLeftDownX(2),y+arrowLeftDownY(2)], 3, 90, 60, 3);
            text(x,y,sprintf('%g', T(y,x)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
        end
    end
end

for x=1:size(Cd, 2)
    for y=1:size(Cd, 1)
        if ~isinf(Cd(y,x))
            fill(x+faceX-0.5, y+faceY-0.5, colors(min(max(Cd(y,x), 0),size(colors,1)-1)+1, :));
        end
        if ~isinf(Td(y,x))
            arrow([x-0.5+arrowLeftUpX(1),y-0.5+arrowLeftUpY(1)],[x-0.5+arrowLeftUpX(2),y-0.5+arrowLeftUpY(2)], 3, 90, 60, 3);
            arrow([x-0.5+arrowRightDownX(1),y-0.5+arrowRightDownY(1)],[x-0.5+arrowRightDownX(2),y-0.5+arrowRightDownY(2)], 3, 90, 60, 3);
            text(x-0.5,y-0.5,sprintf('%g', Td(y,x)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
        end

    end
end

end