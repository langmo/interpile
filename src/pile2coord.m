function [c1, c2, varargout] = pile2coord(S, varargin)

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

p = inputParser;
addOptional(p,'symbolicCalculations', true);
addOptional(p,'numericThreshold', 1e-3);
addOptional(p,'symbolicResult', false);
addOptional(p,'typeName', 'double');
parse(p,varargin{:});


symbolicCalculations = p.Results.symbolicCalculations;
numericThreshold = p.Results.numericThreshold;
symbolicResult = p.Results.symbolicResult;
typeName = p.Results.typeName;

if nargin < 1
    % A test sandpile where the central two harmonics in c2 should be 0.5,
    % and the outer most in c1. All other should be 0.
    S = nullPile(4);
    S(1,2:3) = S(1,2:3) + [-6,8]/2;
    S(1,4) = S(1,4)-4/2;
    S(2:3, end) = S(2:3, end) + [8;-6]/2;
    S(end,2:3) = S(end,2:3) + [-8,6]/2;
    S(end,1) = S(end,1)+4/2;
    S(2:3, 1) = S(2:3, 1) + [6;-8]/2;
    
    minS = -4;
    S(1, :) =   S(1, :)-minS;
    S(end, :) = S(end, :)-minS;
    S(:, 1) =   S(:, 1)-minS;
    S(:, end) = S(:, end)-minS;
    S = relaxPile(S);
end

N = size(S, 1);
M = size(S, 2);

if mod(N, 2) == 0
    diagHarmonic = @evenDiagHarmonic;
else
    diagHarmonic = @oddDiagHarmonic;
end

S = pile2potential(S, false);
S = [S(1, end:-1:2), S(1:end-1, 1)', S(end, 1:end-1), S(end:-1:2, end)']';

X=repmat((0:M+1) - (M+1)/2, N+2, 1);
Y=repmat(((0:N+1) - (N+1)/2)', 1, M+2);
if mod(M,2) ~= 1
    X=round(X+0.5);
end
if mod(N,2) ~= 1
    Y=round(Y+0.5);
end

X = [X(1, end-1:-1:2), X(2:end-1, 1)', X(end, 2:end-1), X(end-1:-1:2, end)'];
Y = [Y(1, end-1:-1:2), Y(2:end-1, 1)', Y(end, 2:end-1), Y(end-1:-1:2, end)'];

P1 = zeros(2*N, length(X), typeName);
P2 = zeros(2*N, length(X), typeName);

ids = [-N:-1, 1:N];

% get potentials
for i = 1:2*N
    if ids(i) == 1 && mod(N, 2) == 1
        harmonicFct = diagHarmonic(0,1, 'typeName', typeName);
    else
        harmonicFct = diagHarmonic(ids(i),1, 'typeName', typeName);
    end
    P1(i, :) = harmonicFct(Y, X);
    harmonicFct = diagHarmonic(ids(i),2, 'typeName', typeName);
    P2(i, :) = harmonicFct(Y, X);
end

% shrink potentials
T1 = [...
    P1(2:end-1, 4*N)+ P1(2:end-1, 1),       P1(2:end-1, 2:N-1), ...
    P1(2:end-1, N)+   P1(2:end-1, N+1),     P1(2:end-1, N+2:2*N-1), ...
    P1(2:end-1, 2*N)+ P1(2:end-1, 2*N+1),   P1(2:end-1, 2*N+2:3*N-1), ...
    P1(2:end-1, 3*N)+ P1(2:end-1, 3*N+1),   P1(2:end-1, 3*N+2:4*N-1)];

T2 = [...
    P2(2:end-1, 4*N)+ P2(2:end-1, 1),       P2(2:end-1, 2:N-1), ...
    P2(2:end-1, N)+   P2(2:end-1, N+1),     P2(2:end-1, N+2:2*N-1), ...
    P2(2:end-1, 2*N)+ P2(2:end-1, 2*N+1),   P2(2:end-1, 2*N+2:3*N-1), ...
    P2(2:end-1, 3*N)+ P2(2:end-1, 3*N+1),   P2(2:end-1, 3*N+2:4*N-1)];

T = [T1;T2]';

if symbolicCalculations
    %% symbolic calculations (more robust, probably, but slower)
    c = sym(T) \ sym(S);
    c1 = [0; c(1:size(T1, 1)); 0];
    c2 = [0; c(1+size(T2, 1):end); 0];

    % Set outest most harmonic such that integer potential.
    Ptot = P1'*c1 + P2'*c2;
    c2(end) = -mod(Ptot(1), 1);
    c1(1) = -mod(Ptot(M+1), 1);
    c2(1) = -mod(Ptot(M+N), 1);
    c1(end) = -mod(Ptot(M+N+M), 1);
    c1 = mod(c1, 1);
    c2 = mod(c2, 1);

    % add the zero in the middle
    if mod(N, 2) == 1
        c2 = [c2(1:N)', c1(N+1)/2, c2(N+1:end)'];
        c1 = [c1(1:N)', c1(N+1)/2, 0, c1(N+2:end)'];
    else
        c1 = [c1(1:N)', 0, c1(N+1:end)'];
        c2 = [c2(1:N)', 0, c2(N+1:end)'];
    end

    if nargout() == 2
        if ~symbolicResult
            c1 = double(c1);
            c2 = double(c2);
        end
    else
        [c1_a,c1_b]=numden(c1);
        [c2_a,c2_b]=numden(c2);
        t_b = 1;
        for c_b = [c1_b, c2_b]
            t_b = lcm(t_b, c_b);
        end
        c1 = c1_a .* (t_b ./ c1_b);
        c2 = c2_a .* (t_b ./ c2_b);

        t_a = 0;
        for c = [c1, c2]
            t_a = gcd(t_a, c);
        end
        if t_a ~= 0
            c1 = c1 ./ t_a;
            c2 = c2 ./ t_a;
        end
        if ~symbolicResult
            c1 = double(c1);
            c2 = double(c2);
            t_a = double(t_a);
            t_b = double(t_b);
        end
        varargout{1} = [t_a, t_b];
    end
else
    %% numeric calculations (the numeric error is quite significant, but its faster...so maybe for some kind of first approximation useful)
    c = T \ S;
    
    c = mod(c, 1);

    c1 = [0; c(1:size(T1, 1)); 0];
    c2 = [0; c(1+size(T2, 1):end); 0];

    % some rounding
    c1(min(c1, 1-c1)<numericThreshold) = 0;
    c2(min(c2, 1-c2)<numericThreshold) = 0;

    % Set outest most harmonic such that integer potential.
    Ptot = P1'*c1 + P2'*c2;
    c2(end) = -mod(Ptot(1), 1);
    c1(1) = -mod(Ptot(M+1), 1);
    c2(1) = -mod(Ptot(M+N), 1);
    c1(end) = -mod(Ptot(M+N+M), 1);
    c1 = mod(c1, 1);
    c2 = mod(c2, 1);

    % some rounding
    c1(min(c1, 1-c1)<numericThreshold) = 0;
    c2(min(c2, 1-c2)<numericThreshold) = 0;

    % add the zero in the middle
    if mod(N, 2) == 1
        c2 = [c2(1:N)', c1(N+1)/2, c2(N+1:end)'];
        c1 = [c1(1:N)', c1(N+1)/2, 0, c1(N+2:end)'];
    else
        c1 = [c1(1:N)', 0, c1(N+1:end)'];
        c2 = [c2(1:N)', 0, c2(N+1:end)'];
    end

    % we know it must be a rational number. Unluckily, the above makes a lot of
    % numerical error...so let's just round it to the nearest rational...
    [c1_a,c1_b]=rat(c1, numericThreshold);
    [c2_a,c2_b]=rat(c2, numericThreshold);
    
    if nargout() == 2
        c1 = c1_a./c1_b;
        c2 = c2_a./c2_b;
    else
        t_b = 1;
        for c_b = [c1_b, c2_b]
            t_b = lcm(t_b, c_b);
        end
        c1 = c1_a .* (t_b ./ c1_b);
        c2 = c2_a .* (t_b ./ c2_b);

        t_a = 0;
        for c = [c1, c2]
            t_a = gcd(t_a, c);
        end
        if t_a ~= 0
            c1 = c1 ./ t_a;
            c2 = c2 ./ t_a;
        end
        varargout{1} = [t_a, t_b];
    end
end

end

