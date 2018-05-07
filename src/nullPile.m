function S = nullPile(n, m)
% Based on the following algorithm:
% if f and g are two states then (f+g*)*=(f+g)*
% (where * denotes the relaxation)
% Now note that 6* and (6-6*)* are recurrent, since obtained from 3 by adding. Apply the trick to them: 
% (6*+(6-6*)*)*=(6*+6-6*)*=6* 
% Therefore, (6-6*)* has to be the zero of the sandpile group.
%S = relaxPile(6*ones(n,m)-relaxPile(6*ones(n,m)));
% Same works also from 5, since 2 is always reachable for rectangles.
if ~isdeployed()
    dirName = 'null_piles';
else
    dirName = fullfile(ctfroot(), 'null_piles');
end
fileName = fullfile(dirName, sprintf('%gx%g.mat', n, m));
if exist(fileName, 'file')
    load(fileName, 'S');
    return;
end
S = relaxPile(5*ones(n,m)-relaxPile(5*ones(n,m)));
try
    if ~exist(dirName, 'dir')
        mkdir(dirName);
        fprintf('Saving nullpiles in folder %s to speed up program.\n', dirName);
    end
    save(fileName, 'S');
catch
    errordlg(sprintf('Could not save nullpile to %s.', fileName), 'Error saving nullpile');
end
end

