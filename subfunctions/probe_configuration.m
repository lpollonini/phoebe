function varargout = probe_configuration(varargin)
% PROBE_CONFIGURATION MATLAB code for probe_configuration.fig
%      PROBE_CONFIGURATION, by itself, creates a new PROBE_CONFIGURATION or raises the existing
%      singleton*.
%
%      H = PROBE_CONFIGURATION returns the handle to a new PROBE_CONFIGURATION or the handle to
%      the existing singleton*.
%
%      PROBE_CONFIGURATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROBE_CONFIGURATION.M with the given input arguments.
%
%      PROBE_CONFIGURATION('Property','Value',...) creates a new PROBE_CONFIGURATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before probe_configuration_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to probe_configuration_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help probe_configuration

% Last Modified by GUIDE v2.5 15-Sep-2018 14:53:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @probe_configuration_OpeningFcn, ...
                   'gui_OutputFcn',  @probe_configuration_OutputFcn, ...
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


% --- Executes just before probe_configuration is made visible.
function probe_configuration_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to probe_configuration (see VARARGIN)

% Choose default command line output for probe_configuration
handles.output = hObject;

handles_main = findobj('Tag','figure_main');
main_data = guidata(handles_main);


handles.faces = main_data.faces;
handles.vertices = main_data.vertices;
handles.patch_head = plot_mesh(handles.axes_head,handles.faces(:,2:4), handles.vertices(:,2:4),0.7);
axis([-100 100 -200 100 -100 150])
view(165, 10);
hold on
handles.opt_counter=1;
handles.src_pts=[];
handles.det_pts=[];
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes probe_configuration wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = probe_configuration_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function dropdown_src_num_Callback(hObject, eventdata, handles)
% hObject    handle to baud_rate_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function dropdown_det_num_Callback(hObject, eventdata, handles)
% hObject    handle to baud_rate_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function edit_min_distance_Callback(hObject, eventdata, handles)
% hObject    handle to baud_rate_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function dropdown_src_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dropdown_src_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function dropdown_det_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dropdown_det_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_configurationOK.
function pushbutton_configurationOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_configurationOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.src_num=get(handles.dropdown_src_num,'value');
handles.det_num=get(handles.dropdown_det_num,'value');
set(handles.dropdown_src_num,'enable','off');
set(handles.dropdown_det_num,'enable','off');
set(handles.edit_min_distance,'enable','off');
set(handles.edit_max_distance,'enable','off');
set(handles.pushbutton_configurationOK,'enable','off');
set(handles.pushbutton_place,'enable','on');
set(handles.togglebutton_rotate_head,'enable','on');
guidata(hObject, handles);

% --- Executes on button press in pushbutton_place.
function pushbutton_place_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_place (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_main = findobj('Tag','figure_main');
main_data = guidata(handles_main);

set(handles.togglebutton_rotate_head,'Enable','off');
set(gcf,'Pointer','cross');
set(handles.axes_head,'HitTest','off')
set(handles.patch_head,'ButtonDownFcn',@patch_click,'PickableParts','all');
drawnow
waitforbuttonpress
data = guidata(hObject);
p=data.p;

if handles.opt_counter<=handles.src_num
    plot3(p(1), p(2), p(3), 'o','MarkerSize',10,'MarkerEdgeColor','r','MarkerFaceColor','r');
    handles.src_pts=[handles.src_pts; p];
    set(handles.pushbutton_place,'string',['Place SOURCE ' num2str(handles.opt_counter+1)])
    if handles.opt_counter==handles.src_num
        set(handles.pushbutton_place,'string','Place Detector 1')
    end
end
if (handles.opt_counter>handles.src_num)&&(handles.opt_counter<=handles.src_num+handles.det_num)
    plot3(p(1), p(2), p(3), 'o','MarkerSize',10,'MarkerEdgeColor','b','MarkerFaceColor','b');
    handles.det_pts=[handles.det_pts; p];
    if handles.opt_counter<handles.src_num+handles.det_num
        set(handles.pushbutton_place,'string',['Place DETECTOR ' num2str(handles.opt_counter-handles.src_num+1)])
    else
        [FileName,PathName] = uiputfile('*.txt','Save the digitized locations of optodes','new_probe.txt');
        fid=fopen([PathName FileName],'w');
        fprintf(fid,'nz: 0.8 84.5 -36.1\n');
        fprintf(fid,'ar: 86.5 -16.5 -51.2\n');
        fprintf(fid,'al: -87.3 -18.6 -50.5\n');
        for i=1:handles.src_num
            fprintf(fid,'s%d: %.1f %.1f %.1f\n',i,handles.src_pts(i,1),handles.src_pts(i,2),handles.src_pts(i,3));
        end
        for i=1:handles.det_num
            fprintf(fid,'d%d: %.1f %.1f %.1f\n',i,handles.det_pts(i,1),handles.det_pts(i,2),handles.det_pts(i,3));
        end
        fclose(fid);
        dig_pts_path = [PathName FileName];
        save([pwd filesep 'init.mat'],'dig_pts_path','-append')
        main_data.dig_pts_path = dig_pts_path; 
        
        min_pts_range = str2double(get(handles.edit_min_distance,'String'));
        max_pts_range = str2double(get(handles.edit_max_distance,'String'));
        det_pts = handles.det_pts;
        src_pts = handles.src_pts;
        idx_min_cell=rangesearch(det_pts,src_pts,min_pts_range);
        idx_max_cell=rangesearch(det_pts,src_pts,max_pts_range);
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
        if ~isempty(MeasList)
            MeasList2 = MeasList;
            MeasList2(:,4) = 2;
            SD.MeasList = [MeasList; MeasList2];
            [FileName,PathName] = uiputfile('*.SD','Save the probe file (MAT struct format)',[PathName FileName(1:end-4) '.SD']);
            save([PathName FileName],'SD','-mat');
            pairings_path = [PathName FileName];
            save([pwd filesep 'init.mat'],'pairings_path','-append')
            main_data.pairings_path = pairings_path;
            for i=1:size(SD.MeasList,1)
                p1 = handles.src_pts(SD.MeasList(i,1),:);
                p2 = handles.det_pts(SD.MeasList(i,2),:);
                p = [p1;p2];
                line(p(:,1),p(:,2),p(:,3),'Color','y');
            end
        else
            SD.MeasList = [];
            warndlg('Empty pairings');
        end
    end
end
if handles.opt_counter==handles.src_num+handles.det_num
    set(handles.pushbutton_place,'string','Placement complete!','enable','off')
    guidata(handles_main, main_data);
    guidata(hObject, handles);
else
    handles.opt_counter=handles.opt_counter+1;
    set(handles.patch_head,'PickableParts','none');
    set(handles.axes_head,'HitTest','on')
    set(gcf,'Pointer','arrow');
    set(handles.togglebutton_rotate_head,'Enable','on');
    guidata(hObject, handles);
end



% --- Executes on button press in togglebutton_rotate_head.
function togglebutton_rotate_head_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_rotate_head (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton_rotate_head
if get(hObject,'Value')==1
    set(handles.togglebutton_rotate_head,'String','Stop 3D Rotate');
     set(handles.pushbutton_place,'Enable','off')
    rotate3d(handles.axes_head,'on')
else
    set(handles.togglebutton_rotate_head,'String','3D Rotate Head');
    set(handles.pushbutton_place,'Enable','on')
    rotate3d(handles.axes_head,'off')
end

function patch_click(hObject,eventdata)

data = guidata(hObject);
data.p = eventdata.IntersectionPoint;
%set(handles.p = eventdata.IntersectionPoint
guidata(hObject, data);



function edit_max_distance_Callback(hObject, eventdata, handles)
% hObject    handle to edit_max_distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_max_distance as text
%        str2double(get(hObject,'String')) returns contents of edit_max_distance as a double


% --- Executes during object creation, after setting all properties.
function edit_max_distance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_max_distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on mouse press over axes background.
function axes_head_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_head (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function patch_head_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_head (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function edit_min_distance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_min_distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
