N = 255;
M = N;
if 1
    Sstart = randi(2, N,M)+1;
    numPerturb = 10*N*M;
    numFrames = 1000;
    for p=1:30
        Sstart(randi(N), randi(M)) = 4;
    end
    Sstart = relaxPile(Sstart);
    folder = sprintf('stochVeryRandi_%gx%g', N, M);
elseif 1
    Sstart = randi(2, N,M)+1;
    numPerturb = N*M;
    numFrames = 100;
    Sstart(round(2/3*N), round(2/3*M)) = 4;
    Sstart = relaxPile(Sstart);
    folder = sprintf('stochRandi_%gx%g', N, M);
elseif 0
    Sstart = 3*ones(N, M);
    numPerturb = N*M;
    numFrames = 100;
    Sstart(round(2/3*N), round(2/3*M)) = 4;
    Sstart = relaxPile(Sstart);
    folder = sprintf('stochAll3_%gx%g', N, M);
else
    Sstart = nullPile(N, M);
    numPerturb = 10000;
    numFrames = 100;
    folder = sprintf('stochIdentity_%gx%g', N, M);
end


interPile(Sstart);
drawnow();
%%
deltaY = [-1, 0, 1, 0];
deltaX = [0, -1, 0, 1];
S = Sstart;
parentIdx = pile2tree(S);

fileTemplate = 'step%g.mat';
pertPerStep = ceil(numPerturb/numFrames);
numSteps = numFrames;
numRounds = pertPerStep*numFrames;
stepsPerRound = 1/pertPerStep;
mode = 'tropicDyn';
if ~exist(folder, 'dir')
    mkdir(folder);
end
save(fullfile(folder, 'config.mat'), 'S', 'numRounds', 'stepsPerRound', 'fileTemplate', 'numSteps', 'mode');
save(fullfile(folder, sprintf(fileTemplate, 0)), 'S');


messageTemplate = 'Calculating dynamics: %3.0f%%%%';
message = sprintf(messageTemplate, 0);
fprintf(message);
messageLength = length(message)-1;
lastTime = tic();


for majorStep = 1:numSteps
    for minorStep = 1:pertPerStep
        time = toc(lastTime);
        if time >= 1
            message = sprintf(messageTemplate, 100*((majorStep-1)*pertPerStep+minorStep-1)/pertPerStep/numSteps);
            fprintf([repmat('\b', 1, messageLength), message]);
            messageLength = length(message)-1;
            lastTime = tic();
        end

        leaves = true(size(S));
        leaves(parentIdx(parentIdx>0)) = false;
        leaves = find(leaves);
        leave = leaves(randi(length(leaves)));
        [leaveY, leaveX] = ind2sub([N,M], leave);
        p = randi(4);
        parentY = leaveY+deltaY(p);
        parentX = leaveX+deltaX(p);
        if parentY <= 0 || parentY > N || parentX <= 0 || parentX > M
            parentIdx(leave) = 0;
        else
            parentIdx(leave) = sub2ind([N,M], parentY, parentX);
        end
    end
    S = tree2pile(parentIdx);
    save(fullfile(folder, sprintf(fileTemplate, majorStep)), 'S');
end
fprintf([repmat('\b', 1, messageLength), 'Finished calculating dynamics.\n']);

%%
interViewer(fullfile(folder, 'config.mat'))