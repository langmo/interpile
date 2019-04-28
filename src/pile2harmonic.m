function [H, varargout] = pile2harmonic(S, varargin)

% Copyright (C) 2019 Moritz Lang
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% For more information, visit the project's website at 
% https://langmo.github.io/interpile/

if ~isempty(which('sym'))
    typeName = 'sym';
elseif ~isempty(which('vpi'))
    typeName = 'vpi';
else
    typeName = 'double';
end
p = inputParser;
addOptional(p,'numericThreshold', 1e-3);
addOptional(p,'typeName', typeName);
addOptional(p,'returnTypeName', Types.gettype(S));
parse(p,varargin{:});

numericThreshold = p.Results.numericThreshold;
typeName = p.Results.typeName;
if isempty(p.Results.returnTypeName)
    returnTypeName = typeName;
else
    returnTypeName = p.Results.returnTypeName;
end

N = size(S, 1);
M = size(S, 2);

% It doesn't really matter which harmonics we use here, thus, we just take
% the simplest...
diagHarmonic = @evenDiagHarmonic;

%% Step 1: Get necessary particle additions to boundary to reach S 
pilePotential = pile2potential(S, false, 'typeName', typeName, 'returnTypeName', typeName);
pilePotential = [...
    pilePotential(1, 1:end)';
    pilePotential(2:end-1, end);
    pilePotential(end, end:-1:1)';
    pilePotential(end-1:-1:2, 1)];
%S = [S(1, end:-1:2), S(1:end-1, 1)', S(end, 1:end-1), S(end:-1:2, end)']';

%% Step 2: Get potentials of sufficiently many harmonic functions
% coordinates of extended domain
X=repmat((0:M+1) - (M+1)/2, N+2, 1);
Y=repmat(((0:N+1) - (N+1)/2)', 1, M+2);
if mod(M,2) ~= 1
    X=round(X+0.5);
end
if mod(N,2) ~= 1
    Y=round(Y+0.5);
end

boundary = false(size(X));
boundary(2, 2:end-1) = true;
boundary(end-1, 2:end-1) = true;
boundary(2:end-1,2) = true;
boundary(2:end-1, end-1) = true;
boundaryIdx = find(boundary);

extendedBoundary = false(size(X));
extendedBoundary(1, 2:end-1) = true;
extendedBoundary(end, 2:end-1) = true;
extendedBoundary(2:end-1, 1) = true;
extendedBoundary(2:end-1, 1) = true;
extendedBoundaryIdx = find(extendedBoundary);

numPotentials = 2*N+2*M -4; % boundary domain
bases = cell(1, numPotentials);
extendedBases = cell(1, 4);
potentialMatrix = zeros(numPotentials, numPotentials);
nextBasis = 1;
nextExtendedBasis = 1;

% iterate over domain and get harmonics.
for direction = 1:2
    for sign = [1,-1]
        for i = 1:2*max(N,M)
            harmonicFct = diagHarmonic(sign*i, direction, 'typeName', typeName);
            harmonic = harmonicFct(Y, X);
            % Check if harmonic is non-zero in domain. Sufficient to check
            % if non-zero on boundary, which is probably faster.
            % We take the absolute value because VPI distinguishes between
            % +0 and -0...
            if any(abs(harmonic(boundaryIdx)) ~= 0) %#ok<FNDSB>
                bases{nextBasis} = harmonic;
                potential = [...
                    harmonic(2, 1) + harmonic(1,2);...
                    harmonic(1,3:end-2)';
                    harmonic(1,end-1) + harmonic(2, end);
                    harmonic(3:end-2, end);
                    harmonic(end-1, end)+harmonic(end, end-1);
                    harmonic(end, end-2:-1:3)';
                    harmonic(end, 2)+harmonic(end-1, 1);
                    harmonic(end-2:-1:3, 1)];
                potentialMatrix(:, nextBasis) = potential;
                nextBasis = nextBasis + 1;
                continue;
            % Check if harmonic is non-zero in extended domain. Sufficient to check
            % if non-zero on extended boundary, which is probably faster.
            elseif any(abs(harmonic(extendedBoundaryIdx)) ~= 0)
                extendedBases{nextExtendedBasis} = harmonic;
                nextExtendedBasis = nextExtendedBasis+1;    
            end
            break;
        end
        if nextExtendedBasis > length(extendedBases)
            break;
        end
    end
    if nextExtendedBasis > length(extendedBases)
        break;
    end
end

if strcmpi(typeName, 'vpi')
    %% variable precision integer calculations (more precise but much slower than numeric, as precise but slower than symbolic)
    
    % Calculate coordinates
    [cN, cD] = solveRational(potentialMatrix, pilePotential, 'typeName', typeName);
    cN = mod(cN, cD); % equivalent to mod(cN/cD, 1);
    
    % Construct harmonic
    harmonic = Types.zeros(N+2,M+2, typeName);
    for i=1:length(cN)
        harmonic = harmonic + cN(i)*bases{i};
    end
    for i=1:length(extendedBases)
        % find a vertex where basis is non-zero.
        nonZeroVertexIdx = extendedBoundaryIdx(find(abs(extendedBases{i}(extendedBoundaryIdx)) ~= 0, 1));
        % get coordinate of extended harmonic.
        coord = cD-mod(harmonic(nonZeroVertexIdx), cD) / (extendedBases{i}(nonZeroVertexIdx));
        harmonic = harmonic + coord*extendedBases{i};
    end
    
    % Set harmonic at the four corners to zero. Note that these corners
    % don't belong to the extended domain at all. But even if the belonged
    % to it, there would be always a basis which is only non-zero on each
    % corner, and with this basis we could also set it to zero. All in all,
    % it's mainly a cosmetic thing to do this...
    zero = Types.cast2type(0, typeName);
    harmonic(1,1) = zero;
    harmonic(1,end) = zero;
    harmonic(end,1) = zero;
    harmonic(end,end) = zero;
    
elseif strcmpi(typeName, 'sym')
    %% symbolic calculations (more precise but slower than numeric, as precise but faster than vpi)
    
    % Calculate coordinates
    c = Types.cast2type(potentialMatrix, 'sym') \ Types.cast2type(pilePotential, 'sym');
    c = mod(c, sym(1));
    
    % to common denominator
    [c_a,c_b]=numden(c);
    cD = 1;
    for i = 1:length(c_b)
        cD = lcm(cD, c_b(i));
    end
    cN = c_a .* (cD ./ c_b);
    
    % Construct harmonic
    harmonic = Types.zeros(N+2,M+2, typeName);
    for i=1:length(cN)
        harmonic = harmonic + cN(i)*bases{i};
    end
    for i=1:length(extendedBases)
        % find a vertex where basis is non-zero.
        nonZeroVertexIdx = extendedBoundaryIdx(find(extendedBases{i}(extendedBoundaryIdx) ~= 0, 1));
        % get coordinate of extended harmonic.
        coord = cD-mod(harmonic(nonZeroVertexIdx), cD) / (extendedBases{i}(nonZeroVertexIdx));
        harmonic = harmonic + coord*extendedBases{i};
    end
    
    % Set harmonic at the four corners to zero. Note that these corners
    % don't belong to the extended domain at all. But even if the belonged
    % to it, there would be always a basis which is only non-zero on each
    % corner, and with this basis we could also set it to zero. All in all,
    % it's mainly a cosmetic thing to do this...
    harmonic(1,1) = 0;
    harmonic(1,end) = 0;
    harmonic(end,1) = 0;
    harmonic(end,end) = 0;
    
else
    %% numeric calculations (the numeric error is quite significant, but its much faster than the other two...so maybe for some kind of first approximation useful)
    
    % Calculate coordinates
    c = potentialMatrix \ pilePotential;
    c = mod(c, 1);

    % some rounding
    c(min(c, 1-c)<numericThreshold) = 0;
    
    % we know the coordinates must be rational, so get the nearest rational number for each coordinate. 
    % Unluckily, this is very error prone after we have done the numeric
    % calculations...
    [c_a,c_b]=rat(c, numericThreshold);
    
    % to common denominator
    cD = 1;
    for i = 1:length(c_b)
        cD = lcm(cD, c_b(i));
    end
    cN = round(c_a .* (cD ./ c_b));
    
    % Construct harmonic
    harmonic = Types.zeros(N+2,M+2, typeName);
    for i=1:length(cN)
        harmonic = harmonic + cN(i)*bases{i};
    end
    for i=1:length(extendedBases)
        % find a vertex where basis is non-zero.
        nonZeroVertexIdx = extendedBoundaryIdx(find(extendedBases{i}(extendedBoundaryIdx) ~= 0, 1));
        % get coordinate of extended harmonic.
        coord = cD-mod(harmonic(nonZeroVertexIdx), cD) / (extendedBases{i}(nonZeroVertexIdx));
        harmonic = harmonic + coord*extendedBases{i};
    end
    
    % Set harmonic at the four corners to zero. Note that these corners
    % don't belong to the extended domain at all. But even if the belonged
    % to it, there would be always a basis which is only non-zero on each
    % corner, and with this basis we could also set it to zero. All in all,
    % it's mainly a cosmetic thing to do this...
    harmonic(1,1) = 0;
    harmonic(1,end) = 0;
    harmonic(end,1) = 0;
    harmonic(end,end) = 0;
    
end

if nargout >= 2
	H = Types.cast2type(harmonic, returnTypeName);
	varargout{1} = Types.cast2type(cD, returnTypeName);
else
    if strcmpi(typeName, 'vpi')
        error('InterPile:vpiCanOnlyRepresentIntegers', ...
            'When using VPI as return type, number of return values cannot be one since VPI cannot represent rational or real numbers...');
    end
    H = Types.cast2type(harmonic, returnTypeName) / Types.cast2type(cD, returnTypeName);
end

end