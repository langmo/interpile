classdef Types
    % Working with different data types, including double, int64, sym and vpi,
    % quickly gets a pain in the ... due to many subtle differences. 
    % This class serves as a namespace for many static functions designed
    % to provide a more common interface for all these classes.   
    methods(Static)
        function value = container(varargin)
            typeName = varargin{end};
            if strcmpi(typeName, 'vpi') || strcmpi(typeName, 'sym')
                if nargin>=2
                    dims = [varargin{1:end-1}];
                else
                    dims = 1;
                end
                value = repmat({[]}, dims);
            else
                value = Types.nanValue(varargin{:});
            end
        end
        function value = nanValue(varargin)
            typeName = varargin{end};
            if nargin>=2
                dims = [varargin{1:end-1}];
            else
                dims = 1;
            end
                
            if strcmpi(typeName, 'double') || strcmpi(typeName, 'single')
                value = NaN(dims);
            elseif strcmpi(typeName, 'vpi')
                value = vpi(NaN(dims));
            elseif strcmpi(typeName, 'sym')
                value = sym(NaN(dims));
            else
                value = repmat(intmax(typeName), dims);
            end
        end
        function value = zeros(varargin)
            typeName = varargin{end};
            if nargin>=2
                dims = [varargin{1:end-1}];
            else
                dims = 1;
            end
                
            if strcmpi(typeName, 'double') || strcmpi(typeName, 'single')
                value = zeros(dims);
            elseif strcmpi(typeName, 'vpi')
                value = vpi(zeros(dims));
            elseif strcmpi(typeName, 'sym')
                value = sym(zeros(dims));
            else
                value = repmat(cast(0, typeName), dims);
            end
        end
        function result = istype(value, typeName)
            result = isa(value, typeName);
        end
        function result = idivide(a,b,typeName)
            if nargin < 3
                typeName = Types.gettype(a);
            else
                a = Types.cast2type(a, typeName);
            end
            b = Types.cast2type(b, typeName);
            if strcmpi(typeName, 'double') || strcmpi(typeName, 'single') || strcmpi(typeName, 'sym') 
                result = floor(a./b);
            elseif strcmpi(typeName, 'vpi')
                result = reshape(a./b, size(a));
            else
                result = idivide(a, b,'floor');
            end
            
        end
        function result = gettype(value)
            if iscell(value)
                for i=1:numel(value)
                    if ~strcmpi(class(value{i}), 'double') || ~isempty(value{i})
                        result = class(value{i});
                        return;
                    end
                end
                result = 'double';
            else
                result = class(value);
            end
        end
        function result = isEmptyElem(value, typeName)
            if nargin < 2
                typeName = class(value);
            end
            % For sym & vpi, we use cell arrays, and [] to indicate NaN.
            % Now, [] is of type double. To test if the value is equal to
            % [], we thus can simply test if it is a double. This avoids
            % exidentially calling isempty on a sym, which turns out to be
            % extremely slow...
            if strcmpi(typeName, 'sym') || strcmpi(typeName, 'vpi')
                result = isa(value,'double');
            else
                result =  Types.isnan(value, typeName);
            end
        end
        function value = getElem(array, varargin)
            if iscell(array)
                value = array{varargin{:}};
            else
                value = array(varargin{:});
            end
        end
        function value = toElem(value, typeName)
            if nargin < 2
                typeName = class(value);
            end
            if strcmpi(typeName, 'sym') || strcmpi(typeName, 'vpi')
                value = {value};        
            end
        end
        function result = isnan(value, typeName)
            if iscell(value) && isempty(value{1})
                % For some data types, we sometimes use cell arrays
                % instead of arrays since they seem to be more
                % economical. 
                result = true;
                return;
            end
            if nargin < 2
                typeName = class(value);
            end
            if strcmpi(typeName, 'int8') || strcmpi(typeName, 'uint8')...
                    || strcmpi(typeName, 'int16') || strcmpi(typeName, 'uint16')...
                    || strcmpi(typeName, 'int32') || strcmpi(typeName, 'uint32')...
                    || strcmpi(typeName, 'int64') || strcmpi(typeName, 'uint64')
                result = value == intmax(typeName);
            else
                result = isnan(value);
            end
        end
        function result = cast2type(value, typeName)
            if strcmpi(class(value), typeName)
                result = value;
            elseif strcmpi(typeName, 'sym')
                if strcmpi(class(value), 'vpi')
                    if max(abs(value)) < flintmax()-1
                        result = sym(double(value));
                    else
                        result = reshape(arrayfun(@(idx)sym([repmat('-', 1, value(idx)<0), arrayfun(@(x)int2str(x),vpi2base(value(idx), 10))]), 1:numel(value)), size(value));
                    end
                else
                    result = sym(value);
                end
            elseif strcmpi(typeName, 'vpi')
                if strcmpi(class(value), 'sym')
                    temp = arrayfun(@(x)vpi(char(x)), value, 'UniformOutput', false);
                    result = reshape([temp{:}], size(value));
                else
                    result = vpi(value);
                end
            elseif strcmpi(class(value), 'vpi')
                if strcmpi(typeName, 'double')
                    result = double(value);
                elseif strcmpi(typeName, 'single')
                    result = single(value);
                else
                    result = cast2type(double(value), typeName);
                end
            else
                result = cast(value, typeName);
            end
        end
    end
end

