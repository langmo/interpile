function S = nullPile(n, m, mask, maskName)
% Based on the following algorithm:
% if f and g are two states then (f+g*)*=(f+g)*
% (where * denotes the relaxation)
% Now note that 6* and (6-6*)* are recurrent, since obtained from 3 by adding. Apply the trick to them: 
% (6*+(6-6*)*)*=(6*+6-6*)*=6* 
% Therefore, (6-6*)* has to be the zero of the sandpile group.
%S = relaxPile(6*ones(n,m)-relaxPile(6*ones(n,m)));
% Same works also from 5, since 2 is always reachable for rectangles.

if nargin < 1
    n = 128;
end
if nargin < 2
    m = n;
end
if nargin < 3
    mask = ones(n, m);
end
if nargin < 4
    maskName = 'customMask';
end
maskName = ['_', maskName];
if all(all(mask == ones(n, m)))
    maskName = '';
end


if ~isdeployed()
    dirName = 'null_piles';
else
    dirName = fullfile(ctfroot(), 'null_piles');
end
fileName = fullfile(dirName, sprintf('%gx%g%s.mat', n, m, maskName));
if exist(fileName, 'file')
    load(fileName, 'S');
    return;
end

filled = 5*ones(n,m);
filled(~mask) = -inf;

S = filled-relaxPile(filled);
S(~mask) = -inf;
S = relaxPile(S);
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

