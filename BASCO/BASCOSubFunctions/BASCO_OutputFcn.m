function varargout = BASCO_OutputFcn(hObject, ~, handles)
varargout{1}     = handles.output;
handles.NumJobs  = 0; % number of subjects
handles.maskfile = '';
handles.InfoText = '';
str='<HELP> : Load file containing analysis data or start => Model specification and estimation <= to load an analysis configuration file.';
handles.InfoText = WriteInfoBox(handles,str,false);
list1{1}='paired t-test';
list1{2}='two-sample t-test';
list1{3}='flexible factorial 2x2';
set(handles.popupmenulevel2,'String',list1);
list2{1}='Tools';
list2{2}='ROI mean beta-values (over trials and subjects)';
list2{3}='Estimate model for single ROI (one subject)';
list2{4}='Estimate model for single ROI (all subjects)';
list2{5}='Rename ROIs';
list2{6}='Reslice image';
list2{7}='Select subject(s)';
list2{8}='Assign number labelled ROI-file.';
list2{9}='Smooth maps';
list2{10}='Mean maps';
list2{11}='Check maps';
set(handles.popupmenumore,'String',list2);

list4{1}  = 'Network analysis';
list4{2}  = 'Network edges';
list4{3}  = 'Graph properties';
set(handles.popupmenu_nwana,'String',list4);

list3{1}='Product-moment correlation';
list3{2}='Spearman correlation coefficients';
list3{3}='arc-hyperbolic tangent transf.';
list3{4}='Pearson (outlier rejection)';
set(handles.popupmenucorrelation,'String',list3);
guidata(hObject, handles);
end