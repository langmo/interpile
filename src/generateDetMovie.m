function generateDetMovie(S, filePath, dropZone, numRounds, stepsPerRound, timePerRound, smallMovie)

if nargin < 1
    S = nullPile(64, 64);
end

if nargin < 3
    detMovieDialog(S);
    return;
end

height = size(S, 1);
width = size(S, 2);

if ~exist('dropZone', 'var') || isempty(dropZone)
    dropZone = @(y,x) x.*(x.^2-3.*y.^2);
end

if ~exist('stepsPerRound', 'var') || isempty(stepsPerRound)
    stepsPerRound = 60;
end

if ~exist('filePath', 'var') || isempty(filePath)
    filePath = fullfile(cd(), sprintf('harmonicDet_%gx%g_%s.avi', height, width, datestr(now,'yyyy-MM-dd_HH-mm-ss')));
end

if ~exist('numRounds', 'var') || isempty(numRounds)
    numRounds = 1;
end

if ~exist('timePerRound', 'var') || isempty(timePerRound)
    timePerRound = 6;
end
if ~exist('smallMovie', 'var') || isempty(smallMovie)
    smallMovie = true;
end



[pathstr,name,~] = fileparts(filePath);
folder = fullfile(pathstr, [name, '_frames']);

wbh = waitbar(0, 'Preparing movie...');
% Either dropZone is already the drop zone, or a function corresponding
% to the intended toppling function. If the latter, generate the drop zone.
if isa(dropZone, 'function_handle')
    F = generateDropZone(dropZone, height, width);

%     %% Get all drop numbers
%     X=repmat((0:width+1) - (width+1)/2, height+2, 1);
%     Y=repmat(((0:height+1) - (height+1)/2)', 1, width+2);
% 
%      if mod(width,2) ~= 1 || mod(height, 2) ~= 1
%          X = 2*X;
%          Y = 2*Y;
%      end
%     H = dropZone(Y, X);
% 
%     DeltaH = filter2([0,1,0;1,-4,1;0,1,0], H, 'valid');
%     assert(all(all(~DeltaH)));
%     %% Values at the vertices are not important for algorithm
%     H(1,1) = 0;
%     H(1, end) = 0;
%     H(end, 1) = 0;
%     H(end, end) = 0;
%     %% Make all values positive, and drop again values at the vertices
%     H = H - min(min(H));
%     H(1,1) = 0;
%     H(1, end) = 0;
%     H(end, 1) = 0;
%     H(end, end) = 0;
%     %% divide by greatest common divisor
%     values = setdiff(unique(H), 0);
%     divisor = values(1);
%     for i=2:length(values)
%         divisor = gcd(divisor, values(i));
%         if divisor == 1
%             break;
%         end
%     end
%     H = H ./divisor;
% 
%     %% Remove all values which do not correspond to drop zone
%     F = H;
%     F(2:end-1, 2:end-1) = 0;
%     F(1,1) = 0;
%     F(1, end) = 0;
%     F(end, 1) = 0;
%     F(end, end) = 0;
% 
%     %% Shrink to drop zone
%     addFilter = zeros(3,3);
%     addFilter(1, 2)= 1;
%     addFilter(2, 1)= 1;
%     addFilter(2, 3)= 1;
%     addFilter(3, 2)= 1;
%     F = filter2(addFilter, F, 'valid');
else
    F = dropZone;
end

%% generate frames
callback = @(x) waitbar(0.05+x*0.85, wbh, 'Generating frames...');
configPath = generateDetFrames(S, F, folder, numRounds, stepsPerRound, callback);


%% Generate movie
wbh = waitbar(0.9, wbh, 'Generating movie...');
assembleMovie(filePath, configPath, timePerRound, smallMovie)
close(wbh)

end

