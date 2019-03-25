function pushbutton_rissmannmask_Callback(hObject, eventdata, handles)
handles.maskfile = spm_select(1,'mat','Select mask (Marsbar).');
handles.InfoText = WriteInfoBox(handles,'Mask selected.',true);
guidata(hObject, handles);
end