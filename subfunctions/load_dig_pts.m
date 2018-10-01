function [ handles ] = load_dig_pts( handles, dig_pts_path )
%LOAD_DIG_PTS Summary of this function goes here
%   Detailed explanation goes here

dig_pts=importdata(dig_pts_path);        

% Fiducials nz, ar, al to be used for transformation into predefined atlas
for i=1:size(dig_pts.data,1)
    match1=strfind(dig_pts.textdata(i),'nz:');
    match2=strfind(dig_pts.textdata(i),'ar:');
    match3=strfind(dig_pts.textdata(i),'al:');
    fid_pts(1:3,:)=dig_pts.data(1:3,:);
end
% Reads all sources
match=strfind(dig_pts.textdata,['s1:']);
idx=find(~cellfun(@isempty,match));
s_pts=[];
for i=1:size(dig_pts.data,1)-idx+1
    match=cell2mat(strfind(dig_pts.textdata(idx+i-1),['s' num2str(i) ':']));
    if ~isempty(match)
        s_pts=[s_pts; dig_pts.data(idx+i-1,:)];
    end
end
%Reads all detectors
match=strfind(dig_pts.textdata,['d1:']);
idx=find(~cellfun(@isempty,match));
d_pts=[];
for i=1:size(dig_pts.data,1)-idx+1
    match=cell2mat(strfind(dig_pts.textdata(idx+i-1),['d' num2str(i) ':']));
    if ~isempty(match)
        d_pts=[d_pts; dig_pts.data(idx+i-1,:)];
    end
end

% Finds rigid transformation from Patriot space to atlas space
[R,t] = rigid_transform_3D(fid_pts, handles.atlas_fid_pts([1 3 2],:)); % Note: fid_pts are the digitized fiducials
%T1=[R t; 0 0 0 1];
% Applies transformation to bring all points (fds, sources, detectors) into atlas space, and save them in GUI handler to pass it everywhere needed 
handles.fid_pts = transform_points(fid_pts,R,t);
handles.src_pts = transform_points(s_pts,R,t);
handles.det_pts = transform_points(d_pts,R,t);

% For testing scaling
%     figure
%     hold on
%     scatter3(handles.fid_pts(:,1),handles.fid_pts(:,2),handles.fid_pts(:,3),'k');
%     scatter3(handles.src_pts(:,1),handles.src_pts(:,2),handles.src_pts(:,3),'r');
%     scatter3(handles.det_pts(:,1),handles.det_pts(:,2),handles.det_pts(:,3),'b');
%     axis equal

% Applies scaling factor to best fit Patriot/subjects space to atlas space
[handles.fid_pts,handles.src_pts,handles.det_pts] = scaling(handles.fid_pts,handles.src_pts,handles.det_pts,handles.atlas_fid_pts,1);

 % For testing scaling
%     scatter3(handles.fid_pts(:,1),handles.fid_pts(:,2),handles.fid_pts(:,3),'k');
%     scatter3(handles.src_pts(:,1),handles.src_pts(:,2),handles.src_pts(:,3),'r');
%     scatter3(handles.det_pts(:,1),handles.det_pts(:,2),handles.det_pts(:,3),'b');



