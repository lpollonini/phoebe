
set(handles.figure_main,'Units','pixels')
tg = uitabgroup(handles.figure_main,'Units','normalized','Position',[0.01 0.49 0.15 0.5]);
tab1 = uitab(tg,'Title','Monitor');
tab2 = uitab(tg,'Title','Digitizer');
set(handles.uipanel_phoebe_parameters,'Parent',tab1,'Units','normalized','Position',[0 0 1 1]);
set(handles.uipanel_digitizer_parameters,'Parent',tab2,'Units','normalized','Position',[0 0 1 1]);
guidata(hObject,handles);
