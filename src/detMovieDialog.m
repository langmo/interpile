function varargout = detMovieDialog(varargin)
% DETMOVIEDIALOG MATLAB code for detMovieDialog.fig
%      DETMOVIEDIALOG, by itself, creates a new DETMOVIEDIALOG or raises the existing
%      singleton*.
%
%      H = DETMOVIEDIALOG returns the handle to a new DETMOVIEDIALOG or the handle to
%      the existing singleton*.
%
%      DETMOVIEDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DETMOVIEDIALOG.M with the given input arguments.
%
%      DETMOVIEDIALOG('Property','Value',...) creates a new DETMOVIEDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before detMovieDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to detMovieDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help detMovieDialog

% Last Modified by GUIDE v2.5 04-Jun-2018 17:11:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @detMovieDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @detMovieDialog_OutputFcn, ...
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


% --- Executes just before detMovieDialog is made visible.
function detMovieDialog_OpeningFcn(figH, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to detMovieDialog (see VARARGIN)

% Choose default command line output for detMovieDialog
handles.output = figH;

% Update handles structure
guidata(figH, handles);

figH.UserData = struct();
if ~isempty(varargin)
    figH.UserData.S = varargin{1};
else
    figH.UserData.S = nullPile(64, 64);
end
fieldStart_Callback(figH, eventdata, handles);
fieldMode_Callback(figH, eventdata, handles);
autoSetPath(figH);


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

fieldMode = findall(figH, 'Tag', 'fieldMode');
if fieldMode.Value == 2
    polynomial = 'custom';
elseif fieldMode.Value == 3
    fieldDropZone = findall(figH, 'Tag', 'fieldDropZone');
    polynomial = fieldDropZone.UserData{fieldDropZone.Value}.name;
    polynomial(polynomial==' ')=[];
    polynomial = lower(polynomial);
else
    fieldHarmonic = findall(figH, 'Tag', 'fieldHarmonic');
    polynomial = fieldHarmonic.UserData{fieldHarmonic.Value}{1};
    polynomial(polynomial==' ')=[];
    polynomial = lower(polynomial);
end

fieldStart = findall(figH, 'Tag', 'fieldStart');
start = fieldStart.String{fieldStart.Value};
start(start==' ')=[];
start = lower(start);
if fieldMode.Value == 3
    X = fieldDropZone.UserData{fieldDropZone.Value}.dropZone();
    width = size(X, 2);
    height = size(X, 1);
elseif fieldStart.Value == 2
    width = size(figH.UserData.S, 2);
    height = size(figH.UserData.S, 1);
else
    fieldWidth = findall(figH, 'Tag', 'fieldWidth');
    fieldHeight = findall(figH, 'Tag', 'fieldHeight');
    
    width = str2double(fieldWidth.String);
    height = str2double(fieldHeight.String);
end

fieldStochDet = findall(figH, 'Tag', 'fieldStochDet');
if fieldStochDet.Value == 2
    stochExtension = '_stoch';
else
    stochExtension = '';
end

fileName = sprintf('%s_fct_%s_%gx%g%s', start, polynomial, height, width, stochExtension);
fieldPath.String = fullfile(path, [fileName, ext]);
figH.UserData.lastAutoPath = fileName;

% --- Outputs from this function are returned to the command line.
function varargout = detMovieDialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function fieldPath_Callback(hObject, eventdata, handles)
% hObject    handle to fieldPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fieldPath as text
%        str2double(get(hObject,'String')) returns contents of fieldPath as a double


% --- Executes during object creation, after setting all properties.
function fieldPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
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

function fieldNumIter_Callback(hObject, eventdata, handles)
% hObject    handle to fieldNumIter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
autoSetPath(hObject);

% --- Executes during object creation, after setting all properties.
function fieldNumIter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldNumIter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fieldStepsPerIter_Callback(hObject, eventdata, handles)
% hObject    handle to fieldStepsPerIter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
autoSetPath(hObject);

% --- Executes during object creation, after setting all properties.
function fieldStepsPerIter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldStepsPerIter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fieldTimePerIter_Callback(hObject, eventdata, handles)
% hObject    handle to fieldTimePerIter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fieldTimePerIter as text
%        str2double(get(hObject,'String')) returns contents of fieldTimePerIter as a double


% --- Executes during object creation, after setting all properties.
function fieldTimePerIter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldTimePerIter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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

fieldMode = findall(figH, 'Tag', 'fieldMode');
if fieldMode.Value == 2
    fieldPolynomial = findall(figH, 'Tag', 'fieldPolynomial');
    polynomialString = fieldPolynomial.String;
    polynomial = @(y,x)eval(polynomialString);
elseif fieldMode.Value == 3
    fieldDropZone = findall(figH, 'Tag', 'fieldDropZone');
    polynomial = fieldDropZone.UserData{fieldDropZone.Value}.dropZone();
else
    fieldHarmonic = findall(figH, 'Tag', 'fieldHarmonic');
    polynomial = fieldHarmonic.UserData{fieldHarmonic.Value}{2};
end

fieldStochDet = findall(figH, 'Tag', 'fieldStochDet');
stochMovie = fieldStochDet.Value == 2;

fieldStepsPerIter = findall(figH, 'Tag', 'fieldStepsPerIter');
stepsPerIter = str2double(fieldStepsPerIter.String);
if isnan(stepsPerIter) || stepsPerIter < 1 || mod(stepsPerIter, 1) ~= 0
    errordlg('Steps per iteration must be an integer greater or equal to one.', 'Invalid Input');
    return;
end

fieldNumIter = findall(figH, 'Tag', 'fieldNumIter');
numIter = str2double(fieldNumIter.String);
if isnan(numIter) || numIter <= 0
    errordlg('Number of iterations must be an double greater than zero.', 'Invalid Input');
    return;
end

fieldTimePerIter = findall(figH, 'Tag', 'fieldTimePerIter');
timePerIter = str2double(fieldTimePerIter.String);
if isnan(timePerIter) || ~(timePerIter > 0)
    errordlg('Time per iteration must be a double greater than zero.', 'Invalid Input');
    return;
end

fieldStart = findall(figH, 'Tag', 'fieldStart');
if fieldStart.Value == 2
    if ~isa(polynomial, 'function_handle')
        errordlg('Mode "Drop Zone" cannot be combined with current sandpile as start pile.', 'Invalid combination');
        return;
    end
    S = figH.UserData.S;    
else
    if isa(polynomial, 'function_handle')
        fieldWidth = findall(figH, 'Tag', 'fieldWidth');
        fieldHeight = findall(figH, 'Tag', 'fieldHeight');

        width = str2double(fieldWidth.String);
        height = str2double(fieldHeight.String);
        if isnan(width) || width < 1 || mod(width, 1) ~= 0 || isnan(height) || height < 1 || mod(height, 1) ~= 0
            errordlg('Sandpile width and height must each be integers greater than zero.', 'Invalid Input');
            return;
        end
    else
        width = size(polynomial, 2);
        height = size(polynomial, 1);
    end
    
    if fieldStart.Value == 1
        S = nullPile(height, width);
    else
        S = (fieldStart.Value-3)*ones(height, width);
    end
end


close(figH);
generateMovie(S, filePath, polynomial, numIter, stepsPerIter, timePerIter, true, stochMovie);


% --- Executes during object creation, after setting all properties.
function fieldCreate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldCreate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function fieldPolynomial_Callback(hObject, eventdata, handles)
% hObject    handle to fieldPolynomial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
autoSetPath(hObject);

% --- Executes during object creation, after setting all properties.
function fieldPolynomial_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldPolynomial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in fieldMode.
function fieldMode_Callback(hObject, eventdata, handles)
% hObject    handle to fieldMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figH = ancestor(hObject,'figure');
fieldMode = findall(figH, 'Tag', 'fieldMode');
if fieldMode.Value == 2
    modeCustom = 'on';
    modeHarmonic = 'off';
    modeDropZone = 'off';
elseif fieldMode.Value == 3
    modeCustom = 'off';
    modeHarmonic = 'off';
    modeDropZone = 'on';
else
    modeCustom = 'off';
    modeHarmonic = 'on';
    modeDropZone = 'off';
end

fieldHarmonic = findall(figH, 'Tag', 'fieldHarmonic');
fieldPolynomial = findall(figH, 'Tag', 'fieldPolynomial');
fieldDropZone = findall(figH, 'Tag', 'fieldDropZone');
textHarmonic = findall(figH, 'Tag', 'textHarmonic');
textPolynomial = findall(figH, 'Tag', 'textPolynomial');
textDropZone = findall(figH, 'Tag', 'textDropZone');

fieldHarmonic.Visible = modeHarmonic;
fieldPolynomial.Visible = modeCustom;
fieldDropZone.Visible = modeDropZone;
textHarmonic.Visible = modeHarmonic;
textPolynomial.Visible = modeCustom;
textDropZone.Visible = modeDropZone;

fieldStart_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function fieldMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
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

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

harmonics = harmonicFunctions();
hObject.String = cellfun(@(x)x{1}, harmonics, 'UniformOutput', false);
hObject.UserData = harmonics;


% --- Executes on selection change in fieldStart.
function fieldStart_Callback(hObject, eventdata, handles)
% hObject    handle to fieldStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fieldStart contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fieldStart
figH = ancestor(hObject,'figure');
fieldStart = findall(figH, 'Tag', 'fieldStart');
fieldMode = findall(figH, 'Tag', 'fieldMode');
if fieldStart.Value == 2 || fieldMode.Value == 3
    showSize = 'off';
else
    showSize = 'on';
end

fieldWidth = findall(figH, 'Tag', 'fieldWidth');
fieldHeight = findall(figH, 'Tag', 'fieldHeight');
textX = findall(figH, 'Tag', 'textX');
textSize = findall(figH, 'Tag', 'textSize');

fieldWidth.Visible = showSize;
fieldHeight.Visible = showSize;
textX.Visible = showSize;
textSize.Visible = showSize;

autoSetPath(hObject);

% --- Executes during object creation, after setting all properties.
function fieldStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function fieldHeight_Callback(hObject, eventdata, handles)
% hObject    handle to fieldHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
autoSetPath(hObject);


% --- Executes during object creation, after setting all properties.
function fieldHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fieldWidth_Callback(hObject, eventdata, handles)
% hObject    handle to fieldWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
autoSetPath(hObject);

% --- Executes during object creation, after setting all properties.
function fieldWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fieldDropZone.
function fieldDropZone_Callback(hObject, eventdata, handles)
% hObject    handle to fieldDropZone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
autoSetPath(hObject);


% --- Executes during object creation, after setting all properties.
function fieldDropZone_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldDropZone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

zones = dropZones();
hObject.String = cellfun(@(x)x.name, zones, 'UniformOutput', false);
hObject.UserData = zones;


% --- Executes on selection change in fieldStochDet.
function fieldStochDet_Callback(hObject, eventdata, handles)
% hObject    handle to fieldStochDet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

autoSetPath(hObject);

% --- Executes during object creation, after setting all properties.
function fieldStochDet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldStochDet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
