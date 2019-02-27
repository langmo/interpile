function [xN, xD] = solveRational(A,b, varargin)
% Solves the equation A*x=b for x, and returns the result in the form of
% x = xN/xD, whereby xN and xD are integers, and numel(xD)=1.
% Thus, it solves the same problem as A\b, however, optimized to give the
% precise rational solution for the case when A and b take values in the
% integers.
% Usage:
%   [xN, xD] = solveRational(A,b)
%       Calculates A\b and returns the result as x=xN/xD, whereby xN and xD
%       are integers, numel(xD)=1 and the greatest common divisor of (all
%       elements of) xN and xD is 1.
%   [xN, xD] = solveRational(A,b, 'typeName', 'vpi')
%       Returns the value as variable precision integers.
% 
% The algorithm uses internally variable precision integers (VPIs), and
% requires the VPI toolbox by John D'Errico:
% https://de.mathworks.com/matlabcentral/fileexchange/22725-variable-precision-integer-arithmetic
% The return values are, however, by default "normal" double values. Use 
% solveRational(_, 'typeName', 'vpi') to return the results in the
% internally used vpi data type and thus to avoid loss of precision.
% The algorithm is based on calculating the Smith Normal Form S = U*A*V.
% The solution of the equation Ax=b thus has to satisfy S V^-1 x = U*b, or
% S y = U*b with y := V^(-1)*x. Since S is diagonal, this is easily
% solvable, and since S and U*b are integer valued, y is rational with
% denumerators directly given by S^-1. We then compute the result x=V*y by
% bringing y onto a common denumerator.
% This function makes heavy use of an algorithm to calculate the Smith
% Normal Form. The original Fortran version of this algorithm was written by Morris Newman.
% This version was adapted to Matlab and the solution changed to a
% multiplier systems by Greg Wilson. Finally, Moritz Lang changed the data
% type to VPI and removed again the multiplier system, which seems to loose
% its advantages once integers can become arbitrarily big.

if ~strcmpi(class(A), 'vpi')
    A = vpi(A);
end
if ~strcmpi(class(b), 'vpi')
    b = vpi(b);
end

p = inputParser;
addOptional(p,'typeName', 'double');
parse(p,varargin{:});

[U, V, S] = SNF(A);

% Solve S y = U*b
% Define y=yN/yD, where yN and yD are integer valued
yD = S;
yN = U * b;
for i=1:length(yN)
    divisor = gcd(yN(i), yD(i));
    yD(i) = yD(i) / divisor;
    yN(i) = yN(i) / divisor;
end

% now, bring everything to a common divisor
divisor = 1;
for i=1:length(yN)
    divisor = lcm(divisor, yD(i));
end
for i=1:length(yN)
    yN(i) = yN(i)*(divisor/ yD(i));
end

% Now we solve x=Vy
xN = V *yN;
xD = divisor;

if strcmpi(p.Results.typeName, 'double')
    xN = double(xN);
    xD = double(xD);
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

[M,N] = size(A);
MPLUSN=M+N;
B = vpi(zeros(MPLUSN));
B(1:M,1:N) = A;

L = min(M,N);
S = vpi(zeros(L,1));

% Set U = I and V = I
B(1:M,N+1:MPLUSN) = vpi(eye(M));
B(M+1:MPLUSN,1:N) = vpi(eye(N));
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
