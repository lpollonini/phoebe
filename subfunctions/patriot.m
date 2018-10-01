function handles = patriot(handles)

plot_atlas_empty
set(handles.pushbutton_digitize,'Enable','off');

try 

%% Setup of serial port
com_port = handles.com_port;
com = serial(com_port);
com.InputBufferSize = 512;	% Enough to receive any response from Patriot
com.OutputBufferSize = 512;		% Enough to send any command to Patriot
baud_rate = handles.baud_rate;
com.BaudRate = str2double(baud_rate);            % Default baud rate (check Patriot backpanel settings)
com.Terminator = {'CR/LF','CR'};
fopen(com);
%com.Terminator = 13; % will stop reading input after this number of inputs
com.ErrorFcn = @timeout_callback;
pause(0.1);

%%Test
fprintf(com,'F'); % print out info for user
pause(0.1);
dummy = fscanf(com);

% Set format to ASCII and check if Patriot is alive (by timeout)
fprintf(com,'F0'); % print out info for user
pause(0.1);
 % Initialize relevant parameters - denoted in user manual
fprintf(com,['U'-64 '1,1']);
pause(0.1);
fprintf(com,['U'-64 '2,1']);
pause(0.1);
fprintf(com,['R'-64 '1']);
pause(0.1);
fprintf(com,['R'-64 '2']);
pause(0.1);
fprintf(com,['B'-64 '1']);
pause(0.1);
fprintf(com,['B'-64 '2']);
pause(0.1);
fprintf(com,'U1');
pause(0.1);
switch handles.patriot_hemisphere
    case 1
        fprintf(com,'H*,1,0,0');
    case 2
        fprintf(com,'H*,-1,0,0');
    case 3
        fprintf(com,'H*,0,1,0');
    case 4
        fprintf(com,'H*,0,-1,0');
    case 5
        fprintf(com,'H*,0,0,1');
    case 6
        fprintf(com,'H*,0,0,-1');
end
pause(0.1);
fprintf(com,'L1,1');
pause(0.1);
fprintf(com,'L2,1');
pause(0.1);
fprintf(com,'O1,2,7,0');
pause(0.1);
fprintf(com,'O2,2,7,1');
pause(0.1);
% while com.BytesAvailable ~= 0
%          dummy = fscanf(com); % creates variable to store doubles and mistakes, to later be disposed of.
% end
% 
% %% Test connection via timeout catch
% 
% com.Timeout = 5; % after this amount of time in seconds, program will end

if com.BytesAvailable ~= 0
    while com.BytesAvailable ~= 0
         dummy = fscanf(com); % creates variable to store doubles and mistakes, to later be disposed of.
    end
end
% else
%     errordlg('Patriot is not responding. Please check the COM port settings.','Patriot error','modal');
%     fclose(com);
%     delete(com);
%     clear com
%     return
% end
%com.Terminator = 'CR/LF';
com.Timeout = 30; % after this amount of time in seconds, program will end

%% Setup of audio cues
listing_alpha = dir([cd filesep 'audio-alphabet' filesep '*.wav']); % sets criteria for the alphabetic side of audio
listing_num = dir([cd filesep 'audio-numbers' filesep '*.wav']); % sets criteria for the numerical side of audio
fs = 8000; % sampling frequency for audio
T = 0.05; % period
t = 0:(1/fs):T;
f = 2500;
a = 0.3;
beep = a*sin(2*pi*f*t);

%% Setup of headgear
ns = get(handles.source_dropdown,'Value'); % number of sources
nd = get(handles.detector_dropdown,'Value'); % number of detectors
fid_idx = get(handles.fiducial_dropdown,'Value'); % get idx of fiducials
% get actual fiducial #
if fid_idx == 1
    nfid = 3;
elseif fid_idx == 2
    nfid = 5;
end
%data = zeros(2*(nfid+ns+nd),7); % create a zero's matrix of appropriate size: # of fiducials + # of sources + # of detectors

%% Acquisition of 3-5 fiducial points
for i = 1:nfid
    switch i
        case 1 % for the first fiducial
            % extracts the desired letter and stores in s,Fs (based on what numerical value the letter has in alphabet) and stores in s,Fs
            set(handles.view_SD,'String','NZ')
            [s,Fs] = audioread([cd filesep 'audio-alphabet' filesep listing_alpha(14).name]);
            sound(s,Fs); 
            pause(0.5)
            [s,Fs] = audioread([cd filesep 'audio-alphabet' filesep listing_alpha(26).name]); 
            sound(s,Fs);

        case 2 % for the second fiducial
            set(handles.view_SD,'String','AR')
            [s,Fs] = audioread([cd filesep 'audio-alphabet' filesep listing_alpha(1).name]);
            sound(s,Fs); 
            pause(0.5) 
            [s,Fs] = audioread([cd filesep 'audio-alphabet' filesep listing_alpha(18).name]);
            sound(s,Fs);

        case 3 % for third fiducial
            set(handles.view_SD,'String','AL')
            [s,Fs] = audioread([cd filesep 'audio-alphabet' filesep listing_alpha(1).name]);
            sound(s,Fs); 
            pause(0.5) 
            [s,Fs] = audioread([cd filesep 'audio-alphabet' filesep listing_alpha(12).name]);
            sound(s,Fs);

        case 4 % for the fourth fiducial
            set(handles.view_SD,'String','CZ')
            [s,Fs] = audioread([cd filesep 'audio-alphabet' filesep listing_alpha(3).name]);
            sound(s,Fs); 
            pause(0.5) 
            [s,Fs] = audioread([cd filesep 'audio-alphabet' filesep listing_alpha(26).name]);
            sound(s,Fs); 

        case 5 % for the 5th fiducial
            set(handles.view_SD,'String','IZ')
            [s,Fs] = audioread([cd filesep 'audio-alphabet' filesep listing_alpha(9).name]);
            sound(s,Fs); 
            pause(0.5) 
            [s,Fs] = audioread([cd filesep 'audio-alphabet' filesep listing_alpha(26).name]);
            sound(s,Fs); % plays desired letter
    end
    response = fscanf(com,'%d %f %f %f %f %f %f %f %d %f %f %f %f %f %f %f',[1,16]); % read data taken from Patriot and store as 1x16 matrix
    pause(0.1)
    sound(beep,fs); % play finishing sound to alert end of acquisition
    pause(1)  
    while com.BytesAvailable ~= 0
         dummy = fscanf(com); % creates variable to store doubles and mistakes, to later be disposed of.
    end
    x1 = 10*response(2);
    y1 = 10*response(3);
    z1 = 10*response(4);
    x2 = 10*response(10);
    y2 = 10*response(11);
    z2 = 10*response(12);
    q0 = response(5);
    q1 = response(6);
    q2 = response(7);
    q3 = response(8);
    R = [q0^2+q1^2-q2^2-q3^2 2*(q1*q2-q0*q3) 2*(q1*q3+q0*q2);...
         2*(q3*q0+q1*q2) q0^2-q1^2+q2^2-q3^2 2*(q2*q3-q0*q1);...
         2*(q1*q3-q0*q2) 2*(q1*q0+q3*q2) q0^2-q1^2-q2^2+q3^2];
    offset=[x2; y2; z2] - [x1; y1; z1];
    v = R'*offset;
    x = v(1);
    y = v(2);
    z = v(3);
    fid_pts(i,:) = [x y z];
end

% Find rigid transformation between Patriot and atlas spaces
[R,t] = rigid_transform_3D(fid_pts(1:3,:), handles.atlas_fid_pts([1 3 2],:)); % Note: fid_pts are the digitized fiducials
%T1=[rt t; 0 0 0 1];

% Applies transformation to bring fiducials into atlas space, and save them in GUI handler to pass it everywhere needed 
fid_pts5 = transform_points(fid_pts,R,t);
handles.fid_pts = fid_pts5(1:3,:);

% Applies scaling factor to best fit Patriot/subjects space to atlas space
[handles.fid_pts,~,~] = scaling(handles.fid_pts,[0 0 0],[0 0 0],handles.atlas_fid_pts,1);

%Plot Fiducials
hold(handles.axes_left,'on')
scatter3(handles.axes_left,handles.atlas_fid_pts(:,1), handles.atlas_fid_pts(:,2), handles.atlas_fid_pts(:,3), 20,'y','fill')
scatter3(handles.axes_left,handles.fid_pts(:,1), handles.fid_pts(:,2), handles.fid_pts(:,3),20,'g','fill') % Plot digitized fiducials after affine transform
text(handles.axes_left,handles.fid_pts(:,1), handles.fid_pts(:,2), handles.fid_pts(:,3), ['  NZ';'  AR';'  AL'],'Color','g');
if get(handles.uipanel_head,'SelectedObject')==handles.radiobutton_doubleview
    hold(handles.axes_right,'on')
    scatter3(handles.axes_right,handles.atlas_fid_pts(:,1), handles.atlas_fid_pts(:,2), handles.atlas_fid_pts(:,3), 20,'y','fill')
    scatter3(handles.axes_right,handles.fid_pts(:,1), handles.fid_pts(:,2), handles.fid_pts(:,3), 20,'g','fill') % Plot digitized fiducials after affine transform
    text(handles.axes_right,handles.fid_pts(:,1), handles.fid_pts(:,2), handles.fid_pts(:,3), ['  NZ';'  AR';'  AL'],'Color','g');
else
    set(handles.axes_right,'Visible','off');
end

%% Acquisition of ns sources
for i = 1:ns  % For all sources...
    set(handles.view_SD,'String',['S', num2str(i)]) % Display current source on GUI
    [s,Fs] = audioread([cd filesep 'audio-alphabet' filesep listing_alpha(19).name]);
    sound(s,Fs); % play desired letter
    pause(0.5) % pause between letters
    [s,Fs] = audioread([cd filesep 'audio-numbers' filesep listing_num(i).name]);
    sound(s,Fs); % play desired number
    response = fscanf(com,'%d %f %f %f %f %f %f %f %d %f %f %f %f %f %f %f',[1,16]); % extract points from Patriot and store in 1x14 matrix
    pause(0.1)
    sound(beep,fs); % finishing beep to notify complete
    pause(1)
    while com.BytesAvailable ~= 0
          dummy = fscanf(com); % stores extra duplicates to later be discarded
    end
    x1 = 10*response(2);
    y1 = 10*response(3);
    z1 = 10*response(4);
    x2 = 10*response(10);
    y2 = 10*response(11);
    z2 = 10*response(12);
    q0 = response(5);
    q1 = response(6);
    q2 = response(7);
    q3 = response(8);
    R = [q0^2+q1^2-q2^2-q3^2 2*(q1*q2-q0*q3) 2*(q1*q3+q0*q2);...
         2*(q3*q0+q1*q2) q0^2-q1^2+q2^2-q3^2 2*(q2*q3-q0*q1);...
         2*(q1*q3-q0*q2) 2*(q1*q0+q3*q2) q0^2-q1^2-q2^2+q3^2];
    offset=[x2; y2; z2] - [x1; y1; z1];
    v = R'*offset;
    x = v(1);
    y = v(2);
    z = v(3);
    src_pts(i,:) = [x y z];
    % Applies transformation to bring current source into atlas space, and save it in GUI handler to pass it everywhere needed 
    handles.src_pts(i,:) = transform_points([x y z],R,t); %inside the loop
    % Applies scaling factor to best fit Patriot/subjects space to atlas space
    [~,handles.src_pts,~] = scaling(handles.fid_pts,handles.src_pts,[0 0 0],handles.atlas_fid_pts,1);
    % Plot current source
    hold(handles.axes_left,'on')
    axis([-100 100 -200 100 -100 150])
    %view([-x,30]) %changes view
    %view(165,10) %default view
    view(134,26) % opposing view
    scatter3(handles.axes_left,handles.src_pts(i,1), handles.src_pts(i,2), handles.src_pts(i,3),60,'r')
    axes(handles.axes_left)
    text(handles.src_pts(i,1), handles.src_pts(i,2),handles.src_pts(i,3),['  ' num2str(i)],'Color','r')
    if get(handles.uipanel_head,'SelectedObject')==handles.radiobutton_doubleview
        hold(handles.axes_right,'on')
        axis([-100 100 -200 100 -100 150])
        %view([-x,30]) %changes view
        %view(165,10) %default
        view(219,26) % opposing view
        scatter3(handles.axes_right,handles.src_pts(i,1), handles.src_pts(i,2), handles.src_pts(i,3),60,'r') 
        axes(handles.axes_right)
        text(handles.src_pts(i,1), handles.src_pts(i,2),handles.src_pts(i,3),['  ' num2str(i)],'Color','r')
        rotate3d on
    else
        set(handles.axes_right,'Visible','off');
    end
end

%% Acquisition of nd detectors
for i = 1:nd % For all detectors
    set(handles.view_SD,'String',['D', num2str(i)])
    [s,Fs] = audioread([cd filesep 'audio-alphabet' filesep listing_alpha(4).name]);
    sound(s,Fs);
    pause(0.5)
    [s,Fs] = audioread([cd filesep 'audio-numbers' filesep listing_num(i).name]);
    sound(s,Fs);
    response = fscanf(com,'%d %f %f %f %f %f %f %f %d %f %f %f %f %f %f %f',[1,16]);
    pause(0.1)
    sound(beep,fs); % finishing beep
    pause(1)
    while com.BytesAvailable ~= 0
        dummy = fscanf(com); % create variable for unwanted data collection, to be discarded later
    end
    x1 = 10*response(2);
    y1 = 10*response(3);
    z1 = 10*response(4);
    x2 = 10*response(10);
    y2 = 10*response(11);
    z2 = 10*response(12);
    q0 = response(5);
    q1 = response(6);
    q2 = response(7);
    q3 = response(8);
    R = [q0^2+q1^2-q2^2-q3^2 2*(q1*q2-q0*q3) 2*(q1*q3+q0*q2);...
         2*(q3*q0+q1*q2) q0^2-q1^2+q2^2-q3^2 2*(q2*q3-q0*q1);...
         2*(q1*q3-q0*q2) 2*(q1*q0+q3*q2) q0^2-q1^2-q2^2+q3^2];
    offset=[x2; y2; z2] - [x1; y1; z1];
    v = R'*offset;
    x = v(1);
    y = v(2);
    z = v(3);
    det_pts(i,:) = [x y z];
    % Applies transformation to bring all points (fds, sources, detectors) into atlas space, and save them in GUI handler to pass it everywhere needed 
    handles.det_pts(i,:) = transform_points([x y z],R,t);
    % Applies scaling factor to best fit Patriot/subjects space to atlas space
    [~,~,handles.det_pts] = scaling(handles.fid_pts,[0 0 0],handles.det_pts,handles.atlas_fid_pts,1);
    %plots current detector
    hold(handles.axes_left,'on')
    scatter3(handles.axes_left,handles.det_pts(i,1), handles.det_pts(i,2), handles.det_pts(i,3),60,'b','s')
    axes(handles.axes_left)
    text(handles.det_pts(i,1), handles.det_pts(i,2),handles.det_pts(i,3),['  ' num2str(i)],'Color','b')
    %view([-x,30]) %changes view
    %view(165,10) %default
    view(219,26) %opposing view
    rotate3d on
    if get(handles.uipanel_head,'SelectedObject')==handles.radiobutton_doubleview 
        scatter3(handles.axes_right,handles.det_pts(i,1), handles.det_pts(i,2), handles.det_pts(i,3),60,'b','s')
        axes(handles.axes_right)
        text(handles.det_pts(i,1), handles.det_pts(i,2),handles.det_pts(i,3),['  ' num2str(i)],'Color','b')
        %view([-x,30]) %changes view
        %view(165,10) %default
        view(134,26) % opposing view
    else
        set(handles.axes_right,'Visible','off');
    end
end
set(handles.view_SD,'String','');
% If all went well, close and remove serial port connection
fclose(com);
delete(com)
clear com

% Save digitization file and make it the new default
[FileName,PathName] = uiputfile('*.txt','Saving the subject digitization file','C:\Users\owner\Desktop\Digitization\*.txt');
fileID = fopen([PathName FileName],'w');
if nfid == 5
    fprintf(fileID,'nz: %.1f %.1f %.1f\n',fid_pts(1,1),fid_pts(1,2),fid_pts(1,3));
    fprintf(fileID,'ar: %.1f %.1f %.1f\n',fid_pts(2,1),fid_pts(2,2),fid_pts(2,3));
    fprintf(fileID,'al: %.1f %.1f %.1f\n',fid_pts(3,1),fid_pts(3,2),fid_pts(3,3));
    fprintf(fileID,'cz: %.1f %.1f %.1f\n',fid_pts(4,1),fid_pts(4,2),fid_pts(4,3));
    fprintf(fileID,'iz: %.1f %.1f %.1f\n',fid_pts(5,1),fid_pts(5,2),fid_pts(5,3));
else
    fprintf(fileID,'nz: %.1f %.1f %.1f\n',fid_pts(1,1),fid_pts(1,2),fid_pts(1,3));
    fprintf(fileID,'ar: %.1f %.1f %.1f\n',fid_pts(2,1),fid_pts(2,2),fid_pts(2,3));
    fprintf(fileID,'al: %.1f %.1f %.1f\n',fid_pts(3,1),fid_pts(3,2),fid_pts(3,3));
end
for i=1:ns
    fprintf(fileID,'s%d: %.1f %.1f %.1f\n',i,src_pts(i,1),src_pts(i,2),src_pts(i,3));
end
for i=1:nd
    fprintf(fileID,'d%d: %.1f %.1f %.1f\n',i,det_pts(i,1),det_pts(i,2),det_pts(i,3));
end
fclose(fileID);
dig_pts_path = [PathName FileName];

% Compute and save pairings file and make it the new default.
min_pts_range = str2double(get(handles.min_optode_dist_edit,'String'));
max_pts_range = str2double(get(handles.max_optode_dist_edit,'String'));
idx_min_cell=rangesearch(det_pts,src_pts,min_pts_range);
idx_max_cell=rangesearch(det_pts,src_pts,max_pts_range);
for i = 1:size(idx_max_cell,1)
    idx{i,1}=setdiff(idx_max_cell{i,1},idx_min_cell{i,1});
end
row=1;
MeasList=[];
for i=1:ns
    det_conn=sort(idx{i,1});
    for j=1:length(det_conn)
        MeasList(row,:)=[i det_conn(j) 1 1];
        row=row+1;
    end
end
% convert for NIRS toolbox format
SD.SrcPos = src_pts;
SD.DetPos = det_pts;
SD.nSrcs = ns;
SD.nDets = nd;
if ~isempty(MeasList)
    MeasList2 = MeasList;
    MeasList2(:,4) = 2;
    SD.MeasList = [MeasList; MeasList2];
    for i=1:size(SD.MeasList,1)
        p1 = handles.src_pts(SD.MeasList(i,1),:);
        p2 = handles.det_pts(SD.MeasList(i,2),:);
        p = [p1;p2];
        line(handles.axes_left,p(:,1),p(:,2),p(:,3),'Color','y');
        line(handles.axes_right,p(:,1),p(:,2),p(:,3),'Color','y');
    end
else
    SD.MeasList = [];
    warndlg('Empty pairings');
end
pairings_path = [PathName FileName(1:end-4) '.SD'];
save(pairings_path,'SD');
    
% Update init.mat
save([pwd filesep 'init.mat'],'baud_rate','com_port','max_pts_range','min_pts_range','dig_pts_path','pairings_path','-append');
set(handles.pushbutton_digitize,'Enable','on');

% If something went wrong, display error message and close serial object
catch
    errordlg('COM port error. Please check if the COM port and baud rate settings are correct.','Patriot communication error','modal');
    if exist('com','var')
        fclose(com);
        delete(com);
        clear com
    end
end

function timeout_callback(obj,event)

errordlg('Patriot is not responding. Please check the COM port settings.','Patriot error','modal');
fclose(obj);
delete(obj);
clear obj
