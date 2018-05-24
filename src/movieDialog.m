function varargout = movieDialog(varargin)
% MOVIEDIALOG MATLAB code for movieDialog.fig
%      MOVIEDIALOG, by itself, creates a new MOVIEDIALOG or raises the existing
%      singleton*.
%
%      H = MOVIEDIALOG returns the handle to a new MOVIEDIALOG or the handle to
%      the existing singleton*.
%
%      MOVIEDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOVIEDIALOG.M with the given input arguments.
%
%      MOVIEDIALOG('Property','Value',...) creates a new MOVIEDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before movieDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to movieDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help movieDialog

% Last Modified by GUIDE v2.5 07-May-2018 17:21:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @movieDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @movieDialog_OutputFcn, ...
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


% --- Executes just before movieDialog is made visible.
function movieDialog_OpeningFcn(figH, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to movieDialog (see VARARGIN)

% Choose default command line output for movieDialog
handles.output = figH;

% Update handles structure
guidata(figH, handles);

figH.UserData = struct();
if length(varargin) > 0
    figH.UserData.S = varargin{1};
else
    figH.UserData.S = nullPile(64, 64);
end

fieldPath = findall(figH, 'Tag', 'fieldPath');
dims = size(figH.UserData.S);
fieldPath.String = fullfile(cd(), sprintf('harmonic_%gx%g.avi', dims(1), dims(2)));

% UIWAIT makes movieDialog wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = movieDialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in fieldDroparea.
function fieldDroparea_Callback(hObject, eventdata, handles)
% hObject    handle to fieldDroparea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fieldDroparea contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fieldDroparea


% --- Executes during object creation, after setting all properties.
function fieldDroparea_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldDroparea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

harmonics = harmonicDropZones();
hObject.String = cellfun(@(x)x{1}, harmonics, 'UniformOutput', false);
hObject.UserData = cellfun(@(x)x{2}, harmonics, 'UniformOutput', false);



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

% Hints: get(hObject,'String') returns contents of fieldNumIter as text
%        str2double(get(hObject,'String')) returns contents of fieldNumIter as a double


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

% Hints: get(hObject,'String') returns contents of fieldStepsPerIter as text
%        str2double(get(hObject,'String')) returns contents of fieldStepsPerIter as a double


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

fieldDroparea = findall(figH, 'Tag', 'fieldDroparea');
dropArea = fieldDroparea.UserData{fieldDroparea.Value};

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

S = figH.UserData.S;

close(figH);
generateMovie(S, filePath, dropArea, numIter, stepsPerIter, timePerIter);

