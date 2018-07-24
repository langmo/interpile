function varargout = scalingMovieDialog(varargin)
% scalingMovieDialog - Dialog window to configure a new movie showing a
% given sandpile configuration when scaling the domain size.
% Usage:
%   scalingMovieDialog()
%       Opens the dialog box.
%   figH = scalingMovieDialog(...)
%       Returns a handle to the dialog box figure.

% Last Modified by GUIDE v2.5 11-Jul-2018 14:26:17

% Copyright (C) 2018 Moritz Lang
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

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @scalingMovieDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @scalingMovieDialog_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



function autoSetPath(figH)
figH = ancestor(figH,'figure');
fieldPath = findall(figH, 'Tag', 'fieldPath');
if ~isfield(figH.UserData, 'lastAutoPath')
    path = cd();
    ext = '.avi';
else
    [path,fileName,ext] = fileparts(fieldPath.String);
    if ~strcmp(fileName, figH.UserData.lastAutoPath)
        return;
    end
end

fieldHarmonic = findall(figH, 'Tag', 'fieldHarmonic');
polynomial = fieldHarmonic.UserData{fieldHarmonic.Value}{1};
polynomial(polynomial==' ')=[];
polynomial = lower(polynomial);

fieldReferenceSize = findall(figH, 'Tag', 'fieldReferenceSize');
refSize = fieldReferenceSize.UserData(fieldReferenceSize.Value);

fieldReferenceTime = findall(figH, 'Tag', 'fieldReferenceTime');
try    
    refTime = fieldReferenceTime.String;
    refTime = eval(refTime);
catch
    refTime = 0;
end
if ~isfloat(refTime) || numel(refTime) ~= 1 || ~isreal(refTime)
    refTime = 0;
end

fieldTimeScaleLaw = findall(figH, 'Tag', 'fieldTimeScaleLaw');
timeScaleLaw = fieldTimeScaleLaw.UserData(fieldTimeScaleLaw.Value);

if refTime == 0
    fileName = 'scaling_identity';
elseif timeScaleLaw ~= 0
    fileName = sprintf('scaling_identity_fct_%s_refSize_%gx%g_refTime_%g_timeScaling_refSize^%gsize^-%g', polynomial, refSize, refSize, refTime, timeScaleLaw, timeScaleLaw);
else
    fileName = sprintf('scaling_identity_fct_%s_time_%g_noTimeScaling', polynomial, refTime);
end
fieldPath.String = fullfile(path, [fileName, ext]);
figH.UserData.lastAutoPath = fileName;


% --- Executes just before scalingMovieDialog is made visible.
function scalingMovieDialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to scalingMovieDialog (see VARARGIN)

% Choose default command line output for scalingMovieDialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

hObject.UserData = struct();

updateMaxSize(hObject);
updateReferenceSize(hObject);

autoSetPath(hObject);

setWindowIcon();



% --- Outputs from this function are returned to the command line.
function varargout = scalingMovieDialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in fieldMinSize.
function fieldMinSize_Callback(hObject, eventdata, handles)
% hObject    handle to fieldMinSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateMaxSize(hObject);
updateReferenceSize(hObject);

% --- Executes during object creation, after setting all properties.
function fieldMinSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldMinSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
sizes = 1:2:511;
hObject.String = arrayfun(@(x)sprintf('%gx%g', x, x), sizes, 'UniformOutput', false);
hObject.UserData = sizes;

function updateMaxSize(figH)
figH = ancestor(figH,'figure');
fieldMinSize = findall(figH, 'Tag', 'fieldMinSize');
minVal = fieldMinSize.UserData(fieldMinSize.Value);
fieldMaxSize = findall(figH, 'Tag', 'fieldMaxSize');
if isempty(fieldMaxSize.UserData)
    currentSize = 255;
else
    currentSize = fieldMaxSize.UserData(fieldMaxSize.Value);
end
sizes = minVal:2:511;
fieldMaxSize.String = arrayfun(@(x)sprintf('%gx%g', x, x), sizes, 'UniformOutput', false);
fieldMaxSize.UserData = sizes;
idx = find(sizes==currentSize, 1);
if isempty(idx)
    idx = 1;
end
fieldMaxSize.Value = idx;

function updateReferenceSize(figH)
figH = ancestor(figH,'figure');
fieldMinSize = findall(figH, 'Tag', 'fieldMinSize');
minVal = fieldMinSize.UserData(fieldMinSize.Value);
fieldMaxSize = findall(figH, 'Tag', 'fieldMaxSize');
maxVal = fieldMaxSize.UserData(fieldMaxSize.Value);
fieldSizeStep = findall(figH, 'Tag', 'fieldSizeStep');
step = fieldSizeStep.UserData(fieldSizeStep.Value);

fieldReferenceSize = findall(figH, 'Tag', 'fieldReferenceSize');
if isempty(fieldReferenceSize.UserData)
    currentSize = 255;
else
    currentSize = fieldReferenceSize.UserData(fieldReferenceSize.Value);
end
sizes = minVal:step:maxVal;
fieldReferenceSize.String = arrayfun(@(x)sprintf('%gx%g', x, x), sizes, 'UniformOutput', false);
fieldReferenceSize.UserData = sizes;
idx = find(sizes==currentSize, 1);
if isempty(idx)
    fieldReferenceSize.Value = 1;
    autoSetPath(figH);
else
    fieldReferenceSize.Value = idx;
end

% --- Executes on selection change in fieldSizeStep.
function fieldSizeStep_Callback(hObject, eventdata, handles)
% hObject    handle to fieldSizeStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateReferenceSize(hObject);


% --- Executes during object creation, after setting all properties.
function fieldSizeStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldSizeStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

sizes = 2:2:100;
hObject.String = arrayfun(@(x)sprintf('%gx%g', x, x), sizes, 'UniformOutput', false);
hObject.UserData = sizes;


% --- Executes on selection change in fieldMaxSize.
function fieldMaxSize_Callback(hObject, eventdata, handles)
% hObject    handle to fieldMaxSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateReferenceSize(hObject);


% --- Executes during object creation, after setting all properties.
function fieldMaxSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldMaxSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fieldHarmonic.
function fieldHarmonic_Callback(hObject, eventdata, handles)
% hObject    handle to fieldHarmonic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
autoSetPath(hObject);


% --- Executes during object creation, after setting all properties.
function fieldHarmonic_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldHarmonic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
harmonics = harmonicFunctions();
hObject.String = cellfun(@(x)x{1}, harmonics, 'UniformOutput', false);
hObject.UserData = harmonics;


% --- Executes on selection change in fieldReferenceSize.
function fieldReferenceSize_Callback(hObject, eventdata, handles)
% hObject    handle to fieldReferenceSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
autoSetPath(hObject);


% --- Executes during object creation, after setting all properties.
function fieldReferenceSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldReferenceSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fieldReferenceTime_Callback(hObject, eventdata, handles)
% hObject    handle to fieldReferenceTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
autoSetPath(hObject);


% --- Executes during object creation, after setting all properties.
function fieldReferenceTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldReferenceTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fieldTimeScaleLaw.
function fieldTimeScaleLaw_Callback(hObject, eventdata, handles)
% hObject    handle to fieldTimeScaleLaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
autoSetPath(hObject);


% --- Executes during object creation, after setting all properties.
function fieldTimeScaleLaw_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldTimeScaleLaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
laws = 0:1:9;
hObject.String = [{'No scaling'}, arrayfun(@(x)sprintf('t=tref (refSize/size)^(%g)', x), laws(2:end), 'UniformOutput', false)];
hObject.UserData = laws;


function fieldMovieDuration_Callback(hObject, eventdata, handles)
% hObject    handle to fieldMovieDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function fieldMovieDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldMovieDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fieldPath_Callback(hObject, eventdata, handles)
% hObject    handle to fieldPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function fieldPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in fieldSelectPath.
function fieldSelectPath_Callback(hObject, eventdata, handles)
% hObject    handle to fieldSelectPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figH = ancestor(hObject,'figure');
fieldPath = findall(figH, 'Tag', 'fieldPath');
file = get(fieldPath, 'String');
filter = {'*.avi';'*.*'};
[file,path] = uiputfile(filter, 'Save Movie', file);
if ~ischar(file)
    return;
end
[~,~,ext] = fileparts(file);
if ~strcmpi(ext, '.avi')
    file = [file, '.avi'];
end
fieldPath.String = fullfile(path, file);


% --- Executes on button press in fieldCreate.
function fieldCreate_Callback(hObject, eventdata, handles)
% hObject    handle to fieldCreate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figH = ancestor(hObject,'figure');
fieldPath = findall(figH, 'Tag', 'fieldPath');
filePath = fieldPath.String;
if exist(filePath, 'file')
    choice = questdlg(['File ', filePath, ' already exists. Overwrite?'], ...
        'File already exists', ...
        'Yes','No', 'No');
    if strcmpi(choice, 'No')
        return;
    end
end


fieldHarmonic = findall(figH, 'Tag', 'fieldHarmonic');
harmonicFct = fieldHarmonic.UserData{fieldHarmonic.Value}{2};

fieldMinSize = findall(figH, 'Tag', 'fieldMinSize');
minSize = fieldMinSize.UserData(fieldMinSize.Value);

fieldMaxSize = findall(figH, 'Tag', 'fieldMaxSize');
maxSize = fieldMinSize.UserData(fieldMaxSize.Value);

fieldSizeStep = findall(figH, 'Tag', 'fieldSizeStep');
sizeStep = fieldSizeStep.UserData(fieldSizeStep.Value);

domainSizes = repmat((minSize:sizeStep:maxSize)', 1, 2);

fieldReferenceSize = findall(figH, 'Tag', 'fieldReferenceSize');
referenceSize = fieldReferenceSize.UserData(fieldReferenceSize.Value);
referenceSize = [referenceSize,referenceSize];

fieldReferenceTime = findall(figH, 'Tag', 'fieldReferenceTime');
try    
    referenceTime = fieldReferenceTime.String;
    referenceTime = eval(referenceTime);
catch
    errordlg('Reference Domain Time invalid.', 'Invalid Input');
    return;
end
if ~isfloat(referenceTime) || numel(referenceTime) ~= 1 || ~isreal(referenceTime)
    errordlg('Reference Domain Time invalid. Setting to 0.', 'Invalid Input');
    return;
end
fieldTimeScaleLaw = findall(figH, 'Tag', 'fieldTimeScaleLaw');
scalingLaw = fieldTimeScaleLaw.UserData(fieldTimeScaleLaw.Value);

fieldMovieDuration = findall(figH, 'Tag', 'fieldMovieDuration');
movieTime = str2double(fieldMovieDuration.String);
if isnan(movieTime) || ~(movieTime > 0)
    errordlg('Movie duration must be a double greater than zero.', 'Invalid Input');
    return;
end

close(figH);
generateScalingMovie(filePath, domainSizes, harmonicFct, referenceSize, referenceTime, scalingLaw, movieTime);
