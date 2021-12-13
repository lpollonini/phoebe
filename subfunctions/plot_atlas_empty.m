current_view = handles.axes_left.View;
set(handles.uipanel_head,'SelectedObject',handles.radiobutton_doubleview); % Always plot two heads 
cla(handles.axes_left);
cla(handles.axes_right);
set(handles.axes_left,'Position',[0.05,0.025,0.5,0.95]);
plot_mesh(handles.axes_left,handles.faces(:,2:4), handles.vertices(:,2:4),handles.opacity,'scalp');
plot_mesh(handles.axes_left,handles.faces_brain(:,2:4), handles.vertices_brain(:,2:4),1,'brain');
hold(handles.axes_left,'on')
scatter3(handles.axes_left,handles.atlas_fid_pts(:,1), handles.atlas_fid_pts(:,2), handles.atlas_fid_pts(:,3), 20,'y','fill'); % Plot atlas fiducials    axis([-130 130 -230 130 -100 150]) % FIX Automatic setting to fit large head or tall optodes
set(handles.axes_left,'XLim',[-90-80*handles.zoom_index 90+80*handles.zoom_index])
set(handles.axes_left,'YLim',[-120-200*handles.zoom_index 90+130*handles.zoom_index])
set(handles.axes_left,'ZLim',[-70-60*handles.zoom_index 100+200*handles.zoom_index])
set(handles.axes_left,'View',current_view);
handles.h_light_left = light;
lightangle(handles.h_light_left, current_view(1),current_view(2))
h_rot3d = rotate3d;
h_rot3d.ActionPostCallback = @rot3dcallback;
h_rot3d.Enable = 'on';
% If double view, do the same on the right head
if get(handles.uipanel_head,'SelectedObject')==handles.radiobutton_doubleview
    current_view = handles.axes_right.View;
    plot_mesh(handles.axes_right,handles.faces(:,2:4), handles.vertices(:,2:4),handles.opacity,'scalp');
    plot_mesh(handles.axes_right,handles.faces_brain(:,2:4), handles.vertices_brain(:,2:4),1,'brain');
    hold(handles.axes_right,'on')
    scatter3(handles.axes_right,handles.atlas_fid_pts(:,1), handles.atlas_fid_pts(:,2), handles.atlas_fid_pts(:,3), 20,'y','fill'); % Plot atlas fiducials        axis([-130 130 -230 130 -100 150]) % FIX autoset larger view
    set(handles.axes_right,'XLim',[-90-80*handles.zoom_index 90+80*handles.zoom_index])
    set(handles.axes_right,'YLim',[-120-200*handles.zoom_index 90+130*handles.zoom_index])
    set(handles.axes_right,'ZLim',[-70-60*handles.zoom_index 100+200*handles.zoom_index])
    set(handles.axes_right,'View',current_view);
    handles.h_light_right = light;
    lightangle(handles.h_light_right, current_view(1),current_view(2))
    %view(165, 10)
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