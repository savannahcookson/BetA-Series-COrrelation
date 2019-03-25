function BASCO_OpeningFcn(hObject, ~, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
spm('Defaults','fmri')
marsbar('on');
set(0, 'defaultTextInterpreter', 'none');
end