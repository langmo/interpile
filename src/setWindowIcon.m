function setWindowIcon(figureH, iconFile)
oldWarn = warning('off', 'MATLAB:ui:javaframe:PropertyToBeRemoved');
try
    if nargin < 1 || isempty(figureH) || ~ishandle(figureH)
        figureH = gcf();
    end
    if nargin < 2
        iconFile = 'icon.tif';
    end
    if isdeployed()
        iconFile = which(iconFile);
    end
    [img] = imread(iconFile);

    oldWarn = warning('off', 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    jimage = im2java(img);
    jframe=get(figureH, 'javaframe') ; %#ok<JAVFM>
    jIcon=javax.swing.ImageIcon(jimage);
    jframe.setFigureIcon(jIcon); 
    warning(oldWarn);
catch
    % Do nothing, default Matlab icon is OK, too.
end
warning(oldWarn);
end

