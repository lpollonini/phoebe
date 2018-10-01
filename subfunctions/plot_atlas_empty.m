set(handles.uipanel_head,'SelectedObject',handles.radiobutton_doubleview);
cla(handles.axes_left);
cla(handles.axes_right);
plot_mesh(handles.axes_left,handles.faces(:,2:4), handles.vertices(:,2:4),handles.opacity);
hold(handles.axes_left,'on')
scatter3(handles.axes_left,handles.atlas_fid_pts(:,1), handles.atlas_fid_pts(:,2), handles.atlas_fid_pts(:,3), 20,'y','fill'); % Plot atlas fiducials    axis([-130 130 -230 130 -100 150]) % FIX Automatic setting to fit large head or tall optodes
set(handles.axes_left,'XLim',[-90-80*handles.zoom_index 90+80*handles.zoom_index])
set(handles.axes_left,'YLim',[-120-200*handles.zoom_index 90+130*handles.zoom_index])
set(handles.axes_left,'ZLim',[-70-60*handles.zoom_index 100+200*handles.zoom_index])
view(165, 10)
rotate3d on
% If double view, do the same on the right head
if get(handles.uipanel_head,'SelectedObject')==handles.radiobutton_doubleview 
    plot_mesh(handles.axes_right,handles.faces(:,2:4), handles.vertices(:,2:4),handles.opacity);
    hold(handles.axes_right,'on')
    scatter3(handles.axes_right,handles.atlas_fid_pts(:,1), handles.atlas_fid_pts(:,2), handles.atlas_fid_pts(:,3), 20,'y','fill'); % Plot atlas fiducials        axis([-130 130 -230 130 -100 150]) % FIX autoset larger view
    set(handles.axes_right,'XLim',[-90-80*handles.zoom_index 90+80*handles.zoom_index])
    set(handles.axes_right,'YLim',[-120-200*handles.zoom_index 90+130*handles.zoom_index])
    set(handles.axes_right,'ZLim',[-70-60*handles.zoom_index 100+200*handles.zoom_index])
    view(165, 10)
    rotate3d on
else
    set(handles.axes_right,'Visible','off');
    cla(handles.axes_right);
end