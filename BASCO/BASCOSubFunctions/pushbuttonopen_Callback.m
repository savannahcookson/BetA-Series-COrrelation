function pushbuttonopen_Callback(hObject, ~, handles)
% load analysis object from file
[file,path]=uigetfile('*.mat','MultiSelect','off');
str=sprintf('Reading file %s.',fullfile(path,file));
handles.InfoText = WriteInfoBox(handles,str,true);
load(fullfile(path,file));
handles.anaobj = anaobj;
handles.NumJobs = size(anaobj,2);
str=sprintf('<INFO> : Analysis object read from file: \n %s.',fullfile(path,file));
handles.InfoText = WriteInfoBox(handles,str,true);
handles.InfoText = WriteInfoBox(handles,sprintf('Number of subjects: %d',handles.NumJobs),true);
guidata(hObject, handles);
end