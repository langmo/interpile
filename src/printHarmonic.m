function printHarmonic(varargin)
%% Read Inputs
idxInput = 1;
if ischar(varargin{idxInput})
    fileName = varargin{idxInput};
    idxInput = idxInput+1;
else
    fileName = [];
end

Hs = varargin{idxInput};
idxInput = idxInput+1;
if ~iscell(Hs)
    Hs = {Hs};
end
spaceText = repmat({'\\'}, 1, numel(Hs)-1);

colorFct = @(nI, nJ)  mod((max(abs(nI), abs(nJ))-mod(max(abs(nI), abs(nJ)), 2))/2, 6);

colors = [...
    0, 0.5, 0.5;...
    0.5, 0, 0.5;...
    0.5, 0.5, 0;...
    0.5, 0, 0;...
    0,0.5,0;...
    0,0,0.5];

p = inputParser;
addOptional(p,'xlim', [-inf, +inf]);
addOptional(p,'ylim', [-inf, +inf]);
addOptional(p,'showCell', @(nI, nJ)true);
addOptional(p,'colorFct', colorFct);
addOptional(p,'backgroundColorFct', @(nI, nJ)NaN);
addOptional(p,'colors', colors);
addOptional(p,'backgroundColors', []);
addOptional(p,'spaceText', spaceText);
addOptional(p,'numDigits', 3);
addOptional(p,'title', []);
addOptional(p,'time', []);
addOptional(p,'drawAxes', true);
addOptional(p,'columnWidth', []);
addOptional(p,'columnHeight', []);
addOptional(p,'fractionType', 'sfrac');
parse(p,varargin{idxInput:end});

showCell = p.Results.showCell;
minI = p.Results.ylim(1);
maxI = p.Results.ylim(2);
minJ = p.Results.xlim(1);
maxJ = p.Results.xlim(2);
numDigits = int2str(p.Results.numDigits);
title = p.Results.title;
time = p.Results.time;
drawAxes = p.Results.drawAxes;
colorFct = p.Results.colorFct;
colors = p.Results.colors;
backgroundColors = p.Results.backgroundColors;
backgroundColorFct = p.Results.backgroundColorFct;
columnWidth = p.Results.columnWidth;
if isempty(p.Results.columnHeight)
    columnHeight = columnWidth;
else
    columnHeight = p.Results.columnHeight;
end
fractionType = p.Results.fractionType;

spaceText(1:max(length(spaceText), length(p.Results.spaceText)))=p.Results.spaceText(1:max(length(spaceText), length(p.Results.spaceText)));

%% write header
if isempty(fileName)
    fID = 1;
else
    [filepath,~,~] = fileparts(fileName);
    if ~isempty(filepath) && ~exist(filepath, 'dir')
        mkdir(filepath);
    end
    fID = fopen(fileName, 'w');
    fTemplate = fopen('harmonicTemplate.template', 'r');
    tline = fgetl(fTemplate);
    while ischar(tline) && ~contains(tline, '%<HEADER>')
        fprintf(fID, '%s\n', tline);
        tline = fgetl(fTemplate);
    end
    for i=1:size(colors, 1)
        fprintf(fID, '\\definecolor{c%s}{rgb}{%g, %g, %g}\n', 'A'+(i-1), colors(i, 1), colors(i, 2), colors(i, 3));
    end
    for i=1:size(backgroundColors, 1)
        fprintf(fID, '\\definecolor{b%s}{rgb}{%g, %g, %g}\n', 'A'+(i-1), backgroundColors(i, 1), backgroundColors(i, 2), backgroundColors(i, 3));
    end
    tline = fgetl(fTemplate);
    while ischar(tline) && ~contains(tline, '%<CONTENT>')
        fprintf(fID, '%s\n', tline);
        tline = fgetl(fTemplate);
    end
end
%% write matrix
%fprintf(fID, '\\begin{table}\n');
%fprintf(fID, '\t\\center\n');

if ~isempty(title)
    fprintf(fID, '\\section*{\\tiny %s}\n', title);
end
fprintf(fID, '\\scalebox{.2}{\n');
%fprintf(fID, '\t\\tiny\n');
for idxH = 1:numel(Hs)
    if idxH > 1
        fprintf(fID, '\t\t%s\n', spaceText{idxH-1});
    end
    
    H = Hs{idxH};
    
    nIs = -((1:size(H, 1))-(size(H, 1)+1)/2)*2;
    nJs = ((1:size(H, 2))-(size(H, 2)+1)/2)*2;
    is = find(nIs>=minI & nIs <=maxI);
    js = find(nJs>=minJ & nJs <=maxJ);
    if ~isempty(columnWidth)
        fprintf(fID, '\t\\setlength\\tabcolsep{0pt}\n');
    end
    if drawAxes
        fprintf(fID, '\t\\begin{tabular}{r | %s}\n', repmat('c', 1, length(js)));
    else
        fprintf(fID, '\t\\begin{tabular}{%s}\n', repmat('c', 1, length(js)));
    end
    for i=is
        nI = nIs(i);
        fprintf(fID, '\t\t');
        if drawAxes
            fprintf(fID, '\\cAxis{%g}\t&\t', nI);
        end
        for j=js
            nJ = nIs(j);
            if showCell(nI, nJ)
                color = colorFct(nI, nJ);
                backgroundColor = backgroundColorFct(nI, nJ);
                if ~isnan(backgroundColor)
                    fprintf(fID, '{\\cellcolor{b%s}', 'A'+backgroundColor);
                end
                if ~isempty(columnWidth)
                    fprintf(fID, '\\parbox[c][%gcm][c]{%gcm}{\\centering ', columnHeight, columnWidth);
                end
                fprintf(fID, '\\textcolor{c%s}{', 'A'+color);
                if isempty(time)
                    if mod(H(i,j),1) <100*eps || 1-mod(H(i,j),1) <100*eps
                        fprintf(fID, '$%4.0f$', H(i,j));
                    else
                        fprintf(fID, ['$%4.',numDigits,'f$'], H(i,j));
                    end
                else
                    num = time(1)*H(i,j);
                    denum = time(2);
                    gg = gcd(num, denum);
                    num = num/gg;
                    denum = denum/gg;
                    if denum == 1
                        fprintf(fID, '$%4.0f$', num);
                    else
                        if strcmpi(fractionType, 'frac')
                            if num < 0
                                signText = '-';
                            else
                                signText = '';
                            end
                            fprintf(fID, '$%s\\frac{%4.0f}{%4.0f}$', signText, abs(num), denum);
                        else
                            fprintf(fID, '$\\sfrac{%4.0f}{%4.0f}$', num, denum);
                        end
                    end
                end
                fprintf(fID, '}');
                if ~isempty(columnWidth)
                    fprintf(fID, '}');
                end
                if ~isnan(backgroundColor)
                    fprintf(fID, '}');
                end
            end
            if j<size(H, 2)
                fprintf(fID, '\t&\t');
            else
                fprintf(fID, '\\\\\n');
            end
        end
    end
    if drawAxes
        fprintf(fID, '\t\t\\hline\n');
        fprintf(fID, '\t\t\\cAxis{y/x}\t&\t');
        for j=js
            nJ = nJs(j);
            fprintf(fID, '\\cAxis{%g}', nJ);
            if j<size(H, 2)
                fprintf(fID, '\t&\t');
            else
                fprintf(fID, '\n');
            end
        end
    end
    fprintf(fID, '\t\\end{tabular}\n');
end
%fprintf(fID, '\\end{table}\n');
fprintf(fID, '}\n');
%% write footer
if ~isempty(fileName)
    tline = fgetl(fTemplate);
    while ischar(tline)
        fprintf(fID, '%s\n', tline);
        tline = fgetl(fTemplate);
    end
    fclose(fID);
    fclose(fTemplate);
    
    [baseDir, baseName, ~] = fileparts(fileName);
    system(sprintf('pdflatex  -output-directory %s -interaction=nonstopmode %s', baseDir, fileName));
    
    pdfName = fullfile(baseDir, [baseName, '.pdf']);
    cropPDF(pdfName);
    drawnow();
    pause(0.5);
    system(sprintf('start "" "%s"', pdfName))
else
end

