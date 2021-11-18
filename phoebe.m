function varargout = phoebe(varargin)
%DESCRIPTION

%PHOEBE MATLAB code for phoebe.fig
%      PHOEBE, by itself, creates a new PHOEBE or raises the existing
%      singleton*.
%
%      H = PHOEBE returns the handle to a new PHOEBE or the handle to
%      the existing singleton*.
%
%      PHOEBE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PHOEBE.M with the given input arguments.
%
%      PHOEBE('Property','Value',...) creates a new PHOEBE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before phoebe_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to phoebe_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help phoebe

% Last Modified by GUIDE v2.5 18-Nov-2021 15:21:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @phoebe_OpeningFcn, ...
                   'gui_OutputFcn',  @phoebe_OutputFcn, ...
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



% --- Executes just before phoebe is made visible.
function phoebe_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to phoebe (see VARARGIN)

containing_dir = mfilename('fullpath');
cd(containing_dir(1:end-7))
% Add that folder plus all subfolders to the path.
addpath(pwd);
addpath(genpath([pwd filesep 'subfunctions']));

%% Choose default command line output for phoebe
handles.output = hObject;

%% Create Patriot and Phoebe parameters tabs
create_tabs;

%% Loads predefined head atlas
load_atlas;

%% Loads initialization parameters (last saved Phoebe settings)

if exist([pwd filesep 'settings.json'],'file') ~= 2
      uiwait(msgbox('File SETTINGS.JSON is missing from the root folder. If it cannot be located, please download it anew from GitHub.'));
else
    settings = jsondecode(fileread('settings.json'));
end
handles.settings = settings;
handles.opacity = settings.opacity;
handles.zoom_index = settings.zoom_index;
handles.axes_left.View = settings.view_left;
handles.axes_right.View = settings.view_right;

% Prepare one or two head models for plotting
if settings.double_view==0
    set(handles.uipanel_head,'SelectedObject',handles.radiobutton_singleview);
    set(handles.axes_left,'Position',[0.25,0.025,0.5,0.95]);
else
    set(handles.uipanel_head,'SelectedObject',handles.radiobutton_doubleview);
    set(handles.axes_left,'Position',[0.05,0.025,0.5,0.95]);
end

% Set solution for plotting
if strcmp(settings.quality_view, "optodes")
    set(handles.uibuttongroup_qc,'SelectedObject',handles.radiobutton_qoptode);
else
    set(handles.uibuttongroup_qc,'SelectedObject',handles.radiobutton_qchannel);
end

% Import digitized layout and transform into atlas space
if ~strcmp(settings.dig_pts_path,'')
    handles = load_dig_pts(handles,settings.dig_pts_path);
    handles.dig_pts_path = settings.dig_pts_path;
    plot_atlas_digpts
    plot_links
else
    plot_atlas_empty
end

% If we know the number of sources, detectors and fiducials, set them on
% the GUI
if ~isfield(handles,'src_num')
    set(handles.source_dropdown,'Value',1);
    set(handles.detector_dropdown,'Value',1);
    set(handles.fiducial_dropdown,'Value',1);
else
    set(handles.source_dropdown,'Value',handles.src_num);
    set(handles.detector_dropdown,'Value',handles.det_num);
    if size(handles.fid_pts,1)==3
        set(handles.fiducial_dropdown,'Value',1);
    else
        set(handles.fiducial_dropdown,'Value',2);
    end
end

% Set all the pre-loaded parameters on the GUI 
set(handles.edit_lowcutoff,'string',num2str(settings.fcut_min));
set(handles.edit_highcutoff,'string',num2str(settings.fcut_max));
set(handles.edit_threshold,'string',num2str(settings.sci_threshold));
set(handles.min_optode_dist_edit,'String',num2str(settings.min_sd_range));
set(handles.max_optode_dist_edit,'String',num2str(settings.max_sd_range));
set(handles.edit_SCIwindow,'string',num2str(settings.sci_window));
set(handles.edit_spectral_threshold,'string',num2str(settings.psp_threshold));
set(handles.slider_opacity,'value',settings.opacity);
handles.baud_rate = settings.baud_rate;
handles.com_port = settings.com_port;
handles.patriot_hemisphere = settings.patriot_hemisphere;
%handles.current_ver = current_ver;

% Update GUI handler and launch GUI inferface
guidata(hObject, handles);
% UIWAIT makes phoebe wait for user response (see UIRESUME)
% uiwait(handles.figure_main);


% Updates graphics when toggling between single and double view
function uipanel_head_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_head 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
if eventdata.NewValue == handles.radiobutton_singleview 
    set(handles.axes_left,'Position',[0.25,0.025,0.5,0.95]);
    set(findall(handles.axes_right),'Visible','off');
end
if eventdata.NewValue == handles.radiobutton_doubleview
    set(handles.axes_left,'Position',[0.05,0.025,0.5,0.95]);
    set(findall(handles.axes_right),'Visible','on');
    set(handles.axes_right,'Visible','off');
end
hold(handles.axes_right,'off')
set(handles.togglebutton_scan,'String','START MONITOR');
set(handles.radiobutton_singleview,'Enable','on');
set(handles.radiobutton_doubleview,'Enable','on');
guidata(hObject, handles);


%% MENU PROBE -> CREATE
function menu_probe_create_Callback(hObject, ~, handles)
uiwait(probe_configuration(handles))
cla(handles.axes_left)
cla(handles.axes_right)
handles = guidata(hObject);
handles = load_dig_pts(handles,handles.dig_pts_path);  % Import digitized layout and transform into atlas space
%handles = load_SD(handles,handles.pairings_path);  % Loads SD pairs to be considered for Phoebe, and saves info into GUI handler
plot_atlas


%% START/STOP MONITORING
function togglebutton_scan_Callback(hObject, ~, handles, FileName, PathName)
% Hint: get(hObject,'Value') returns toggle state of togglebutton_scan

if get(hObject,'Value') %If currently STOPed (not monitoring), execute this LSL preparation steps
    %Update some graphics
    set(handles.togglebutton_scan,'String','STOP MONITORING');
    set(handles.radiobutton_singleview,'Enable','off');
    set(handles.radiobutton_doubleview,'Enable','off');
    drawnow
    
    % Load LSL library
    lib = lsl_loadlib(); 
    if isempty(lib)
       uiwait(msgbox(sprintf('LSL library not loaded.\n\nPlease ensure that the subfolder is included in the MATLAB path.'),'PHOEBE','error'));
       return
    end
    
    % Resolve LSL stream depending on selected software/instrument
    switch(get(handles.popupmenu_device,'value'))
        case 1  % NIRStar
            result = lsl_resolve_byprop(lib,'name','NIRStar');
            if ~isempty(result)
                inlet = lsl_inlet(result{1});
                [~,~] = inlet.pull_chunk();
            else
                uiwait(warndlg(sprintf('LSL stream not found.\n\nPlease PREVIEW or RECORD data in NIRStar and ensure that the LSL streaming is active'),'PHOEBE'))
                set(handles.togglebutton_scan,'String','START MONITORING');
                set(handles.togglebutton_scan,'Value',0);
                set(handles.radiobutton_singleview,'Enable','on');
                set(handles.radiobutton_doubleview,'Enable','on');
                guidata(hObject,handles)
                return
            end
            
            SD = parse_fnirs_channels_nirstar(inlet);
            handles.src_pts = parse_source_coordinates_nirstar(inlet);
            handles.det_pts = parse_detector_coordinates_nirstar(inlet);
            
        case 2  % Aurora
            %TBD
   
        case 3  % OxySOft
            %TBD
    end
    
    % LUCA: it may still be a good idea to check that the LSL stream is
    % consistent with PHOEBE graphics to avoid drawing issues. With the
    % SDpairs infor created above, it should not be too difficult (just
    % check that number of sources, detectors and (maybe) channels all
    % coincide, and we could do it for all devices

    
    % Prepare the LSL buffer (window_time x LSL_channel_count, all devices)
    handles.fs = result{1}.nominal_srate;
    buffer_rows = floor(handles.fs*str2double(get(handles.edit_SCIwindow,'string'))); % Number of frames to be buffered
    lsl_buffer = zeros(buffer_rows,result{1}.channel_count);
    
    % Computes total optodes based on loaded probe 
    num_optodes = size(handles.src_pts,1) + size(handles.det_pts,1); 
    
    % Plot filled markers in red and blue
    hold(handles.axes_right,'on')
    if ~exist('handles.h_src_left','var')
        delete(handles.h_src_left);
        delete(handles.h_det_left);
        delete(handles.h_txt_src_left);
        delete(handles.h_txt_det_left);
        delete(handles.h_links_left);
    end
    h_src_left = scatter3(handles.axes_left,handles.src_pts(:,1),handles.src_pts(:,2),handles.src_pts(:,3),60,'r','fill','SizeData',60,'LineWidth',2);
    h_det_left = scatter3(handles.axes_left,handles.det_pts(:,1),handles.det_pts(:,2),handles.det_pts(:,3),60,'b','fill','s','SizeData',60,'LineWidth',2);
    h_txt_src_left = text(handles.axes_left,handles.src_pts(:,1), handles.src_pts(:,2), handles.src_pts(:,3), [repmat('  ',[size(handles.src_pts,1) 1]) num2str((1:size(handles.src_pts,1))','%d')],'Color','r','FontSize',15,'FontWeight','bold'); % Labels sources
    h_txt_det_left = text(handles.axes_left,handles.det_pts(:,1), handles.det_pts(:,2), handles.det_pts(:,3), [repmat('  ',[size(handles.det_pts,1) 1]) num2str((1:size(handles.det_pts,1))','%d')],'Color','b','FontSize',15,'FontWeight','bold'); % Labels detectors
    
    % Plot links in yellow
    px = zeros(2,size(SD,1));
    py = zeros(2,size(SD,1));
    pz = zeros(2,size(SD,1));
    for i=1:size(SD,1)
        p1 = handles.src_pts(SD(i,1),:);
        p2 = handles.det_pts(SD(i,2),:);
        px(:,i) = [p1(1);p2(1)];
        py(:,i) = [p1(2);p2(2)];
        pz(:,i) = [p1(3);p2(3)];
    end
    h_links_left = line(handles.axes_left,px,py,pz,'Color','y','LineWidth',3);
    % Do the same for right axes 
    if get(handles.uipanel_head,'SelectedObject') == handles.radiobutton_doubleview
        delete(handles.h_src_right);
        delete(handles.h_det_right);
        delete(handles.h_txt_src_right);
        delete(handles.h_txt_det_right);
        delete(handles.h_links_right);
        h_src_right = scatter3(handles.axes_right,handles.src_pts(:,1),handles.src_pts(:,2),handles.src_pts(:,3),60,'r','fill','SizeData',60,'LineWidth',2);
        h_det_right = scatter3(handles.axes_right,handles.det_pts(:,1),handles.det_pts(:,2),handles.det_pts(:,3),60,'b','fill','s','SizeData',60,'LineWidth',2); 
        h_txt_src_right = text(handles.axes_right,handles.src_pts(:,1), handles.src_pts(:,2), handles.src_pts(:,3), [repmat('  ',[size(handles.src_pts,1) 1]) num2str((1:size(handles.src_pts,1))','%d')],'Color','r','FontSize',15,'FontWeight','bold');
        h_txt_det_right = text(handles.axes_right,handles.det_pts(:,1), handles.det_pts(:,2), handles.det_pts(:,3), [repmat('  ',[size(handles.det_pts,1) 1]) num2str((1:size(handles.det_pts,1))','%d')],'Color','b','FontSize',15,'FontWeight','bold');
        h_links_right = line(handles.axes_right,px,py,pz,'Color','y','LineWidth',3);
    end
    
    % Reads the filter parameters from panel and computes bandpass coeffs
    [B,A] = bandpass_coefficients(handles);

else % Stops monitoring
    set(handles.togglebutton_scan,'String','START MONITOR');
    set(handles.radiobutton_singleview,'Enable','on');
    set(handles.radiobutton_doubleview,'Enable','on');
%     handles.h_src_left = h1;
%     handles.h_det_left = h2;
%     delete(handles.h_txt_src_left);
%     delete(handles.h_txt_det_left);
%     delete(handles.h_links_left);
    guidata(hObject,handles);
end

% If START/STOP button is START mode, run this loop indefinitely until the button is toggled
while ishandle(hObject) && get(hObject,'Value')
    
    % Fill lsl_buffer (FIFO) with new data
    lsl_buffer = fill_lsl_buffer(inlet,lsl_buffer);
    
    % Pull fNIRS signals from buffer
    nirs_data1 = lsl_buffer(:,SD(:,3));
    nirs_data2 = lsl_buffer(:,SD(:,4));
    
    % Filter everything but the cardiac component
    filtered_nirs_data1=filtfilt(B,A,nirs_data1);       % Cardiac bandwidth
    filtered_nirs_data1=filtered_nirs_data1./repmat(std(filtered_nirs_data1,0,1),size(filtered_nirs_data1,1),1); % Normalized heartbeat
    filtered_nirs_data2=filtfilt(B,A,nirs_data2);       % Cardiac bandwidth
    filtered_nirs_data2=filtered_nirs_data2./repmat(std(filtered_nirs_data2,0,1),size(filtered_nirs_data2,1),1); % Normalized heartbeat
    
    % Distributes all the measures in the optode "battlefield" matrix
    sci_matrix = zeros(num_optodes,num_optodes);    % Number of optode is from the user's layout, not the machine, hence we may want to check for consistency here?
    power_matrix = zeros(num_optodes,num_optodes);
    fpower_matrix = zeros(num_optodes,num_optodes);
    A_matrix = zeros(num_optodes,num_optodes);
    
     % Compute quality metrics on each channel
    for i = 1 : size(SD,1)
   
        % Compute quality measures on one channel
        [sci,psp,fpsp] = quality_metrics(handles,filtered_nirs_data1(:,i),filtered_nirs_data2(:,i));
        
        % Placing the measures in the battlefield matrix
        sci_matrix(SD(i,1),size(handles.src_pts,1)+SD(i,2)) = sci;    % Adjust not based on machine
        power_matrix(SD(i,1),size(handles.src_pts,1)+SD(i,2)) = psp;
        fpower_matrix(SD(i,1),size(handles.src_pts,1)+SD(i,2)) = fpsp;
        A_matrix(SD(i,1),size(handles.src_pts,1)+SD(i,2)) = 1;   % Adjacency matrix: marks all the active pairs with 1, rest is 0
    end
    
    % Weight boolean matrix: here we set the criteria for passing thresholds
    W = (sci_matrix >= str2double(get(handles.edit_threshold,'string'))) & (power_matrix >= str2double(get(handles.edit_spectral_threshold,'string'))); 
    
    % Display results at the optode level or the channel level
    if get(handles.radiobutton_qoptode,'Value')
        % Computes optodes coupling status: coupled (1), uncoupled (0) or undetermined (-1).
        [optodes_status] = boolean_system(num_optodes,A_matrix,W); 
        optodes_color = zeros(length(optodes_status),3);
        for i=1:length(optodes_status)
            switch(optodes_status(i))
                case 1
                    optodes_color(i,:) = [0 1 0];
                case 0
                    optodes_color(i,:) = [1 0 0];
                case -1
                    optodes_color(i,:) = [1 1 0];
            end
        end
        % Update optodes graphics
        set(h_src_left,'CData',optodes_color(1:size(handles.src_pts,1),:));
        set(h_det_left,'CData',optodes_color(size(handles.src_pts,1)+1:end,:));
        if get(handles.uipanel_head,'SelectedObject')==handles.radiobutton_doubleview
            set(h_src_right,'CData',optodes_color(1:size(handles.src_pts,1),:));
            set(h_det_right,'CData',optodes_color(size(handles.src_pts,1)+1:end,:));
        end
        drawnow
        
    else % Channel solution: update links color
        for i = 1 : size(SD,1)
            if W(SD(i,1),size(handles.src_pts,1)+SD(i,2))
                set(h_links_left(i),'Color','g')
                if get(handles.uipanel_head,'SelectedObject')==handles.radiobutton_doubleview
                    set(h_links_right(i),'Color','g')
                end
            else
                set(h_links_left(i),'Color','r')
                if get(handles.uipanel_head,'SelectedObject')==handles.radiobutton_doubleview
                    set(h_links_right(i),'Color','r')
                end
            end
        end
        drawnow
    end
end


%% CLOSE FUNCTION
% When user attempts to close GUI, then save all the parameters from the panel
function figure_main_CloseRequestFcn(hObject, ~, handles)

handles = guidata(hObject);
handles.settings.fcut_min = str2double(get(handles.edit_lowcutoff,'string'));
handles.settings.fcut_max = str2double(get(handles.edit_highcutoff,'string'));
handles.settings.sci_threshold = str2double(get(handles.edit_threshold,'string'));
if get(handles.uipanel_head,'SelectedObject')==handles.radiobutton_singleview
    handles.settings.double_view = 0;
else
    handles.settings.double_view = 1;
end
if get(handles.uibuttongroup_qc,'SelectedObject') == handles.radiobutton_qoptode
    handles.settings.quality_view = "optodes";
else
    handles.settings.quality_view = "channels";
end
handles.settings.sci_window = str2double(get(handles.edit_SCIwindow,'string'));
handles.settings.psp_threshold = str2double(get(handles.edit_spectral_threshold,'string'));
handles.settings.min_sd_range = str2double(get(handles.min_optode_dist_edit,'String'));
handles.settings.max_sd_range = str2double(get(handles.max_optode_dist_edit,'String'));
handles.settings.opacity = get(handles.slider_opacity,'Value');
handles.settings.view_left = get(handles.axes_left,'View');
handles.settings.view_right = get(handles.axes_right,'View');
saveJSONfile(handles.settings,[pwd filesep 'settings.json'])
% Hint: delete(hObject) closes the figure
if ~isempty(instrfind)
    fclose(instrfind)
end
set(handles.togglebutton_scan,'String','START MONITOR');
set(handles.radiobutton_singleview,'Enable','on');
set(handles.radiobutton_doubleview,'Enable','on');
delete(hObject);


%% SLIDER OPACITY
function slider_opacity_Callback(hObject, ~, handles)
% hObject    handle to slider_opacity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.opacity = get(hObject,'Value');

if isfield(handles,'fid_pts')
    set(handles.h_scalp_left,'FaceAlpha',handles.opacity)
    if ~isempty(allchild(handles.axes_right))
        set(handles.h_scalp_right,'FaceAlpha',handles.opacity)
    end
else
    plot_atlas_empty;
end
guidata(hObject, handles);


%% SLIDER ZOOM
% --- Executes on slider movement.
function slider_zoom_Callback(hObject, eventdata, handles)
% hObject    handle to slider_zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.zoom_index = 1 - get(hObject,'Value');
if isfield(handles,'fid_pts')
    set(handles.axes_left,'XLim',[-90-80*handles.zoom_index 90+80*handles.zoom_index])
    set(handles.axes_left,'YLim',[-120-200*handles.zoom_index 90+130*handles.zoom_index])
    set(handles.axes_left,'ZLim',[-70-60*handles.zoom_index 100+200*handles.zoom_index])
    if ~isempty(allchild(handles.axes_right))
        set(handles.axes_right,'XLim',[-90-80*handles.zoom_index 90+80*handles.zoom_index])
        set(handles.axes_right,'YLim',[-120-200*handles.zoom_index 90+130*handles.zoom_index])
        set(handles.axes_right,'ZLim',[-70-60*handles.zoom_index 100+200*handles.zoom_index])
    end
    
else
    plot_atlas_empty;
end
guidata(hObject, handles);


%% LOAD PROBE
function menu_probe_load_Callback(hObject, ~, handles)
%
set(handles.uipanel_head,'SelectedObject',handles.radiobutton_doubleview);
cla(handles.axes_left);
cla(handles.axes_right);
[FileName,PathName] = uigetfile('*.txt','Select the subject digitization file','C:\Users\owner\Desktop\Digitization\*.txt');
if FileName
    dig_pts_path = [PathName FileName];
    idx_slash = strfind(dig_pts_path,'\');
    dig_pts_path(idx_slash) = '/';
    handles.settings.dig_pts_path = dig_pts_path;
    saveJSONfile(handles.settings,[pwd filesep 'settings.json'])
    handles.dig_pts_path = dig_pts_path;
    handles = load_dig_pts(handles,handles.dig_pts_path);  % Import digitized layout and transform into atlas space
    plot_atlas_digpts
    plot_links
    guidata(hObject, handles);
end


%% MENU TOOLS -> CONVERT PATRIOT TO MNI
% --------------------------------------------------------------------
function menu_patriot2mni_Callback(hObject, ~, handles)
% hObject    handle to menu_patriot2mni (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'dig_pts_path')
    current_dig_pts_path = handles.dig_pts_path;
    [current_dig_pts_path,~,~] = fileparts(current_dig_pts_path);
else
    current_dig_pts_path = [pwd filesep '*.txt'];
end
[FileName,PathName] = uigetfile('*.txt','Select the digitization file',current_dig_pts_path);
if not(FileName)
    return
end
dig_pts_path = [PathName FileName];
handles = load_dig_pts(handles,dig_pts_path);  % Import digitized layout and transform into atlas space

[FileName,PathName] = uiputfile('*.txt','Saving the subject digitization file',[PathName FileName(1:end-4) '_mni.txt']);
if not(FileName)
    return
end
fileID = fopen([PathName FileName],'w');
fprintf(fileID,'nz: %.1f %.1f %.1f\n',handles.fid_pts(1,1),handles.fid_pts(1,2),handles.fid_pts(1,3));
fprintf(fileID,'ar: %.1f %.1f %.1f\n',handles.fid_pts(2,1),handles.fid_pts(2,2),handles.fid_pts(2,3));
fprintf(fileID,'al: %.1f %.1f %.1f\n',handles.fid_pts(3,1),handles.fid_pts(3,2),handles.fid_pts(3,3));

for i = 1:length(handles.src_pts)
    fprintf(fileID,'s%d: %.1f %.1f %.1f\n',i,handles.src_pts(i,1),handles.src_pts(i,2),handles.src_pts(i,3));
end
for i = 1:1:length(handles.det_pts)
    fprintf(fileID,'d%d: %.1f %.1f %.1f\n',i,handles.det_pts(i,1),handles.det_pts(i,2),handles.det_pts(i,3));
end
fclose(fileID);


%% MENU TOOLS -> NEW RANGE
% --------------------------------------------------------------------
function menu_range2pairings_Callback(hObject, ~, handles)
% hObject    handle to menu_range2pairings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);
uiwait(create_pairings(handles))
handles_main = findobj('Tag','figure_main');
handles = guidata(handles_main);
handles = load_dig_pts(handles,handles.dig_pts_path);  % Import digitized layout and transform into atlas space
handles = load_SD(handles,handles.pairings_path);  % Loads SD pairs to be considered for Phoebe, and saves info into GUI handler
cla(handles.axes_left);
cla(handles.axes_right);
plot_atlas
guidata(hObject, handles);


%% MENU ABOUT -> CHECK UPDATE
function menu_check_update_Callback(hObject, ~, handles)
% hObject    handle to menu_check_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
current_ver = handles.current_ver;
h_msgchk = msgbox('Checking for updated version...','PHOEBE');
latest_ver = str2double(webread('https://www.uh.edu/tech/pollonini/phoebe/version.txt'));
if current_ver < latest_ver
    close(h_msgchk);
    uiwait(msgbox('A new version of PHOEBE is available on Bitbucket','PHOEBE','replace'));
%     choice = questdlg('A new version of PHOEBE is available. Would you like to update it?','Settings','Yes','No','Yes');
%     if strcmp(choice,'Yes') % download new version of phoebe
%         current_ver = latest_ver;
%         save([pwd filesep 'init.mat'],'current_ver','-append');
%         !phoebe_update.exe&
%         exit
%         %Either exit the application from here, or let Update kill it
%     end
else
    uiwait(msgbox('PHOEBE is up to date','PHOEBE','replace'));
end

%% DIGITIZE BUTTON
% --- Executes on button press in pushbutton_digitize.
function [handles] = pushbutton_digitize_Callback(hObject, ~, handles)
% hObject    handle to pushbutton_digitize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% patriotGUIcodeREALTIME

[handles] = patriot(handles);
guidata(hObject,handles); 


%% MENU PREFERENCES
% --------------------------------------------------------------------
function menu_settings_Callback(hObject, ~, handles)
% hObject    handle to menu_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiwait(digitizer_settings(handles))



%% GARBAGE GUI FUNCTIONS

% Outputs from this function are returned to the command line.
function varargout = phoebe_OutputFcn(hObject, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function menu_online_help_Callback(hObject, ~, handles)
% hObject    handle to menu_online_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
url = 'https://github.com/lpollonini/phoebe/wiki';
web(url,'-browser')

% --------------------------------------------------------------------
function menu_about_Callback(hObject, ~, handles)
% hObject    handle to menu_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_tools_Callback(hObject, eventdata, handles)
% hObject    handle to menu_tools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_probe_Callback(hObject, eventdata, handles)
% hObject    handle to menu_probe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_help_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_digitizer_Callback(hObject, eventdata, handles)
% hObject    handle to menu_digitizer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in radiobutton8.
function radiobutton8_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton8


% --- Executes on button press in radiobutton9.
function radiobutton9_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton9


% --------------------------------------------------------------------
function menu_probe_load_empty_Callback(hObject, eventdata, handles)
% hObject    handle to menu_probe_load_empty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

plot_atlas_empty


% --- Executes on slider movement.
function slider_sci_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to slider_sci_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

Value = round(get(hObject, 'Value'),2);
set(hObject, 'Value', Value);
set(handles.edit_threshold,'String',num2str(get(hObject,'Value')));


% --- Executes during object creation, after setting all properties.
function slider_sci_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_sci_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_psp_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to slider_psp_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

Value = round(get(hObject, 'Value'),2)
set(hObject, 'Value', Value);
set(handles.edit_spectral_threshold,'String',num2str(get(hObject,'Value')))

% --- Executes during object creation, after setting all properties.
function slider_psp_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_psp_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over slider_sci_threshold.
function slider_sci_threshold_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to slider_sci_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





function edit_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to edit_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_threshold as text
%        str2double(get(hObject,'String')) returns contents of edit_threshold as a double

set(handles.slider_sci_threshold,'Value',str2double(get(hObject,'String')))




function edit_spectral_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to edit_spectral_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_spectral_threshold as text
%        str2double(get(hObject,'String')) returns contents of edit_spectral_threshold as a double

set(handles.slider_psp_threshold,'Value',str2double(get(hObject,'String')))
