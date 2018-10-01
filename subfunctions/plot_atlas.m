 plot_mesh(handles.axes_left,handles.faces(:,2:4), handles.vertices(:,2:4),handles.opacity); % faces and vertices are the atlas graphical variables
hold(handles.axes_left,'on')
scatter3(handles.axes_left,handles.atlas_fid_pts(:,1), handles.atlas_fid_pts(:,2), handles.atlas_fid_pts(:,3), 20,'y','fill'); % Plot atlas fiducials
scatter3(handles.axes_left,handles.fid_pts(:,1), handles.fid_pts(:,2), handles.fid_pts(:,3),20,'g','fill'); % Plot digitized fiducials after affine transformation
text(handles.axes_left,handles.fid_pts(:,1), handles.fid_pts(:,2), handles.fid_pts(:,3), ['  NZ';'  AR';'  AL'],'Color','g');
set(handles.axes_left,'XLim',[-90-80*handles.zoom_index 90+80*handles.zoom_index])
set(handles.axes_left,'YLim',[-120-200*handles.zoom_index 90+130*handles.zoom_index])
set(handles.axes_left,'ZLim',[-70-60*handles.zoom_index 100+200*handles.zoom_index])
view(165, 10)
handles.h_src_left = scatter3(handles.axes_left,handles.src_pts(:,1), handles.src_pts(:,2), handles.src_pts(:,3),60,'r'); % Plots sources
handles.h_det_left = scatter3(handles.axes_left,handles.det_pts(:,1), handles.det_pts(:,2), handles.det_pts(:,3),60,'b','s'); % Plots detectors
text(handles.axes_left,handles.src_pts(:,1), handles.src_pts(:,2), handles.src_pts(:,3), [repmat('  ',[size(handles.src_pts,1) 1]) num2str((1:size(handles.src_pts,1))','%d')],'Color','r') % Labels sources
text(handles.axes_left,handles.det_pts(:,1), handles.det_pts(:,2), handles.det_pts(:,3), [repmat('  ',[size(handles.det_pts,1) 1]) num2str((1:size(handles.det_pts,1))','%d')],'Color','b') % Labels detectors
for i=1:size(handles.SDpairs,1)
    p1 = handles.src_pts(handles.SDpairs(i,1),:);
    p2 = handles.det_pts(handles.SDpairs(i,2),:);
    p = [p1;p2];
    line(handles.axes_left,p(:,1),p(:,2),p(:,3),'Color','y');
end
rotate3d on
% If double view, do the same on the right head
if get(handles.uipanel_head,'SelectedObject')==handles.radiobutton_doubleview 
    plot_mesh(handles.axes_right,handles.faces(:,2:4), handles.vertices(:,2:4),handles.opacity);
    hold(handles.axes_right,'on')
    scatter3(handles.axes_right,handles.atlas_fid_pts(:,1), handles.atlas_fid_pts(:,2), handles.atlas_fid_pts(:,3), 20,'y','fill')
    scatter3(handles.axes_right,handles.fid_pts(:,1), handles.fid_pts(:,2), handles.fid_pts(:,3), 20,'g','fill')
    text(handles.axes_right,handles.fid_pts(:,1), handles.fid_pts(:,2), handles.fid_pts(:,3), ['  NZ';'  AR';'  AL'],'Color','g');
    set(handles.axes_right,'XLim',[-90-80*handles.zoom_index 90+80*handles.zoom_index])
    set(handles.axes_right,'YLim',[-120-200*handles.zoom_index 90+130*handles.zoom_index])
    set(handles.axes_right,'ZLim',[-70-60*handles.zoom_index 100+200*handles.zoom_index])
    view(165, 10) % FIX angled view?
    handles.h_src_right = scatter3(handles.axes_right,handles.src_pts(:,1), handles.src_pts(:,2), handles.src_pts(:,3),60,'r'); 
    handles.h_det_right = scatter3(handles.axes_right,handles.det_pts(:,1), handles.det_pts(:,2), handles.det_pts(:,3),60,'b','s');
    text(handles.axes_right,handles.src_pts(:,1), handles.src_pts(:,2), handles.src_pts(:,3), [repmat('  ',[size(handles.src_pts,1) 1]) num2str((1:size(handles.src_pts,1))','%d')],'Color','r')
    text(handles.axes_right,handles.det_pts(:,1), handles.det_pts(:,2), handles.det_pts(:,3), [repmat('  ',[size(handles.det_pts,1) 1]) num2str((1:size(handles.det_pts,1))','%d')],'Color','b')
    for i=1:size(handles.SDpairs,1)
        p1 = handles.src_pts(handles.SDpairs(i,1),:);
        p2 = handles.det_pts(handles.SDpairs(i,2),:);
        p = [p1;p2];
        line(handles.axes_right,p(:,1),p(:,2),p(:,3),'Color','y');
    end
    rotate3d on
else
    set(handles.axes_right,'Visible','off');
    cla(handles.axes_right);
end
guidata(hObject,handles);