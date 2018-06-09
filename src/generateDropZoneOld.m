function F = generateDropZone(polynomial, height, width)

if ~exist('polynomial', 'var') || isempty(polynomial)
    polynomial = @(y,x) x.*(x.^2-3.*y.^2);
end

if ~exist('height', 'var') || isempty(height)
    height = 128;
end
if ~exist('width', 'var') || isempty(width)
    width = height;
end

%% Get all drop numbers
X=repmat((0:width+1) - (width+1)/2, height+2, 1);
Y=repmat(((0:height+1) - (height+1)/2)', 1, width+2);

 if mod(width,2) ~= 1 || mod(height, 2) ~= 1
     X = 2*X;
     Y = 2*Y;
 end
H = polynomial(Y, X);

DeltaH = filter2([0,1,0;1,-4,1;0,1,0], H, 'valid');
assert(all(all(~DeltaH)));
%% Values at the vertices are not important for algorithm
H(1,1) = 0;
H(1, end) = 0;
H(end, 1) = 0;
H(end, end) = 0;
%% Make all values positive, and drop again values at the vertices
H = H - min(min(H));
H(1,1) = 0;
H(1, end) = 0;
H(end, 1) = 0;
H(end, end) = 0;
%% divide by greatest common divisor
values = setdiff(unique(H), 0);
divisor = values(1);
for i=2:length(values)
    divisor = gcd(divisor, values(i));
    if divisor == 1
        break;
    end
end
H = H ./divisor;

%% Remove all values which do not correspond to drop zone
F = H;
F(2:end-1, 2:end-1) = 0;
F(1,1) = 0;
F(1, end) = 0;
F(end, 1) = 0;
F(end, end) = 0;

%% Shrink to drop zone
addFilter = zeros(3,3);
addFilter(1, 2)= 1;
addFilter(2, 1)= 1;
addFilter(2, 3)= 1;
addFilter(3, 2)= 1;
F = filter2(addFilter, F, 'valid');

end

