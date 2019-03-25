function pushbuttonseedroi_Callback(hObject, eventdata, handles)
% select ROI
[roifile,roipath] = uigetfile('*.mat','Select seed ROI (marsbar .mat)','MultiSelect','off');
str=sprintf('Selected seed-ROI: %s. \nNow enter name for ROI.',fullfile(roipath,roifile));
handles.InfoText = WriteInfoBox(handles,str,true);
handles.SeedROI  = fullfile(roipath,roifile);
prompt    = { 'ROI name' };
dlg_title = 'ROI name';
num_lines = 1;
def       = { strrep(roifile,'.mat','') };
answer    = inputdlg(prompt,dlg_title,num_lines,def);
handles.SeedROIName = answer{1};
str=sprintf('Name: %s. \nNow you want to specify a condition and calculate the correlation map.',handles.SeedROIName);
handles.InfoText = WriteInfoBox(handles,str,true);
guidata(hObject, handles);
end