function varargout = digitizer_settings(varargin)
% DIGITIZER_SETTINGS MATLAB code for digitizer_settings.fig
%      DIGITIZER_SETTINGS, by itself, creates a new DIGITIZER_SETTINGS or raises the existing
%      singleton*.
%
%      H = DIGITIZER_SETTINGS returns the handle to a new DIGITIZER_SETTINGS or the handle to
%      the existing singleton*.
%
%      DIGITIZER_SETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIGITIZER_SETTINGS.M with the given input arguments.
%
%      DIGITIZER_SETTINGS('Property','Value',...) creates a new DIGITIZER_SETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before digitizer_settings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to digitizer_settings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help digitizer_settings

% Last Modified by GUIDE v2.5 23-Sep-2018 11:33:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @digitizer_settings_OpeningFcn, ...
                   'gui_OutputFcn',  @digitizer_settings_OutputFcn, ...
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


% --- Executes just before digitizer_settings is made visible.
function digitizer_settings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to digitizer_settings (see VARARGIN)

% Choose default command line output for digitizer_settings
handles.output = hObject;

handles_main = findobj('Tag','figure_main');
main_data = guidata(handles_main);

com_list = seriallist;  % Pull a list of available serial ports for digitizer
if ~isempty(com_list)
    for i = 1:length(com_list)
       com_list_cell{i} = com_list(i);  
    end
    set(handles.popupmenu_serial,'String',com_list_cell); 
    set(handles.popupmenu_serial,'Max',length(com_list_cell));
    for i = 1:length(com_list)
        if strcmp(com_list_cell{i},main_data.com_port)
            set(handles.popupmenu_serial,'Value',i);
        end
    end
else
   uiwait(warndlg('This computer does not have any serial port for connecting to Patriot'))
   set(handles.pushbutton_test_patriot,'Enable','off');
   set(handles.text_serial_test,'String','NO SERIAL PORTS','ForegroundColor',[1,0,0]);
end

baudrate_list_cell = get(handles.popupmenu_baudrate,'String');
for i = 1:size(baudrate_list_cell,1)
        if strcmp(baudrate_list_cell{i},main_data.baud_rate)
            set(handles.popupmenu_baudrate,'Value',i);
        end
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes digitizer_settings wait for user response (see UIRESUME)
% uiwait(handles.figure_settings);




% --- Executes on button press in pushbutton_test_patriot.
function pushbutton_test_patriot_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_test_patriot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

com_port_list = get(handles.popupmenu_serial,'String');
com_port = com_port_list{get(handles.popupmenu_serial,'Value'),1};
com = serial(com_port);
baud_rate_list = get(handles.popupmenu_baudrate,'String');
baud_rate = baud_rate_list{get(handles.popupmenu_baudrate,'Value'),1};
com.InputBufferSize = 512;	% Enough to receive any response from Patriot
com.OutputBufferSize = 512;		% Enough to send any command to Patriot
com.BaudRate = str2double(baud_rate);            % Default baud rate (check Patriot backpanel settings)
com.Terminator = {'CR/LF','CR'};
com.Timeout = 5;
fopen(com);
pause(0.1);

set(handles.text_serial_test,'String','TESTING...','ForegroundColor',[0,0,0]);
fprintf(com,'F');
pause(0.1);
response = fscanf(com); % Here it can timeout or have something different than the expected 'F00 F'
if ~isempty(response)
    if response(1:3) == '00F'
        set(handles.text_serial_test,'String','CONNECTED','ForegroundColor',[0,0.9,0]);
        handles.patriot_response = 1;
        handles.com_port = com_port;
        handles.baud_rate = baud_rate;
        set(handles.pushbutton_saveclose,'Enable','on');
    end
else
    set(handles.text_serial_test,'String','UNCONNECTED','ForegroundColor',[1,0,0]);
    handles.patriot_response = 0;
    handles.com_port = com_port;    % remove from final
    handles.baud_rate = baud_rate;  % remove from final
end
fclose(com);
delete(com);
clear com

guidata(hObject, handles);

% --- Executes on button press in pushbutton_saveclose.
function pushbutton_saveclose_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_saveclose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_main = findobj('Tag','figure_main');
main_data = guidata(handles_main);
main_data.com_port = handles.com_port;
main_data.baud_rate = handles.baud_rate;
main_data.patriot_hemisphere = get(handles.popupmenu_orientation,'Value');
save([pwd filesep 'init.mat'],'-struct','main_data','baud_rate','com_port','patriot_hemisphere','-append');
guidata(handles_main, main_data);

close (handles.figure_settings)

%% GARBAGE GUI

% --- Outputs from this function are returned to the command line.
function varargout = digitizer_settings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_baudrate.
function popupmenu_baudrate_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_baudrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_baudrate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_baudrate


% --- Executes during object creation, after setting all properties.
function popupmenu_baudrate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_baudrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenu_orientation.
function popupmenu_orientation_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_orientation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_orientation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_orientation


% --- Executes during object creation, after setting all properties.
function popupmenu_orientation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_orientation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
