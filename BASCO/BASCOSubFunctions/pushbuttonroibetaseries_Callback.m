function pushbuttonroibetaseries_Callback(hObject, ~, handles)
% plot beta-series for seed-ROI
NumSubj = handles.NumJobs;
str = sprintf('Please select subject (%d) and summary function (mean or median).',NumSubj);
set(handles.infobox,'String',str);
drawnow;
prompt    = { 'Select subject' , 'Summary function' };
dlg_title = 'Configure';
num_lines = 1;
def       = { '1' , 'mean' };
answer    = inputdlg(prompt,dlg_title,num_lines,def);
isubj     = str2num(answer{1});
SumFunc   = answer{2};
ROIfile = handles.SeedROI;
thecond = str2num(get(handles.editconditionrissman,'String'));
str = sprintf('Beta-series for selected seed-ROI and the condition(s): %s (subject %d)',num2str(thecond),isubj);
set(handles.infobox,'String',str);
drawnow;
[voxelbs]            = EstimateModelOnROI(handles,isubj,ROIfile,SumFunc,thecond);
[seedroimeanbs_cond] = MeanROIBetaSeries(handles,isubj,ROIfile,thecond);
figure('Name','');
plot([1:1:length(voxelbs)],voxelbs,'b-+',[1:1:length(seedroimeanbs_cond)],seedroimeanbs_cond,'r-+');
xlabel('trial');
ylabel('beta-value');
title('beta-series seed-ROI (model estimated on ROI level)');
legend('estimated on ROI level','estimated on voxel level (mean)');
guidata(hObject, handles);
end