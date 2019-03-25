function pushbuttoncorrelationmatrix_Callback(hObject, eventdata, handles)
try
    NWM = handles.anaobj{1}.Ana{1}.Matrix;
catch
    handles.InfoText = WriteInfoBox(handles,'Compute correlation matrix first.',true);
    guidata(hObject, handles);
    return;
end
InspectCorrMatrix(handles.anaobj);
end