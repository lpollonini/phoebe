function varargout = create_pairings(varargin)
% CREATE_PAIRINGS MATLAB code for create_pairings.fig
%      CREATE_PAIRINGS, by itself, creates a new CREATE_PAIRINGS or raises the existing
%      singleton*.
%
%      H = CREATE_PAIRINGS returns the handle to a new CREATE_PAIRINGS or the handle to
%      the existing singleton*.
%
%      CREATE_PAIRINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATE_PAIRINGS.M with the given input arguments.
%
%      CREATE_PAIRINGS('Property','Value',...) creates a new CREATE_PAIRINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before create_pairings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to create_pairings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help create_pairings

% Last Modified by GUIDE v2.5 15-Sep-2018 15:51:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @create_pairings_OpeningFcn, ...
                   'gui_OutputFcn',  @create_pairings_OutputFcn, ...
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


% --- Executes just before create_pairings is made visible.
function create_pairings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to create_pairings (see VARARGIN)

% Choose default command line output for create_pairings
handles.output = hObject;

handles_main = findobj('Tag','figure_main');
main_data = guidata(handles_main);

set(handles.text_dig_filename,'String',['Digitization file = ' main_data.dig_pts_path])

pairings_path = [main_data.dig_pts_path(1:end-4) '_pairings.SD'];
set(handles.text_pairings_filename,'String',['Source-Detector Pairings_file = ' pairings_path]);
% save(pairings_path,'SD');
% save([pwd filesep 'init.mat'],'pairings_path','-append')

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes create_pairings wait for user response (see UIRESUME)
% uiwait(handles.figure_create_pairings);


% --- Executes on button press in pushbutton_create_pairings.
function pushbutton_create_pairings_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_create_pairings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Choose default command line output for create_pairings
handles.output = hObject;

handles_main = findobj('Tag','figure_main');
main_data = guidata(handles_main);

main_data = load_dig_pts(main_data,main_data.dig_pts_path);
det_pts = main_data.det_pts;
src_pts = main_data.src_pts;
idx_min_cell=rangesearch(det_pts,src_pts,str2double(get(handles.edit_min_optode_distance,'String')));
idx_max_cell=rangesearch(det_pts,src_pts,str2double(get(handles.edit_max_optode_distance,'String')));
for i = 1:size(idx_max_cell,1)
    idx{i,1}=setdiff(idx_max_cell{i,1},idx_min_cell{i,1});
end
row=1;
MeasList=[];
for i=1:size(src_pts,1)
    det_conn=sort(idx{i,1});
    for j=1:length(det_conn)
        MeasList(row,:)=[i det_conn(j) 1 1];
        row=row+1;
    end
end
% convert for NIRS toolbox format
SD.SrcPos = src_pts;
SD.DetPos = det_pts;
SD.nSrcs = size(src_pts,1);
SD.nDets = size(det_pts,1);
MeasList2 = MeasList;
MeasList2(:,4) = 2;
SD.MeasList = [MeasList; MeasList2];
pairings_path = [main_data.dig_pts_path(1:end-4) '_pairings.SD'];
set(handles.text_pairings_filename,'String',['Source-Detector Pairings_file = ' pairings_path]);
save(pairings_path,'SD');
save([pwd filesep 'init.mat'],'pairings_path','-append')
main_data.pairings_path = pairings_path;
guidata(handles_main, main_data);
close(handles.figure_create_pairings)


%% GARBAGE GUI
% --- Outputs from this function are returned to the command line.
function varargout = create_pairings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_max_optode_distance_Callback(hObject, eventdata, handles)
% hObject    handle to edit_max_optode_distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_max_optode_distance as text
%        str2double(get(hObject,'String')) returns contents of edit_max_optode_distance as a double


% --- Executes during object creation, after setting all properties.
function edit_max_optode_distance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_max_optode_distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_min_optode_distance_Callback(hObject, eventdata, handles)
% hObject    handle to edit_min_optode_distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_min_optode_distance as text
%        str2double(get(hObject,'String')) returns contents of edit_min_optode_distance as a double


% --- Executes during object creation, after setting all properties.
function edit_min_optode_distance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_min_optode_distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_min_optode_distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_min_optode_distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
