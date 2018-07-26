function varargout = maskMovieDialog(varargin)
% maskMovieDialog - Dialog window to configure a new movie showing a
% given sandpile configuration when transforming the domain mask.
% Usage:
%   maskMovieDialog()
%       Opens the dialog box.
%   figH = maskMovieDialog(...)
%       Returns a handle to the dialog box figure.

% Last Modified by GUIDE v2.5 26-Jul-2018 12:09:05

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
                   'gui_OpeningFcn', @maskMovieDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @maskMovieDialog_OutputFcn, ...
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

fieldWidth = findall(figH, 'Tag', 'fieldWidth');
fieldHeight = findall(figH, 'Tag', 'fieldHeight');
width = str2double(fieldWidth.String);
height = str2double(fieldHeight.String);

fieldTime = findall(figH, 'Tag', 'fieldTime');
try    
    time = fieldTime.String;
    time = eval(time);
catch
    time = 0;
end
if ~isfloat(time) || numel(time) ~= 1 || ~isreal(time)
    time = 0;
end

fieldName = findall(figH, 'Tag', 'fieldName');
name = fieldName.String;

if time == 0
    fileName = sprintf('domainTrafo_identity_%s_%gx%g', name, height, width);
else
    fileName = sprintf('domainTrafo_identity_%s_fct_%s_time_%g_%gx%g', name, polynomial, time, height, width);
end
fieldPath.String = fullfile(path, [fileName, ext]);
figH.UserData.lastAutoPath = fileName;

% --- Executes just before maskMovieDialog is made visible.
function maskMovieDialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to maskMovieDialog (see VARARGIN)

% Choose default command line output for maskMovieDialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

hObject.UserData = struct();

autoSetPath(hObject);

setWindowIcon(hObject);



% --- Outputs from this function are returned to the command line.
function varargout = maskMovieDialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function fieldName_Callback(hObject, eventdata, handles)
% hObject    handle to fieldName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

autoSetPath(hObject);


% --- Executes during object creation, after setting all properties.
function fieldName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

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



function fieldTime_Callback(hObject, eventdata, handles)
% hObject    handle to fieldTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

autoSetPath(hObject);


% --- Executes during object creation, after setting all properties.
function fieldTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fieldStartTrafo_Callback(hObject, eventdata, handles)
% hObject    handle to fieldStartTrafo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function fieldStartTrafo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldStartTrafo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fieldStepTrafo_Callback(hObject, eventdata, handles)
% hObject    handle to fieldStepTrafo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function fieldStepTrafo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldStepTrafo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fieldEndTrafo_Callback(hObject, eventdata, handles)
% hObject    handle to fieldEndTrafo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function fieldEndTrafo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldEndTrafo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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

fieldMaskFct = findall(figH, 'Tag', 'fieldMaskFct');
maskFct = fieldMaskFct.String;

fieldStartTrafo = findall(figH, 'Tag', 'fieldStartTrafo');
startTrafo = str2double(fieldStartTrafo.String);
if isnan(startTrafo)
    errordlg('Mask parameter start value must be a double.', 'Invalid Input');
    return;
end

fieldStepTrafo = findall(figH, 'Tag', 'fieldStepTrafo');
stepTrafo = str2double(fieldStepTrafo.String);
if isnan(stepTrafo)
    errordlg('Mask parameter step value must be a double.', 'Invalid Input');
    return;
end

fieldEndTrafo = findall(figH, 'Tag', 'fieldEndTrafo');
stopTrafo = str2double(fieldEndTrafo.String);
if isnan(stopTrafo)
    errordlg('Mask parameter stop value must be a double value.', 'Invalid Input');
    return;
end

fieldWidth = findall(figH, 'Tag', 'fieldWidth');
fieldHeight = findall(figH, 'Tag', 'fieldHeight');

width = str2double(fieldWidth.String);
height = str2double(fieldHeight.String);
if isnan(width) || width < 1 || mod(width, 1) ~= 0 || isnan(height) || height < 1 || mod(height, 1) ~= 0
    errordlg('Bounding box width and height must each be integers greater than zero.', 'Invalid Input');
    return;
end

fieldTime = findall(figH, 'Tag', 'fieldTime');
try    
    time = fieldTime.String;
    time = eval(time);
catch
    errordlg('Harmonic time invalid.', 'Invalid Input');
    return;
end
if ~isfloat(time) || numel(time) ~= 1 || ~isreal(time)
    errordlg('Harmonic time invalid.', 'Invalid Input');
    return;
end

fieldMovieDuration = findall(figH, 'Tag', 'fieldMovieDuration');
movieTime = str2double(fieldMovieDuration.String);
if isnan(movieTime) || ~(movieTime > 0)
    errordlg('Movie duration must be a double greater than zero.', 'Invalid Input');
    return;
end

close(figH);
generateMaskMovie(filePath, [height, width], maskFct, startTrafo:stepTrafo:stopTrafo, harmonicFct, time, movieTime)



function fieldMaskFct_Callback(hObject, eventdata, handles)
% hObject    handle to fieldMaskFct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fieldMaskFct as text
%        str2double(get(hObject,'String')) returns contents of fieldMaskFct as a double


% --- Executes during object creation, after setting all properties.
function fieldMaskFct_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldMaskFct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
