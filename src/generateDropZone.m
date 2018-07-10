function [F, varargout] = generateDropZone(polynomial, height, width, mask)

if ~exist('polynomial', 'var') || isempty(polynomial)
    polynomial = @(y,x) x.*(x.^2-3.*y.^2);
end

if ~exist('height', 'var') || isempty(height)
    height = 128;
end
if ~exist('width', 'var') || isempty(width)
    width = height;
end
if ~exist('mask', 'var') || isempty(mask)
    mask = ones(height, width);
end

addFilter = zeros(3,3);
addFilter(1, 2)= 1;
addFilter(2, 1)= 1;
addFilter(2, 3)= 1;
addFilter(3, 2)= 1;

%% Get all drop numbers
X=repmat((0:width+1) - (width+1)/2, height+2, 1);
Y=repmat(((0:height+1) - (height+1)/2)', 1, width+2);

 if mod(width,2) ~= 1 || mod(height, 2) ~= 1
     X = 2*X;
     Y = 2*Y;
 end
H = polynomial(Y, X);

table = zeros(height+2, width+2);
table(2:end-1, 2:end-1) = mask;
extended = (filter2(addFilter, table) > 0)-table;

%% Separate values which correspond to drop zone, and the ones which correspond to the board
F = H;
F(~extended) = 0;

H(~table) =0;

minVal = min(min(min(H)), min(min(F)));
H = H-minVal;
F = F-minVal;
H(~table) =0;
F(~extended) = 0;

H = H(2:end-1, 2:end-1);

%% Shrink F to drop zone
F = filter2(addFilter, F, 'valid');
F(~mask) = 0;

%% divide by greatest common divisor
values = setdiff(union(unique(H), unique(F)), 0);
divisor = values(1);
for i=2:length(values)
    divisor = gcd(divisor, values(i));
    if divisor == 1
        break;
    end
end
H = H ./divisor;
F = F ./ divisor;

%% Check validity
DeltaH = filter2([0,1,0;1,-4,1;0,1,0], H, 'valid');
if ~all(all(abs(DeltaH)==0))
    warning('InterPile:NotHarmonic', 'Function to generate potential is not harmonic.');
end
assert(all(all(H>=0)), 'InterPile:HarmonicFunctionNegative', 'Harmonic function takes negative values.');
assert(all(all(F>=0)), 'InterPile:PotentialNegative', 'Potential takes negative values');

%% Return values
if nargout > 1
    varargout{1} = H;
end
if nargout > 1
    varargout{2} = divisor;
end

end

