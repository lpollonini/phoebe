det_pts = handles.det_pts;
src_pts = handles.src_pts;
idx_min_cell=sd_rangesearch(det_pts,src_pts,20);
idx_max_cell=sd_rangesearch(det_pts,src_pts,50);
for i = 1:size(idx_max_cell,1)
    idx{i,1}=setdiff(idx_max_cell{i,1},idx_min_cell{i,1});
end
row=1;
SDpairs=[];
for i=1:size(src_pts,1)
    det_conn=sort(idx{i,1});
    for j=1:length(det_conn)
        SDpairs(row,:)=[i det_conn(j) 1 1];
        row=row+1;
    end
end
px = zeros(2,size(SDpairs,1));
py = zeros(2,size(SDpairs,1));
pz = zeros(2,size(SDpairs,1));
for i=1:size(SDpairs,1)
    p1 = handles.src_pts(SDpairs(i,1),:);
    p2 = handles.det_pts(SDpairs(i,2),:);
    px(:,i) = [p1(1);p2(1)];
    py(:,i) = [p1(2);p2(2)];
    pz(:,i) = [p1(3);p2(3)];
end
handles.h_links_left = line(handles.axes_left,px,py,pz,'Color','y','LineWidth',3);

% If double view, do the same on the right head
if get(handles.uipanel_head,'SelectedObject')==handles.radiobutton_doubleview 
    handles.h_links_right = line(handles.axes_right,px,py,pz,'Color','y','LineWidth',3);
else
    set(handles.axes_right,'Visible','off');
    cla(handles.axes_right);
end
guidata(hObject,handles);