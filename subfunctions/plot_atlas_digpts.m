current_view = handles.axes_left.View;
cla(handles.axes_left)
plot_mesh(handles.axes_left,handles.faces(:,2:4), handles.vertices(:,2:4),handles.opacity); % faces and vertices are the atlas graphical variables
hold(handles.axes_left,'on')
scatter3(handles.axes_left,handles.atlas_fid_pts(:,1), handles.atlas_fid_pts(:,2), handles.atlas_fid_pts(:,3), 20,'y','fill'); % Plot atlas fiducials
scatter3(handles.axes_left,handles.fid_pts(:,1), handles.fid_pts(:,2), handles.fid_pts(:,3),20,'g','fill'); % Plot digitized fiducials after affine transformation
text(handles.axes_left,handles.fid_pts(:,1), handles.fid_pts(:,2), handles.fid_pts(:,3), ['  NZ';'  AR';'  AL'],'Color','g');
set(handles.axes_left,'XLim',[-90-80*handles.zoom_index 90+80*handles.zoom_index])
set(handles.axes_left,'YLim',[-120-200*handles.zoom_index 90+130*handles.zoom_index])
set(handles.axes_left,'ZLim',[-70-60*handles.zoom_index 100+200*handles.zoom_index])
set(handles.axes_left,'View',current_view);
handles.h_light_left = light;
lightangle(handles.h_light_left, current_view(1),current_view(2))
handles.h_src_left = scatter3(handles.axes_left,handles.src_pts(:,1), handles.src_pts(:,2), handles.src_pts(:,3),80,'r','fill','SizeData',60,'LineWidth',2); % Plots sources
handles.h_det_left = scatter3(handles.axes_left,handles.det_pts(:,1), handles.det_pts(:,2), handles.det_pts(:,3),80,'b','fill','s','SizeData',60,'LineWidth',2); % Plots detectors
text(handles.axes_left,handles.src_pts(:,1), handles.src_pts(:,2), handles.src_pts(:,3), [repmat('  ',[size(handles.src_pts,1) 1]) num2str((1:size(handles.src_pts,1))','%d')],'Color','r','FontSize',15,'FontWeight','bold') % Labels sources
text(handles.axes_left,handles.det_pts(:,1), handles.det_pts(:,2), handles.det_pts(:,3), [repmat('  ',[size(handles.det_pts,1) 1]) num2str((1:size(handles.det_pts,1))','%d')],'Color','b','FontSize',15,'FontWeight','bold') % Labels detectors
h_rot3d = rotate3d;
h_rot3d.ActionPostCallback = @rot3dcallback;
h_rot3d.Enable = 'on';
% If double view, do the same on the right head
if get(handles.uipanel_head,'SelectedObject')==handles.radiobutton_doubleview
    current_view = handles.axes_right.View;
    cla(handles.axes_right)
    plot_mesh(handles.axes_right,handles.faces(:,2:4), handles.vertices(:,2:4),handles.opacity);
    hold(handles.axes_right,'on')
    scatter3(handles.axes_right,handles.atlas_fid_pts(:,1), handles.atlas_fid_pts(:,2), handles.atlas_fid_pts(:,3), 20,'y','fill')
    scatter3(handles.axes_right,handles.fid_pts(:,1), handles.fid_pts(:,2), handles.fid_pts(:,3), 20,'g','fill')
    text(handles.axes_right,handles.fid_pts(:,1), handles.fid_pts(:,2), handles.fid_pts(:,3), ['  NZ';'  AR';'  AL'],'Color','g');
    set(handles.axes_right,'XLim',[-90-80*handles.zoom_index 90+80*handles.zoom_index])
    set(handles.axes_right,'YLim',[-120-200*handles.zoom_index 90+130*handles.zoom_index])
    set(handles.axes_right,'ZLim',[-70-60*handles.zoom_index 100+200*handles.zoom_index])
    set(handles.axes_right,'View',current_view);
    handles.h_light_right = light;
    lightangle(handles.h_light_right, current_view(1),current_view(2))
    handles.h_src_right = scatter3(handles.axes_right,handles.src_pts(:,1), handles.src_pts(:,2), handles.src_pts(:,3),60,'r','fill','SizeData',60,'LineWidth',2); 
    handles.h_det_right = scatter3(handles.axes_right,handles.det_pts(:,1), handles.det_pts(:,2), handles.det_pts(:,3),60,'b','fill','s','SizeData',60,'LineWidth',2);
    text(handles.axes_right,handles.src_pts(:,1), handles.src_pts(:,2), handles.src_pts(:,3), [repmat('  ',[size(handles.src_pts,1) 1]) num2str((1:size(handles.src_pts,1))','%d')],'Color','r','FontSize',15,'FontWeight','bold')
    text(handles.axes_right,handles.det_pts(:,1), handles.det_pts(:,2), handles.det_pts(:,3), [repmat('  ',[size(handles.det_pts,1) 1]) num2str((1:size(handles.det_pts,1))','%d')],'Color','b','FontSize',15,'FontWeight','bold')
    rotate3d on
else
    set(handles.axes_right,'Visible','off');
    cla(handles.axes_right);
end
guidata(hObject,handles);

function rot3dcallback(obj,evd)
    handles = guidata(obj);
    lightangle(handles.h_light_left, handles.axes_left.View(1),handles.axes_left.View(2))
    if get(handles.uipanel_head,'SelectedObject')==handles.radiobutton_doubleview
        lightangle(handles.h_light_right, handles.axes_right.View(1),handles.axes_right.View(2))
    end
end

