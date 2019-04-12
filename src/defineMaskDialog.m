function varargout = defineMaskDialog(varargin)
% DEFINEMASKDIALOG MATLAB code for defineMaskDialog.fig
%      DEFINEMASKDIALOG, by itself, creates a new DEFINEMASKDIALOG or raises the existing
%      singleton*.
%
%      H = DEFINEMASKDIALOG returns the handle to a new DEFINEMASKDIALOG or the handle to
%      the existing singleton*.
%
%      DEFINEMASKDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEFINEMASKDIALOG.M with the given input arguments.
%
%      DEFINEMASKDIALOG('Property','Value',...) creates a new DEFINEMASKDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before defineMaskDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to defineMaskDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help defineMaskDialog

% Last Modified by GUIDE v2.5 25-Jul-2018 13:52:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @defineMaskDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @defineMaskDialog_OutputFcn, ...
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


% --- Executes just before defineMaskDialog is made visible.
function defineMaskDialog_OpeningFcn(figH, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to defineMaskDialog (see VARARGIN)

% Choose default command line output for defineMaskDialog
handles.output = figH;

% Update handles structure
guidata(figH, handles);

figH.UserData = struct();
figH.UserData.setMask = varargin{1};
figH.UserData.updateMasks = varargin{2};
setWindowIcon(figH);

% --- Outputs from this function are returned to the command line.
function varargout = defineMaskDialog_OutputFcn(hObject, eventdata, handles) 
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

% Hints: get(hObject,'String') returns contents of fieldName as text
%        str2double(get(hObject,'String')) returns contents of fieldName as a double


% --- Executes during object creation, after setting all properties.
function fieldName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fieldFormula_Callback(hObject, eventdata, handles)
% hObject    handle to fieldFormula (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fieldFormula as text
%        str2double(get(hObject,'String')) returns contents of fieldFormula as a double


% --- Executes during object creation, after setting all properties.
function fieldFormula_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldFormula (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in fieldApply.
function fieldApply_Callback(hObject, eventdata, handles)
% hObject    handle to fieldApply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
applyMask(hObject);

% --- Executes on button press in fieldApplyClose.
function fieldApplyClose_Callback(hObject, eventdata, handles)
% hObject    handle to fieldApplyClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if applyMask(hObject)
    close(ancestor(hObject,'figure'));
end


function success = applyMask(figH)
figH = ancestor(figH,'figure');
fieldFormula = findall(figH, 'Tag', 'fieldFormula');
formula = fieldFormula.String;
errorMsg = checkMask(formula);
if ~errorMsg
    dlgH = errordlg(sprintf('Mask formula is invalid: %s', errorMsg), 'Invalid Input');
    setWindowIcon(dlgH);
    success = false;
    return;
end
fieldName = findall(figH, 'Tag', 'fieldName');
name = fieldName.String; 
maskFct = @(y,x,i,j,N,M)eval(formula);
try
    figH.UserData.setMask(name, maskFct);
catch ex
    dlgH = errordlg(sprintf('Error while applying mask:: %s', ex.message), 'Error Applying Mask');
    setWindowIcon(dlgH);
    success = false;
    return;
end
success = true;

% --- Executes on button press in fieldSave.
function fieldSave_Callback(hObject, eventdata, handles)
% hObject    handle to fieldSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figH = ancestor(hObject,'figure');
fieldFormula = findall(figH, 'Tag', 'fieldFormula');
formula = fieldFormula.String;
errorMsg = checkMask(formula);
if ~errorMsg
    dlgH = errordlg(sprintf('Mask formula is invalid: %s', errorMsg), 'Invalid Input');
    setWindowIcon(dlgH);
    return;
end
fieldName = findall(figH, 'Tag', 'fieldName');
name = fieldName.String; 
if checkName(name)
    choice = questdlg(['Mask with name ', name, ' already exists. Overwrite?'], ...
        'Mask already exists', ...
        'Yes','No', 'No');
    if strcmpi(choice, 'No')
        return;
    end
end
if ~isdeployed()
    dirName = 'custom_masks';
else
    dirName = fullfile(ctfroot(), 'custom_masks');
end
if ~exist(dirName, 'dir')
    mkdir(dirName);
end
mask = struct();
mask.name = name;
mask.formula = formula; %#ok<STRNU>
maskFileName = strrep(name, ' ', '_');
save(fullfile(dirName, [maskFileName, '.mat']), 'mask');
figH.UserData.updateMasks();

function errorMsg = checkMask(formula)
maskFct = @(y,x,i,j,N,M)evalc(formula);
height = 63;
width = 63;
X=repmat((0:width-1) - (width-1)/2, height, 1);
Y=repmat(((0:height-1) - (height-1)/2)', 1, width);
J=repmat((1:width), height, 1);
I=repmat((1:height)', 1, width);
try
    maskFct(Y,X,I,J, height, width);
catch ex
    errorMsg = ex.message;
    return;
end
errorMsg = [];

function nameUsed = checkName(name)
if ~isdeployed()
    dirName = 'custom_masks';
else
    dirName = fullfile(ctfroot(), 'custom_masks');
end
if ~exist(dirName, 'dir')
    maskFiles = struct([]);
else
    maskFiles = dir(fullfile(dirName, '*.mat'));
end

for i=1:length(maskFiles)
    maskPath = fullfile(dirName, maskFiles(i).name);
    mask = [];
    load(maskPath, 'mask');
    if strcmpi(mask.name, name)
        nameUsed = true;
        return;
    end
end
nameUsed = false;
