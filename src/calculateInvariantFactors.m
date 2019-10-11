function varargout = calculateInvariantFactors(varargin)
% Calculates the invariant factors of the sandpile group.
% Usage:
%   factors = calculateInvariantFactors(N)
%       Calculates the number of recurrent states for an NxN square domain.
%       Instead of the number of recurrent states, the factorization is
%       returned. This is usually more precise for large numbers of
%       recurrent states due to rounding errors due to finite precision of
%       double values. The number of recurrent states can be obtained by
%       prod(factors).
%   factors = calculateInvariantFactors(N, M)
%       Calculates the number of recurrent states for an NxM rectangular domain.
%   factors = calculateInvariantFactors(mask)
%       Calculates the number of recurrent states for a domain
%       corresponding to the non-zero values of the mask.
%   factors = calculateInvariantFactors(..., 'method', method)
%       Defines the method how the number of recurrent states is
%       determined. 
%       Options:
%        'potential' (default). The number of states is determined by the absolute
%           value of the determinant of the matrix P, where each column of
%           P corresponds to the potential of one (non-zero) harmonic
%           diagonal function, restricted to the boundary of the domain.
%        'potentialPolynoms'. Same as 'potential', only with harmonics of
%           polynomial type.
%        'laplacian'. The number of states is determined by
%           the absolute value of the determinant of the graph laplacian.
%       

% Copyright (C) 2018, 2019 Moritz Lang
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

inputIdx = 1;
if numel(varargin{inputIdx}) > 1
    mask = varargin{inputIdx};
    N = size(mask, 1);
    M = size(mask, 2);
    inputIdx = inputIdx+1;
else
    N = varargin{inputIdx};
    inputIdx = inputIdx+1;
    if numel(varargin) >= inputIdx && isnumeric(varargin{inputIdx}) && numel(varargin{inputIdx}) == 1
        M = varargin{inputIdx};
        inputIdx = inputIdx+1;
    else
        M = N;
    end
    mask = ones(N, M);
end

if ~isempty(which('sym'))
    typeName = 'sym';
elseif ~isempty(which('vpi'))
    typeName = 'vpi';
else
    typeName = 'double';
end

p = inputParser;
addOptional(p,'method', 'potential');
addOptional(p,'typeName', typeName);
addOptional(p,'returnTypeName', 'double');
parse(p,varargin{inputIdx:end});
typeName = p.Results.typeName;
returnTypeName = p.Results.returnTypeName;
method = p.Results.method;

if nargout > 1
    error('InterPile:TooManyReturnValues', 'The function either returns zero or one value.');
end
if strcmpi(method, 'potential')
    % Calculate via potentials.
    startTime = tic();
    maskExtended = false(size(mask, 1)+2, size(mask, 2)+2);
    maskExtended(2:end-1, 2:end-1) = mask;
    
    X=ceil(repmat((0:M+1) - (M+1)/2, N+2, 1));
    Y=ceil(repmat(((0:N+1) - (N+1)/2)', 1, M+2));
    
    outerBoundary = filter2([0,1,0;1,0,1;0,1,0], maskExtended)>0;
    outerBoundary(maskExtended) = false;
    innerBoundary = filter2([0,1,0;1,0,1;0,1,0], ~maskExtended)>0;
    innerBoundary(~maskExtended) = false;
    
    outerX = X(outerBoundary);
    outerY = Y(outerBoundary);
    
    innerX = X(innerBoundary);
    innerY = Y(innerBoundary);
    
    outer2inner = Types.cast2type(abs(repmat(innerX,1, length(outerX)) - repmat(outerX',length(innerX), 1))...
        +abs(repmat(innerY,1, length(outerY)) - repmat(outerY',length(innerY), 1)) == 1, typeName);
    
    
    P = Types.zeros(sum(innerBoundary(:)), typeName); % potential matrix
    nextIdx = 1;
    h = 1;
    while nextIdx <= size(P, 1)
        for sign = [-1, 1]
            for direction = 1:2
                harmonic = evenDiagHarmonic(sign*h, direction, 'typeName', typeName);
                Pi = outer2inner * harmonic(outerY,outerX);
                if any(Pi~=0)
                    P(nextIdx, :) = Pi;
                    nextIdx = nextIdx+1;
                    if nextIdx > size(P, 1)
                        break;
                    end
                end
            end
            if nextIdx > size(P, 1)
                break;
            end
        end
        h = h+1;
    end
    if strcmpi(typeName, 'sym')
        invFactors = abs(diag(smithForm(P))');
    else
        [~,~,invFactors] = SNF(P);
    end
    
    calculationTime = toc(startTime);
elseif strcmpi(method, 'potentialPolynoms')
    % Calculate via potential polynoms.
    startTime = tic();
    maskExtended = zeros(size(mask, 1)+2, size(mask, 2)+2);
    maskExtended(2:end-1, 2:end-1) = mask;
    boundary = filter2([0,1,0;1,0,1;0,1,0], ~maskExtended);
    boundary = boundary(2:end-1, 2:end-1);
    boundary = boundary ~=0 & mask;
    boundaryIdx = find(boundary);
    P = NaN(length(boundaryIdx));
    H0 = @(y,x) ones(size(y));
    P0 = generateDropZone(H0, size(mask, 1), size(mask, 2), mask, false, false);
    P(1, : ) = P0(boundaryIdx);
    nextIdx = 2;
    h = 1;
    while nextIdx <= size(P, 1)
        HR = realHarmonicMonomial(h);
        PR = generateDropZone(HR, size(mask, 1), size(mask, 2), mask, false, false);
        PBound =  PR(boundaryIdx);
        if any(PBound)
            P(nextIdx, :) = PBound;
            if rank(P(1:nextIdx, :)) == nextIdx
                nextIdx = nextIdx+1;
                if nextIdx > size(P, 1)
                    break;
                end
            end
        end

        HI = imagHarmonicMonomial(h);
        PI = generateDropZone(HI, size(mask, 1), size(mask, 2), mask, false, false);
        PBound =  PI(boundaryIdx);
        if any(PBound)
            P(nextIdx, :) = PBound;
            if rank(P(1:nextIdx, :)) == nextIdx
                nextIdx = nextIdx+1;
                if nextIdx > size(P, 1)
                    break;
                end
            end
        end
        h = h+1;
    end
    
    if strcmpi(typeName, 'sym')
        invFactors = abs(diag(smithForm(Types.cast2type(P, typeName)))');
    else
        [~,~,invFactors] = SNF(Types.cast2type(P, typeName));
    end
    
    calculationTime = toc(startTime);
elseif strcmpi(method, 'laplacian')
    % Calculate via graph laplacian.
    startTime = tic();
    maskIDs = find(mask);
    Delta = zeros(length(maskIDs));
    for i=1:length(maskIDs)
        M = zeros(size(mask, 1), size(mask, 2));
        M(maskIDs(i))=1;
        A = filter2([0,1,0;1,-4,1;0,1,0], M);
        Delta(i, :) = A(maskIDs);
    end
    if strcmpi(typeName, 'sym')
        invFactors = abs(diag(smithForm(Types.cast2type(Delta, typeName)))');
    else
        [~,~,invFactors] = SNF(Types.cast2type(Delta, typeName));
    end
    % Calculate determinant. Symbolic toolbox seems to be more precise...
    calculationTime = toc(startTime);
else
    error('InterPile:UnknownAlgorithm', 'The method %s for the calculation of the number of recurrent states is unknown.', method);
end

% Return or print results.
if nargout > 0
    varargout{1} = invFactors;
else
    invFactors = invFactors(invFactors~=1);
    for f = 1:length(invFactors)
        if f==1
            factorsString = sprintf('%1.0f', Types.cast2type(invFactors(f), 'double'));
        else
            factorsString = sprintf('%s, %1.0f', factorsString, Types.cast2type(invFactors(f), 'double'));
        end
    end
       
    fprintf('Method:\t\t\t\t\t%s\n', method);
    fprintf('Internal Type:\t\t\t%s\n', typeName);
    fprintf('Invariant Factors:\t\t%s\n', factorsString);
    fprintf('Calculation Time:\t\t%.2fs\n', calculationTime);
end

end

function [U, V, S] = SNF(A)
%
%  This program determines the Smith Normal Form S of the M x N matrix A,
%  where S = U*A*V with U and V unimodular.  The returned S is a vector of
%  the invarient factors. Use diag(S) to turn it into a matrix.
%
%  Original Fortran version written by Morris Newman.
%  Adapted to Matlab with multiplier systems by Greg Wilson.
%  Adapted to use variable precision integers, and multiplier system
%  removed again, by Moritz Lang.

typeName = class(A);

[M,N] = size(A);
MPLUSN=M+N;
B = Types.zeros(MPLUSN, typeName);
B(1:M,1:N) = A;

L = min(M,N);
S = vpi(zeros(L,1));

% Set U = I and V = I
B(1:M,N+1:MPLUSN) = Types.cast2type(eye(M), typeName);
B(M+1:MPLUSN,1:N) = Types.cast2type(eye(N), typeName);
U = vpi(eye(L));
V = vpi(eye(L));

K=1;
while (K <= L)
    [I,J,T] = NMZ(K,M,N,B);
    if (T == 0)
        break;
    end
    
    % Interchange rows i and k, if i and k are different
    if (I ~= K)
        for v=K:MPLUSN
            S      = B(K,v);
            B(K,v) = B(I,v);
            B(I,v) = S;
        end
    end
    
    % Interchange columns j and k, if j and k are different
    if (J ~= K)
        for u=K:MPLUSN
            S      = B(u,K);
            B(u,K) = B(u,J);
            B(u,J) = S;
        end
    end
    
    % Replace row k by its negative, if B(k,k) < 0
    if (B(K,K) < 0)
        for v=K:MPLUSN
            B(K,v) = -B(K,v);
        end
    end
    
    % Replace row i by row i - x row k,
    % x = [B(i,k)/B(k,k)], i = k+1, ... ,m
    
    for I=K:M
        if (I ~= K)
            X = floor(B(I,K)/T);
            for J=K:MPLUSN
                B(I,J)=B(I,J)-X*B(K,J);
            end
        end
    end
    
    % Replace col j by col j - y col k,
    % where y =[B(k,j)/B(k,k)], j = k+1, ... ,n
    
    u = 1;
    while u ~= 0
        for J=K+1:N
            Y=floor(B(K,J)/T);
            for I=K:MPLUSN
                B(I,J)=B(I,J)-Y*B(I,K);
            end
        end
        
        %   Check to see whether or not all B(i,k) = 0,
        %   i = k+1, ... ,m
        
        GOTO5 = 0;
        for I=K+1:M
            if (B(I,K) ~= 0)
                GOTO5 = 1;
            end
        end
        if (GOTO5 == 1)
            break;
        end
        
        %   Check to see whether or not all B(k,j) = 0,
        %   j = k+1, ... ,n
        
        for J=K+1:N
            if (B(K,J) ~= 0)
                GOTO5 = 1;
            end
        end
        if (GOTO5 == 1)
            break;
        end
        %
        %   Replace row k by row k + row p  if u ~= 0
        u = TFD(K,M,N,B);
        if u == 0
            break;
        else
            for J=K:MPLUSN
                B(K,J)=B(K,J)+B(u,J);
            end
        end
        
    end  % end while (u ~= 0)
    
    if (GOTO5 == 0)
        U = B(1:M,N+1:MPLUSN) * U;
        V = V * B(M+1:MPLUSN,1:N);
        B(1:M,N+1:MPLUSN) = vpi(eye(M));
        B(M+1:MPLUSN,1:N) = vpi(eye(N));
        K = K + 1;
    end
    
end  % end while (K <= L)

B = round(B);

% Store invariant factors in IVF
S = Types.zeros(1, L, typeName);
for I=1:L
    S(I)=B(I,I);
end
end


function [I,J,T] = NMZ(K,M,N,A)
%
%  T is set equal to 0 if Ak = 0; otherwise t is set equal to abs(A(i,j)),
%  where A(i,j) is a nonzero element which is least in absolute value.
%
%
%  Original Fortran version written by Morris Newman.
%  Adapted to Matlab with multiplier systems by Greg Wilson.

for I=K:M
    for J=K:N
        T = abs(A(I,J));
        if (T ~= 0); break; end
    end
    if (T ~= 0); break; end
end
if (T == 0); return; end
for U=K:M
    for V=K:N
        S = abs(A(U,V));
        if (S ~= 0) && (S < T)
            T = S;
            I = U;
            J = V;
        end
    end
end
end


function [T] = TFD(K,M,N,A)
%
%  T is set equal to 0 if Ak is congruent to 0 modulo A(k,k); otherwise,
%  Tis set equal to p, where A(p,q) is an element of Ak which is not
%  divisible by A(k,k)
%
%
%  Original Fortran version written by Morris Newman.
%  Adapted to Matlab with multiplier systems by Greg Wilson.

T=0;
for I=K:M
    for J=K:N
        if (mod(A(I,J),A(K,K)) ~= 0)
            T = I;
            return
        end
    end
end
end
