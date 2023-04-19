function varargout = defineBackgroundDialog(varargin)
% DEFINEBACKGROUNDDIALOG MATLAB code for defineBackgroundDialog.fig
%      DEFINEBACKGROUNDDIALOG, by itself, creates a new DEFINEBACKGROUNDDIALOG or raises the existing
%      singleton*.
%
%      H = DEFINEBACKGROUNDDIALOG returns the handle to a new DEFINEBACKGROUNDDIALOG or the handle to
%      the existing singleton*.
%
%      DEFINEBACKGROUNDDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEFINEBACKGROUNDDIALOG.M with the given input arguments.
%
%      DEFINEBACKGROUNDDIALOG('Property','Value',...) creates a new DEFINEBACKGROUNDDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before defineBackgroundDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to defineBackgroundDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help defineBackgroundDialog

% Last Modified by GUIDE v2.5 03-Nov-2020 07:36:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @defineBackgroundDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @defineBackgroundDialog_OutputFcn, ...
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


% --- Executes just before defineBackgroundDialog is made visible.
function defineBackgroundDialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to defineBackgroundDialog (see VARARGIN)

% Choose default command line output for defineBackgroundDialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

figH = ancestor(hObject,'figure');
figH.UserData = struct();
if length(varargin) < 1 || isempty(varargin{1})
    figH.UserData.variables = struct();
    figH.UserData.variables.S = zeros(63, 63);
    figH.UserData.variables.A = zeros(63, 63);
    figH.UserData.variables.B = zeros(63, 63);
    figH.UserData.variables.C = zeros(63, 63);
    figH.UserData.variables.D = zeros(63, 63);
else
    figH.UserData.variables = varargin{1};
end
if length(varargin) < 2 || isempty(varargin{2})
    figH.UserData.callback = @(T)T;
else
    figH.UserData.callback = varargin{2};
end
setWindowIcon(figH);

% --- Outputs from this function are returned to the command line.
function varargout = defineBackgroundDialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function formulaField_Callback(hObject, eventdata, handles)
% hObject    handle to formulaField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function formulaField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to formulaField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in applyField.
function applyField_Callback(figH, eventdata, handles)
% hObject    handle to applyField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figH = ancestor(figH,'figure');
fieldFormula = findall(figH, 'Tag', 'formulaField');
formula = fieldFormula.String;

try
    background = cell2mat(cellfun(@(x)str2num(x), formula, 'UniformOutput', false));
    figH.UserData.callback(background);
catch ex
    dlgH = errordlg(sprintf('Error while calculating sandpile from background pattern: %s', ex.message), 'Error Calculating Sandpile');
    setWindowIcon(dlgH);
    return;
end
