function varargout = assembleMovieDialog(varargin)
% assembleMovieDialog - Dialog window to configure the generation of a
% movie from a movie configuration file.
% Usage:
%   assembleMovieDialog()
%       Asks the user for the configuration file and opens the dialog box.
%   assembleMovieDialog([], configPath)
%       Opens the dialog box for the provided movie configuration file
%       (typically config.mat').
%   figH = assembleMovieDialog(...)
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
                   'gui_OpeningFcn', @assembleMovieDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @assembleMovieDialog_OutputFcn, ...
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


% --- Executes just before assembleMovieDialog is made visible.
function assembleMovieDialog_OpeningFcn(figH, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to assembleMovieDialog (see VARARGIN)

% Choose default command line output for assembleMovieDialog
handles.output = figH;

% Update handles structure
guidata(figH, handles);

if isempty(varargin)
    [filename, pathname, ~] = uigetfile({'config.mat', 'InterPile Movies (*.mat)'}, 'Select movie configuration file', 'config.mat');
    if isempty(filename) || (isnumeric(filename) && numel(filename) == 1 && filename == 0)
        close(figH);
        return;
    end
    configPath = fullfile(pathname, filename);
else
    configPath = varargin{2};
end
try
    numSteps = [];
    numRounds = [];
    oldWarn = warning('off','MATLAB:load:variableNotFound');
    load(configPath, 'numSteps', 'numRounds');
    warning(oldWarn);
catch ex
    warning(oldWarn);
    close(figH);
    dlgH = errordlg(['Could not open movie configuration file:\n', ex.message], 'Could not open movie');
    setWindowIcon(dlgH);
    return;
end
if ~exist('numSteps', 'var') || isempty(numSteps)
    close(figH);
    dlgH = errordlg('Movie configuration file does not contain information on number of frames.', 'Could not open movie');
    setWindowIcon(dlgH);
    return;
end
if ~exist('numRounds', 'var') || isempty(numRounds)
    numRounds = 1;
end

[folder, ~, ~] = fileparts(configPath);
[folder, baseName, ext] = fileparts(folder);
baseName = [baseName, ext];
idx = strfind(baseName, '_frames');
if ~isempty(idx)
    baseName = baseName(1:idx(end)-1);
end
filePath = fullfile(folder, [baseName, '.avi']);
fieldPath = findall(figH, 'Tag', 'fieldPath');
fieldPath.String = filePath;

deltaT = max(round(numSteps/600), 1);
fieldFrames = findall(figH, 'Tag', 'fieldFrames');
deltaT = max(min(numel(fieldFrames.UserData), deltaT), 1);
fieldFrames.Value = deltaT;

movieDuration = round(1/3*numSteps/deltaT*numRounds);
fieldDuration = findall(figH, 'Tag', 'fieldDuration');
fieldDuration.String = movieDuration;

figH.UserData = struct();
figH.UserData.numRounds = numRounds;
figH.UserData.configPath = configPath;

setWindowIcon();


% --- Outputs from this function are returned to the command line.
function varargout = assembleMovieDialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function fieldDuration_Callback(hObject, eventdata, handles)
% hObject    handle to fieldDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function fieldDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fieldFrames.
function fieldFrames_Callback(hObject, eventdata, handles)
% hObject    handle to fieldFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function fieldFrames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
frames = 1:1:20;
hObject.String = arrayfun(@(x)sprintf('%g', x), frames, 'UniformOutput', false);
hObject.UserData = frames;


% --- Executes on button press in fieldShowState.
function fieldShowState_Callback(hObject, eventdata, handles)
% hObject    handle to fieldShowState (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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


% --- Executes on button press in fieldGenerateMovie.
function fieldGenerateMovie_Callback(hObject, eventdata, handles)
% hObject    handle to fieldGenerateMovie (see GCBO)
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

fieldMovieType = findall(figH, 'Tag', 'fieldMovieType');
smallMovie = fieldMovieType.Value == 2;

fieldMovieDuration = findall(figH, 'Tag', 'fieldDuration');
movieTime = str2double(fieldMovieDuration.String);
if isnan(movieTime) || ~(movieTime > 0)
    errordlg('Movie duration must be a double greater than zero.', 'Invalid Input');
    return;
end
timePerRound = movieTime / figH.UserData.numRounds;

fieldShowState = findall(figH, 'Tag', 'fieldShowState');
showState = fieldShowState.Value ~= 0;

fieldFrames = findall(figH, 'Tag', 'fieldFrames');
deltaT = fieldFrames.UserData(fieldFrames.Value);

configPath = figH.UserData.configPath;
try
    assembleMovie(filePath, configPath, timePerRound, smallMovie, 1, deltaT, showState);
catch ex
    dlgH = errordlg(['Could not generate movie:\n', ex.message], 'Could not generate movie');
    setWindowIcon(dlgH);
    return;
end
close(figH);



% --- Executes on selection change in fieldMovieType.
function fieldMovieType_Callback(hObject, eventdata, handles)
% hObject    handle to fieldMovieType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fieldMovieType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fieldMovieType


% --- Executes during object creation, after setting all properties.
function fieldMovieType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldMovieType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
