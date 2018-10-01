function [handles] = load_SD(handles,pairings_path)

%% Loads SD pairs to be considered for Phoebe, and saves info into GUI handler
load(pairings_path,'-mat','SD');
handles.src_num=SD.nSrcs;
handles.det_num=SD.nDets;
handles.opt_num=SD.nSrcs+SD.nDets;
if ~isempty(SD.MeasList)
    handles.SDpairs=SD.MeasList(SD.MeasList(:,4)==1,1:2);
    handles.A=zeros(handles.opt_num,handles.opt_num);
    for i=1:size(handles.SDpairs,1)
        handles.A(handles.SDpairs(i,1),handles.SDpairs(i,2)+SD.nSrcs)=1;
    end
else
    handles.SDpairs=[];
    handles.A=zeros(handles.opt_num,handles.opt_num);
    uiwait(warndlg('There are no source-detector pairings associated to this optodes layout. Please load a layout with valid pairigs.'));
end
