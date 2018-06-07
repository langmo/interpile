function [F, varargout] = generateDropZone(polynomial, height, width)

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

%DeltaH = filter2([0,1,0;1,-4,1;0,1,0], H, 'valid');
%assert(all(all(abs(DeltaH)<0.01)));

%% Separate values which correspond to drop zone, and the ones which correspond to the board
F = H;
F(2:end-1, 2:end-1) = 0;
F(1,1) = 0;
F(1, end) = 0;
F(end, 1) = 0;
F(end, end) = 0;

H = H(2:end-1, 2:end-1);

%% Shrink F to drop zone
addFilter = zeros(3,3);
addFilter(1, 2)= 1;
addFilter(2, 1)= 1;
addFilter(2, 3)= 1;
addFilter(3, 2)= 1;
F = filter2(addFilter, F, 'valid');

%% Make all values positive
Ftemp = F;
Ftemp(1,1) = ceil(Ftemp(1,1) / 2);
Ftemp(end,1) = ceil(Ftemp(end,1) / 2);
Ftemp(1,end) = ceil(Ftemp(1,end) / 2);
Ftemp(end,end) = ceil(Ftemp(end,end) / 2);
minVal = min(min(min(H)), min(min(Ftemp))); 

H = H - minVal;
F(1:end, 1) = F(1:end, 1) - minVal;
F(1:end, end) = F(1:end, end) - minVal;
F(1, 1:end) = F(1, 1:end) - minVal;
F(end, 1:end) = F(end, 1:end) - minVal;

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
if nargout > 1
    varargout{1} = H;
end


end

