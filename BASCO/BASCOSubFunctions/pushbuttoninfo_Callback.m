function pushbuttoninfo_Callback(hObject, ~, handles)
if handles.NumJobs==0
    str='<INFO> : No analysis. Load analysis object or create new analysis with => Model specification and estimation <=.';
    handles.InfoText = WriteInfoBox(handles,str,true);
    return;
end
str=sprintf('Number of subjects: %d',handles.NumJobs);
handles.InfoText = WriteInfoBox(handles,str,true);
disp(handles.anaobj{1});
disp(handles.anaobj{1}.Ana{1});
guidata(hObject, handles);
end