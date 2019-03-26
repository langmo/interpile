function [H, varargout] = periodicHarmonic(Y,X, coeff1, coeff2, varargin)

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

if mod((length(coeff1)-1)/2, 2) == 0
    harmFun = @evenDiagHarmonic;
else
    harmFun = @oddDiagHarmonic;
end

p = inputParser;
addOptional(p,'typeName', 'double');
addOptional(p,'returnTypeName', []);
parse(p,varargin{:});
typeName = p.Results.typeName;
if isempty(p.Results.returnTypeName)
    returnTypeName = typeName;
else
    returnTypeName = p.Results.returnTypeName;
end

maxXY = max(max(abs(X(:))), max(abs(Y(:))));

if strcmpi(typeName, 'vpi')
    H = vpi(zeros(size(X)));
else
    H = zeros(size(X), typeName);
end
harmonicIds = -2*maxXY:1:2*maxXY;
totalCoeff1 = NaN(1, length(harmonicIds));
totalCoeff2 = NaN(1, length(harmonicIds));
for k = 1:length(harmonicIds)
    id = harmonicIds(k);
    coeffID = id2idx(id, length(coeff1));
    if isnan(coeffID)
        continue;
    end
    if coeff1(abs(coeffID)) ~= 0
        harmonicFct = harmFun(id,1, 'typeName', typeName);
        H = H + sign(coeffID).*coeff1(abs(coeffID)) .* harmonicFct(Y, X);
    end
    if coeff2(abs(coeffID)) ~= 0
        harmonicFct = harmFun(id,2, 'typeName', typeName);
        H = H + sign(coeffID).*coeff2(abs(coeffID)) .* harmonicFct(Y, X);
    end
    
    totalCoeff1(k) = sign(coeffID).*coeff1(abs(coeffID));
    totalCoeff2(k) = sign(coeffID).*coeff2(abs(coeffID));
end

H = Types.cast2type(H, returnTypeName);
if nargout >= 3
    varargout{1} = totalCoeff1;
    varargout{2} = totalCoeff2;
end


end

function idx = id2idx(id, numCoeff)
    id = id + (numCoeff+1)/2;
    vals = [(1:numCoeff), (numCoeff+1)/2, (-1).^(1:numCoeff).*(numCoeff:-1:1), (numCoeff+1)/2];
    while id <= 0
        id = id+length(vals);
    end
    idx = vals(1+mod(id-1, length(vals)));
end